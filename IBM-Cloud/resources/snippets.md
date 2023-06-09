* Get all service instances
```
➜ ibmcloud resource service-instances --output JSON > service-instances.json
```

Use jq regex to get crn parts (refer to [`jq documentation`](https://jqlang.github.io/jq/manual/#RegularexpressionsPCRE))

To split crn into an array of values:
```
jq -r '.[] | .crn | split(":")` service-instances.json
```

Can then use array index to get an individual vlaue. For example to get service name
```
jq -r '.[] | .crn | split(":") | .[4]' service-instances.json
```

Can also use `capture()` to transform the crn into an object

```
➜ jq -r '.[] | .crn | capture("(?<crn>[a-z,0-9]*):(?<version>[a-z,0-9]+):(?<platform>[a-z,0-9]+):(?<isolation>[a-z,0-9]+):(?<service>[a-z,0-9,-]+):(?<region>[a-z,0-9,-]+):(?<acc>[a-z,0-9,-,/]+):(?<resource>[a-z,0-9,-]+)") ' service-instances.json

```

To get unique set of service names
```
jq -r '[.[] | .crn | split(":") | .[4] ]| unique' instances-Production-1703041_20230609.json
```
