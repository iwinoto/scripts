import { mkdir, writeFile } from "fs/promises";
import { join } from "path";
import ibm from "ibm-cos-sdk";
import * as dotenv from 'dotenv';
import { Command } from 'commander';

dotenv.config();

if (!process.env["IBMCLOUD_APIKEY"]) {
    throw new Error("Not all vars passed!");
}

const COS_AUTH_ENDPOINT = "https://iam.cloud.ibm.com/identity/token";
const COS_ENDPOINT = "s3.au-syd.cloud-object-storage.appdomain.cloud";

//let destDir = `./cos/`;
const includePrefix = true;

const config = {
    endpoint: COS_ENDPOINT,
    apiKeyId: process.env["IBMCLOUD_APIKEY"],
    ibmAuthEndpoint: COS_AUTH_ENDPOINT,
    serviceInstanceId: "crn:v1:bluemix:public:cloud-object-storage:global:a/c15ecdd5890bdc705dd4e448a0a4b68d:bc97eb6e-53f3-4e55-afef-a340fb146906::",
    signatureVersion: 'iam'
};

/**
 * Strip the bucket name from the the start of the path
 * @param {string} name the string we're stripping
 * @returns the stripped name
 */
function stripBucketEnvName(name) {
    if (includePrefix) {
        return name;
    }
    else {
        const startStr = `${environment}-`;
        if (name.startsWith(startStr)) {
            return name.substring(startStr.length);
        }
    }
}

async function restoreFilesInBucket(cos, bucket, prefix = undefined, period, periodUnit) {
    /**
     * Restore files that are in cold storage, or extend their availability
     * <period> int
     * <periodUnit> char d, w, m, y
     */
}

async function downloadFilesInBucket(cos, bucket, prefix = undefined, destDir) {
    const bucketDir = join(destDir, stripBucketEnvName(bucket));
    await mkdir(bucketDir, {recursive: true});

    /**
     * The Steps for this function are:
     * 1. Get the folders in the bucket (really the keys)
     * 2. Pick only the unique folders
     * 3. Create these folders
     *      - Because we have created these folders already it becomes easy to download the files into the key path straight away
     * 4. Download all objects in the bucket in a parallel fashion and store to memory (BAD, but it works for now and we assume that there aren't any large files in COS)
     * 5. Write the objects to their path at the same time
     */

    console.log(bucket, `Listing Files ${prefix ? "with prefix: " + prefix : ""}`);
    const objectsRes = await cos.listObjects({
        Bucket: bucket,
        Prefix: prefix
    }).promise();

    // We remove out any objects are just dirs
    const objects = objectsRes.Contents.filter(it => !it.Key.endsWith("/"));

    console.log(bucket, objects.map(it => it.Key));

    // lets make the dirs first
    // 1. Get the folders in the bucket (really the keys)
    const folders = objects.map(it => {
        const pathObjects = it.Key.split("/");
        pathObjects.pop();
        const finalPath = join(bucketDir, ...pathObjects);
        // console.log(finalPath);
        return finalPath;
    });

    // 2. Pick only the unique folders
    const foldersUnique = new Set(folders);
    
    // 3. Create these folders
    console.log(bucket, foldersUnique);
    for (const folder of foldersUnique) {
        await mkdir(folder, {recursive: true});
    }

    // 4. Download all objects in the bucket in a parallel fashion and store to memory
    console.log(bucket, "Downloading Files");
    const objectData = await Promise.all(objects.map(object => {
        console.log("request to get :", object.Key);
        return cos.getObject({
            Bucket: bucket,
            Key: object.Key
        }).promise().then(it => {
            console.log("Downloaded:", object.Key);
            console.log("Saved Path:", join(bucketDir, object.Key));
            return {
                path: join(bucketDir, object.Key),
                data: it.Body
            }
        });
    }));

    // console.log(objectData);

    // 5. Write the objects to their path at the same time
    const writeFilesPromise = await Promise.all(objectData.map(it => {
        console.log("Writing:", it.path);
        return writeFile(it.path, it.data).then(_ => console.log("Wrote:", it.path));
    }));

    console.log(bucket, "Files written");
}

async function main() {
    const cos = new ibm.S3(config);
    // const items = await cos.listObjectsV2({
    //     Bucket: "uat-core-backup",
    //     Prefix: "uat-backup-2023-01-18/"
    // }).promise();

    const program = new Command();
    program
        .option('-b, --bucket <value>', 'The bucket from which to download objects', 'prod-logdna-archived-logs')
        .option('-p, --prefix <value>', 'The bucket object prefix. Objects under this prefix will be downloaded')
        .option('-d, --destination <avlue>', 'Destination directory for downloaded files.', './cos/');

    program.parse(process.argv);
    let options = program.opts()

    let bucket = options.bucket;
    let prefix = options.prefix;
    let destDir = options.destination;

    console.log('Bucket: ', `${bucket}`);
    console.log('Prefix: ', `${prefix}`);
    console.log('Destination dir: ', `${destDir}`);

    downloadFilesInBucket(cos, bucket, prefix, destDir);
    
    /*
    const days = [13, 14, 20];
    for (let index in days){
        downloadFilesInBucket(cos, bucket, prefix + "day=" + days[index].toString() + "/");
    }
    */


/*
    let day = 1;
    while ( day <= 31){
        downloadFilesInBucket(cos, bucket, prefix + "day=" + day.toString() + "/");
        day++;
    }
*/
    
}

main();



