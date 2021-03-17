# Print all individuals and access groups that have an access policy to the resource
First get export an access report as a JSON file for the service instance from the [Cloud console Resource list](https://cloud.ibm.com/resources).

Which resource does this report relate to?
```
jq -r '.responses[] | .resource ' audit_containers-kubernetes_bsofgl3s06j68q703esg.json
```

Show a list of individuals and access groups who have access to the resource

```
jq -r '.responses[] | .access[] | .subject | if has("user") then .user else .accessGroupId end | .id + " = " + .displayName' audit_containers-kubernetes_bsofgl3s06j68q703esg.json
```

Can we use `jq reduce` to reduce `.access[]` to a single output under `.resource`? Something like
```
jq -r '.responses[] | .resource + reduce .access[] as $access ({}; . + $access.subject) ' audit_containers-kubernetes_bsofgl3s06j68q703esg.json
```
