## Install `istioctl`
Configure `kubectl` for the target cluster context.

check the vertsion of istio installed 
```
istioctl version
```

If `istioctl` not installed, check the Istio vesion on the cluster 
```
kubectl -n istio-system get deployment istiod -o json | jq -r '.metadata.labels'
```

Install cluster version of `istioctl`
```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=<version> sh -
```
