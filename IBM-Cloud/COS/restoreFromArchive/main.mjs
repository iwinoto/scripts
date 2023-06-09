import { mkdir, writeFile } from "fs/promises";
import { join } from "path";
import * as dotenv from 'dotenv';
dotenv.config();

import ibm from "ibm-cos-sdk";

if (!process.env["IBMCLOUD_APIKEY"]) {
    throw new Error("Not all vars passed!");
}

const COS_AUTH_ENDPOINT = "https://iam.cloud.ibm.com/identity/token";
const COS_ENDPOINT = "s3.au-syd.cloud-object-storage.appdomain.cloud";

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

async function unarchiveFilesInBucket(cos, bucket, prefix = undefined, days) {
    // const bucketDir = join(destDir, stripBucketEnvName(bucket));
    // await mkdir(bucketDir, {recursive: true});

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

    console.log(objects);
    

    const results = await Promise.all(objects.map(object => {
        if (object.StorageClass === "STANDARD") {
            console.log("Not restoring:", object.Key, "as it's not archived.");
            return Promise.resolve();
        }
        
        if (object.StorageClass === "ACCELERATED" || Object.StorageClass === "GLACIER") {
            console.log("Not restoring:", object.Key, "as it's being restored already");
            return Promise.resolve();
        }



        const params = {
            Bucket: bucket, 
            Key: object.Key, 
            RestoreRequest: {
                Days: days, 
                GlacierJobParameters: {
                    Tier: 'Accelerated' 
                },
            } 
        };

        return cos
            .restoreObject(params)
            .promise()
            .then(it => {
                console.log("Unarchived:", object.Key);
                return it
            }).catch(it => {
                console.log(it);
                if (it.code === "RestoreAlreadyInProgress") {
                    return Promise.resolve();
                }
                else {
                    console.error("Failed:", object.Key);
                    return Promise.reject(it);
                }
            });
    }));



}

async function main() {
    const config = {
        endpoint: COS_ENDPOINT,
        apiKeyId: process.env["IBMCLOUD_APIKEY"],
        ibmAuthEndpoint: COS_AUTH_ENDPOINT,
        serviceInstanceId: "crn:v1:bluemix:public:cloud-object-storage:global:a/c15ecdd5890bdc705dd4e448a0a4b68d:554ceddd-e9b8-438b-a036-064ca0925d01::",
        signatureVersion: 'iam'
    };

    let days = 14;
    const cos = new ibm.S3(config);

    //Nov
    for (let i = 21; i <= 30; i++) {
        await unarchiveFilesInBucket(cos, "prod-logdna-archived-logs", "year=2022/month=11/day=" + i.toString().padStart(2, '0') +"/", days);
    }
    // dec
    await unarchiveFilesInBucket(cos, "prod-logdna-archived-logs", "year=2022/month=12/", days);
    // Jan
    for (let i = 1; i <= 23; i++) {
        await unarchiveFilesInBucket(cos, "prod-logdna-archived-logs", "year=2023/month=01/day=" + i.toString().padStart(2, '0') +"/", days);
    }

    // unarchiveFilesInBucket(cos, "prod-logdna-archived-logs", "year=2022/month=11/day=21");

    // const savedLocation = await Promise.all(validBuckets.map(it => downloadFilesInBucket(cos, it)));

}

main();
