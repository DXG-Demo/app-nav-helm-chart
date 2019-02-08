# Application Navigator Helm Chart


## Installation

Clone the repository.

### Installation for IBM Cloud Private

Prereq: Install ICP CLI. https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/install_cli.html

Install the application navigator helm chart

`helm install --name=application-navigator --namespace=prism helm-chart-prism/stable/prism`

From IBM Cloud Private UI navigate to Network Access > Services > Prism.  The application navigator UI link will show up as the first link under Node port. 

### Installation for Minikube

Install the application navigator helm chart

`helm install --name=application-navigator --namespace=prism --set env.kubeEnv=minikube --set service.port=9080 --set service.targetPort=9080 --set service.scheme=HTTP --set env.target=http://localhost:9080 helm-chart-prism/stable/prism`

To find the Application Navigator UI port, locate the prism service.  The application navigator port is the external port match for the internal port 3000.  

## Install Sample

The list of applications in the Application Navigator UI will be empty at first.  A quick way to get started will be to install a sample.

`kubectl apply -f samples/crds`

`helm install --name=stocktrader samples/stocktraderChart`

## Uninstall

helm delete application-navigator --purge

## Troubleshooting

If Application Navigator fails to uninstall you may need to delete the following jobs to complete the uninstall: prism-init-post, prism-delete.