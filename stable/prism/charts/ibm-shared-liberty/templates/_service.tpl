{{- /*
Shared Liberty Templates (SLT)

Service templates:
  - slt.service

Usage of "slt.service.*" requires the following line be include at 
the begining of template:
{{- include "slt.config.init" (list . "slt.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- define "slt.service" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{ include "slt.utils.isMonitoringEnabled" (list $root) }}
---
# SLT: 'slt.service' from templates/_service.tpl
apiVersion: v1
kind: Service
metadata:
  name: prism
  labels:
    chart: "{{ $root.Chart.Name }}-{{ $root.Chart.Version }}"
    app: {{ include "slt.utils.fullname" (list $root) }}
    release: "{{ $root.Release.Name }}"
    heritage: "{{ $root.Release.Service }}"
spec:
  type: {{ $root.Values.service.type }}
  ports:
  - port: 3000
    targetPort: 3000
    protocol: TCP
    name: "https"
{{- if eq $root.Values.service.openAPI "enabled" }}
  - port: {{ $root.Values.service.port }}
    targetPort: {{ $root.Values.service.targetPort }}
    protocol: TCP  
    name: "https-api"
{{- end }}
  
  selector:
    app: {{ include "slt.utils.fullname" (list $root) }}
{{- end -}}

{{- define "slt.service.http.clusterip" -}} 
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{ include "slt.utils.isMonitoringEnabled" (list $root) }}
{{- if $root.Values.isMonitoringEnabled }}
---
# SLT: 'slt.service.http.clusterip' from templates/_service.tpl
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/scrape: 'true'
  name: {{ include "slt.utils.servicename" (list $root) | trunc 48 }}-http-clusterip
  labels:
    chart: "{{ $root.Chart.Name }}-{{ $root.Chart.Version }}"
    app: {{ include "slt.utils.fullname" (list $root) }}
    release: "{{ $root.Release.Name }}"
    heritage: "{{ $root.Release.Service }}"
spec:
  ports:
  - port: {{ $root.slt.httpService.nonSecurePort }}
    targetPort: {{ $root.slt.httpService.nonSecurePort }}
    name: {{ $root.slt.httpService.name }}-clusterip
    protocol: TCP
  selector:
    app: {{ include "slt.utils.fullname" (list $root) }}
  type: ClusterIP
{{- end }}
{{- end -}}
