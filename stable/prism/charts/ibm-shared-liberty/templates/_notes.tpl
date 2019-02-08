{{- /*
Shared Liberty Templates (SLT)

Notes templates:
  - slt.notes.application.url

Usage of "slt.notes.*" requires the following line be include at 
the begining of template:
{{- include "slt.config.init" (list . "slt.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- define "slt.notes.application.url" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
{{ include "slt.utils.isICP" (list $root) }}

  {{- if $root.Values.isICP }}
+ Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace {{ $root.Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "slt.utils.name" (list $root) }})
  export NODE_IP=$(kubectl get nodes -l proxy=true -o jsonpath="{.items[0].status.addresses[?(@.type==\"Hostname\")].address}")
  echo http://$NODE_IP:$NODE_PORT
  {{- else }}
+ If you are running on IBM Cloud Kubernetes Service, get the application address by running these commands:
  ibmcloud cs workers $(kubectl config current-context)
  export NODE_IP=<Worker node public IP from the first command>
  export NODE_PORT=$(kubectl get --namespace {{ $root.Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "slt.utils.fullname" (list $root) }})
  echo Application Address: http://$NODE_IP:$NODE_PORT

Otherwise, run the following commands:
  export NODE_IP=$(kubectl get nodes -l proxy=true -o jsonpath="{.items[0].status.addresses[?(@.type==\"Hostname\")].address}")
  export NODE_PORT=$(kubectl get --namespace {{ $root.Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "slt.utils.fullname" (list $root) }})
  echo Application Address: http://$NODE_IP:$NODE_PORT

  {{- end }}

{{- end -}}

