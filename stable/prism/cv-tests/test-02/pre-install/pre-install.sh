#!/bin/bash

# Pre-install script REQUIRED ONLY IF additional setup is required prior to
# helm install for this test path.
#
# For example, a secret is required for chart installation
# it will need to be created prior to helm install.
#
# Parameters :
#   -c <chartReleaseName>, the name of the release used to install the helm chart
#
# Pre-req environment: authenticated to cluster & kubectl cli install / setup complete

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }



DEFAULT_PULL_REG="wasliberty-liber8-docker.artifactory.swg-devops.com"
PULL_REG=${DEFAULT_PULL_REG}
PULL_USER=${FUNC_ID}
PULL_PWD=${FUNC_PASS}

ENCODED_LOGIN=`echo -n "${PULL_USER}:${PULL_PWD}" | base64 -w 0`
REGISTRY_AUTH=`echo -n "{\"auths\": {\"${PULL_REG}\": {\"auth\": \"${ENCODED_LOGIN}\"}}}" | base64 -w 0`

echo "Creating Secret wasliberty-liber8-docker-secret"
echo "{
    \"apiVersion\": \"v1\",
    \"kind\": \"Secret\",
    \"metadata\": {
        \"name\": \"wasliberty-liber8-docker-secret\",
        \"namespace\": \"prism\",
    },
    \"type\": \"kubernetes.io/dockerconfigjson\",
    \"data\": {
        \".dockerconfigjson\": \"${REGISTRY_AUTH}\"
    }
}" | kubectl apply -n $NAMESPACE -f -
