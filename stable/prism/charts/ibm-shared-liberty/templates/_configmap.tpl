{{- /*
Shared Liberty Templates (SLT)

ConfigMap templates:
  - slt.configmap

Usage of "slt.configmap.*" requires the following line be include at 
the begining of template:
{{- include "slt.config.init" (list . "slt.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- define "slt.configmap" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{ include "slt.utils.isMonitoringEnabled" (list $root) }}
---
# SLT: 'slt.configmap' from templates/_configmap.tpl
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "slt.utils.fullname" (list $root) }}
  labels:
    chart: "{{ $root.Chart.Name }}-{{ $root.Chart.Version | replace "+" "_" }}"
    app: {{ include "slt.utils.fullname" (list $root) }}
    release: "{{ $root.Release.Name }}"
    heritage: "{{ $root.Release.Service }}"
data:
###############################################################################
#  Liberty Fabric
###############################################################################
  include-configmap.xml: |-
    <server>
      <include optional="true" location="/etc/wlp/configmap/server.xml"/>
      <include optional="true" location="/etc/wlp/configmap/https-endpoint.xml"/>
      <include optional="true" location="/etc/wlp/configmap/https-http-endpoint.xml"/>
      <include optional="true" location="/etc/wlp/configmap/ssl.xml"/>
      <include optional="true" location="/etc/wlp/configmap/health.xml"/>
      <include optional="true" location="/etc/wlp/configmap/monitoring.xml"/>
    </server>

  server.xml: |-
    <server>
      <!-- Customize the running configuration. -->
    </server>

  {{- if $root.Values.isMonitoringEnabled }}
  https-http-endpoint.xml: |-
    <server>
      <httpEndpoint id="defaultHttpEndpoint" host="*" httpsPort="${env.HTTPENDPOINT_HTTPSPORT}" httpPort="{{ $root.slt.httpService.nonSecurePort }}" />
    </server>
  {{- else }}
  https-endpoint.xml: |-
    <server>
      <httpEndpoint id="defaultHttpEndpoint" host="*" httpsPort="${env.HTTPENDPOINT_HTTPSPORT}" />
    </server>
  {{- end }}

  ssl.xml: |-
    <server>
      <featureManager>
        <feature>ssl-1.0</feature>
      </featureManager>
    </server>

{{ if $root.Values.microprofile.health.enabled }}
  health.xml: |-
    <server>
      <featureManager>
        <feature>mpHealth-1.0</feature>
      </featureManager>
    </server>
{{ end }}

{{ if and $root.Values.isMonitoringEnabled }}
  monitoring.xml: |-
    <server>
      <featureManager>
        <feature>mpMetrics-1.1</feature>
        <feature>monitor-1.0</feature>
      </featureManager>
      <mpMetrics authentication="false" />
    </server>
{{ end }}

{{- end -}}

