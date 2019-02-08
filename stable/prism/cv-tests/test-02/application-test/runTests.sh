#!/bin/bash

# Exit when failures occur (including unset variables)
set -o errexit
set -o nounset
set -o pipefail

# Verify pre-req environment
command -v kubectl > /dev/null 2>&1 || { echo "kubectl pre-req is missing."; exit 1; }

[[ `dirname $0 | cut -c1` = '/' ]] && appTestDir=`dirname $0`/ || appTestDir=`pwd`/`dirname $0`/

# Process parameters notify of any unexpected
while test $# -gt 0; do
	[[ $1 =~ ^-c|--chartrelease$ ]] && { chartRelease="$2"; shift 2; continue; };
	echo "Parameter not recognized: $1, ignored"
	shift
done
: "${chartRelease:="default"}"

echo "Testing nodeport:"

# Wait for 15x10=150 seconds until the ingress IP is available
i=0
printf 'Waiting to retrieve the nodeport'
node_ip=kubectl get pods --namespace prism --selector=app=prism -o jsonpath='{.items[0].spec.nodeName}'
node_port=kubectl get svc  --namespace prism --selector=app=prism -o jsonpath='{.items[0].spec.ports[?(@.name=="http")].nodePort}'

until [ -n "$node_port" ]; do
    printf '.'
    node_port=kubectl get svc  --namespace prism --selector=app=prism -o jsonpath='{.items[0].spec.ports[?(@.name=="http")].nodePort}'
    i=$((i+1))
    if [ $i -gt 10 ]
    then
      printf " Could not get nodeport\n"
      kubectl get svc  --namespace prism --selector=app=prism
      exit 2
    fi
    sleep 15
done

# Hit the ingress endpoint
# NOTE: /test is setup in the test's values.yaml -> .Values.ingress.path
url=http://$node_ip:$node_port/
printf "\nChecking if the nodeport endpoint '$url' is available\n"
curl -k --connect-timeout 180 --output /dev/null --silent --head --fail $url
_testResult=$?

if [ $_testResult -eq 0 ]; then
  echo "SUCCESS - Nodeport endpoint is available"
else
  echo "FAIL - Could not reach ingress endpoint"
fi
exit $_testResult
