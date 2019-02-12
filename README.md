# Application Navigator Helm Chart

Application Navigator [Documentation](https://github.com/WASdev/app-nav-helm-chart/wiki).

## Installation

Clone this repository.

### Installation for IBM Cloud Private

Prereqs: 

1. Install [KubeCtl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
1. Install [Helm CLI](https://github.com/helm/helm/blob/master/docs/install.md).
1. Install [ICP CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/install_cli.html).
1. Create [ICP/CE Cluster](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_1.2.0/installing/install_containers_CE.html).

Install the application navigator via helm chart

`helm install --name=application-navigator --namespace=prism app-nav-helm-chart/stable/prism --tls`

From IBM Cloud Private UI navigate to Workload > Deployments > Prism.  Click the "Launch" button to access the Application Navigator UI.

### Installation for Minikube

1. Install [KubeCtl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
1. Install [Helm CLI](https://github.com/helm/helm/blob/master/docs/install.md).
1. Install [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/).

Install the application navigator via helm chart

`helm install --name=application-navigator --namespace=prism --set env.kubeEnv=minikube --set service.port=9080 --set service.targetPort=9080 --set service.scheme=HTTP --set env.target=http://localhost:9080 app-nav-helm-chart/stable/prism`

Launch Application Navigator UI using command:  'minikube service prism -n prism'. 

## Install Sample

The list of applications in the Application Navigator UI will be empty at first.  A quick way to get started will be to install a sample.

### On ICP:  

1. `kubectl apply -f samples/crds`
1. `helm install --name=stock-trader samples/stocktraderChart --tls`

### On Minikube:  

1. `kubectl apply -f samples/crds`
1. `helm install --name=stock-trader samples/stocktraderChart`

## Uninstall

### On ICP:  

1. `helm delete application-navigator --purge --tls`
1. `helm delete stock-trader --purge --tls` 

### On Minikube:  

1. `helm delete application-navigator --purge`
1. `helm delete stock-trader --purge`

## Troubleshooting

If Application Navigator fails to uninstall you may need to delete the following jobs to complete the uninstall: prism-init-post, prism-delete. Search for these jobs with command: 

`kubectl get jobs -n prism`

If you find either of these jobs after you have issued the helm command to uninstall application navigator, delete them with the following command: 

`kubectl delete job \<job-name\> -n prism`

