List volume by username to get its ID for further commands
```
$ ibmcloud sl file volume-list -d syd01 -t endurance -u DSW02SEV1703041_704
id          username              datacenter   storage_type             capacity_gb   ip_addr                                 mount_addr
175939774   DSW02SEV1703041_704   syd01        endurance_file_storage   20            fsf-syd0101g-fz.service.softlayer.com   fsf-syd0101g-fz.service.softlayer.com:/DSW02SEV1703041_704/data01
```

Details for a volume does not show the notes.
```
ibmcloud sl file volume-detail 175939774 --output json
```

ID of volume named `DSW02SEV1703041_704` is `175939774`

List snapshots for a volume
```
ibmcloud sl file snapshot-list 175939774
```

List replicas for a volume (known as `replica-partners`)
```
ibmcloud sl file replica-partners 175939774 --output json
```

Create a duplicate volume from a replica. `178082566` is the ID of a replica of `175939774`
```
ibmcloud sl file volume-duplicate 178082566
```

