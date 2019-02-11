# Application Navigator Helm Chart

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

`helm install --name=application-navigator --namespace=prism --set env.kubeEnv=minikube --set service.port=9080 --set service.targetPort=9080 --set service.scheme=HTTP --set env.target=http://localhost:9080 app-nav-helm-chart/stable/prism --tls`

Launch Application Navigator UI using command:  'minikube service prism -n prism'. 

## Install Sample

The list of applications in the Application Navigator UI will be empty at first.  A quick way to get started will be to install a sample.

`kubectl apply -f samples/crds`

`helm install --name=stocktrader samples/stocktraderChart`

## Uninstall

On ICP:  helm delete application-navigator --purge --tls 

On Minikube:  helm delete application-navigator --purge

## Troubleshooting

If Application Navigator fails to uninstall you may need to delete the following jobs to complete the uninstall: prism-init-post, prism-delete.
