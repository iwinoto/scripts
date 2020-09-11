Print all individuals and access groups that have an access policy to the resource

```
jq -r '.responses[] | .resource ' audit_containers-kubernetes_bsofgl3s06j68q703esg.json

jq -r '.responses[] | .access[] | .subject | if has("user") then .user else .accessGroupId end | .id + " = " + .displayName' audit_containers-kubernetes_bsofgl3s06j68q703esg.json
```

Can we use `jq reduce` to reduce `.access[]` to a single output under `.resource`? Something like
```
jq -r '.responses[] | .resource + reduce .access[] as $access ({}; . + $access.subject) ' audit_containers-kubernetes_bsofgl3s06j68q703esg.json
```
