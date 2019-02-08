{{- /*
Shared Liberty Templates (SLT)

Deployment templates:
  - slt.deployment

Usage of "slt.deployment.*" requires the following line be include at 
the begining of template:
{{- include "slt.config.init" (list . "slt.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- define "slt.deployment" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{ include "slt.utils.isOpenShift" (list $root) }}
---
# SLT: 'slt.deployment' from templates/_deployment.tpl
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: prism
  labels:
    chart: "{{ $root.Chart.Name }}-{{ $root.Chart.Version }}"
    app: {{ include "slt.utils.fullname" (list $root) }}
    release: "{{ $root.Release.Name }}"
    heritage: "{{ $root.Release.Service }}"
spec:
  {{ if not $root.Values.autoscaling.enabled -}}
  replicas: {{ $root.Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      app: {{ include "slt.utils.fullname" (list $root) }}
  template:
    metadata:
      labels:
        chart: "{{ $root.Chart.Name }}-{{ $root.Chart.Version }}"
        app: {{ include "slt.utils.fullname" (list $root) }}
        release: "{{ $root.Release.Name }}"
        heritage: "{{ $root.Release.Service }}"
    spec:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 
      volumes:
      {{ if eq $root.Values.env.kubeEnv "icp" }}
      - name: tls
        secret:
          secretName: "{{ $root.Chart.Name }}-certs"
      {{ end }}
      - name: liberty-overrides
        configMap:
          name: {{ include "slt.utils.fullname" (list $root) }}
          items:
          - key: include-configmap.xml
            path: include-configmap.xml
      - name: liberty-config
        configMap:
          name: {{ include "slt.utils.fullname" (list $root) }}
      affinity:
      {{- include "slt.affinity.nodeaffinity" (list $root) | indent 6 }}
      {{/* Prefer horizontal scaling */}}
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - {{ include "slt.utils.fullname" (list $root) }}
                - key: release
                  operator: In
                  values:
                  - {{ $root.Release.Name | quote }}
              topologyKey: kubernetes.io/hostname
      containers:
      - name: nodeapp
        image: "{{ $root.Values.image.repositoryUI }}:{{ $root.Values.image.tag }}"
        imagePullPolicy: {{ $root.Values.image.pullPolicy }}
        env: 
        - name: KUBE_ENV
          value: "{{ $root.Values.env.kubeEnv }}"
        - name: TARGET 
          value: "{{ $root.Values.env.target }}"
        {{ if eq $root.Values.env.kubeEnv "icp" }}
        volumeMounts:
        - name: tls
          mountPath: "/etc/prism/ssl"
          readOnly: true
        {{ end }}
      - name: {{ $root.Chart.Name }}
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
          {{ if $root.Values.microprofile.health.enabled }}
            path: /health
          {{ else }}
            path: /
          {{ end }}
            port: {{ $root.Values.service.targetPort }}
            scheme: {{ $root.Values.service.scheme }}
        image: "{{ $root.Values.image.repository }}:{{ $root.Values.image.tag }}"
        imagePullPolicy: {{ $root.Values.image.pullPolicy }}
        env:
        - name: JVM_ARGS
          value: "{{ $root.Values.env.jvmArgs }}"
        - name: WLP_LOGGING_CONSOLE_FORMAT
          value: {{ $root.Values.logs.consoleFormat }}
        - name: WLP_LOGGING_CONSOLE_LOGLEVEL
          value: {{ $root.Values.logs.consoleLogLevel }}
        - name: WLP_LOGGING_CONSOLE_SOURCE
          value: {{ $root.Values.logs.consoleSource }}
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: HTTPENDPOINT_HTTPSPORT
          value: "{{ $root.Values.service.targetPort }}"
        - name : KEYSTORE_REQUIRED
          value: "true"
        volumeMounts:
        - name: liberty-overrides
          mountPath: /config/configDropins/overrides/include-configmap.xml
          subPath: include-configmap.xml
          readOnly: true
        - name: liberty-config
          mountPath: /etc/wlp/configmap
          readOnly: true
        resources:
          {{- if $root.Values.resources.constraints.enabled }}
          limits:
{{ toYaml $root.Values.resources.limits | indent 12 }}
          requests:
{{ toYaml $root.Values.resources.requests | indent 12 }}
          {{- end }}
      restartPolicy: "Always"
      terminationGracePeriodSeconds: 30
      dnsPolicy: "ClusterFirst"
{{- end -}}

