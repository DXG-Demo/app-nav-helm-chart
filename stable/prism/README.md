# Prism Helm Chart

## Introduction 



## Accessing Prism


### Prerequisites

#### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-prism-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-websphere-liberty-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-websphere-liberty-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
  ```

#### Configuration scripts can be used to create the required resources

??

### Installing the Chart

The Helm chart has the following values that can be overridden by using `--set name=value`. For example:

*    `helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`
*    `helm install --name prism ibm-charts/??? --debug`

### Configuration - It is not recommended to change any configuration values. 

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| `image`   | `repository`     | Name of API server image, including repository prefix (if required). | |
|           | `repositoryUI`   | Name of UI image, including repository prefix (if required). | |
|           | `repositoryInit` | Name of init image, including repository prefix (if required). | |
|           | `pullPolicy`     | Image Pull Policy | `Always`, `Never`, or `IfNotPresent`. Defaults to `Always` if `:latest` tag is specified, or `IfNotPresent` otherwise. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images)  |
|           | `tag`            | Docker image tag. | See Docker - [Tag](https://docs.docker.com/engine/reference/commandline/tag/) |
| `service` | `name`           | The service metadata name and DNS A record.  | |
|           | `port`           | The port that the api container exposes.  |   |
|           | `targetPort`     | Port that will be exposed externally by the pod. | |
| `env`     | `kubeEnv`        | Specifies the Kubernetes environment. | `icp` or `minikube` |
|           | `target`         | The target URL for the API server |  |


## Travis builds

Travis build are kicked off during commits to branches (master or another) and PR creations.  They can be viewed in this link: https://travis.ibm.com/WASCloudPrivate/helm-chart-prism

You can then use the generated helm repository to test your changes: http://icpbuild.rtp.raleigh.ibm.com:31532/WASCloudPrivate/helm-chart-prism/

