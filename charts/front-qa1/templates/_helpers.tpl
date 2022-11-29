#######################################################
###############        GENERAL       ##################
#######################################################

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "front.fullname" -}}
{{- if ne (.Values.global.projectName | toString) "" -}}
{{- .Values.global.projectName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "front.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "front.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
#######################################################
###############         frontend          ##################
#######################################################


{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "frontend.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.frontend.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "frontend.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "frontend.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "frontend.nodeselector" -}}
{{- if .Values.frontend.nodeSelector -}}
  nodeSelector: {{ toYaml .Values.frontend.nodeSelector | nindent 8 }}
{{ end }}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "frontend.affinity" -}}
{{- end -}}

{{/*
Sets the frontend toleration for pod placement
*/}}
{{- define "frontend.tolerations" -}}
  {{- if .Values.frontend.tolerations }}
      tolerations:
        {{ tpl .Values.frontend.tolerations . | nindent 8 | trim }}
  {{- end }}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "frontend.ingress.annotations" -}}
  {{- if .Values.frontend.ingress.annotations }}
  annotations:
    {{- tpl .Values.frontend.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "frontend.resources" -}}
  {{- if .Values.frontend.resources -}}
          resources:
{{ toYaml .Values.frontend.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}


{{/*
Set's up configmap mounts if this isn't a dev deployment and the user
defined a custom configuration.  Additionally iterates over any
extra volumes the user may have specified (such as a secret with TLS).
*/}}
{{- define "frontend.volumes" -}}
  {{ if .Values.frontend.extraVolumes }}
      volumes:
    {{- range .Values.frontend.extraVolumes }}
      - name: {{ .name }}
        {{ .type }}:
        {{- if (eq .type "configMap") }}
          name: {{ .name }}
        {{- else if (eq .type "secret") }}
          secretName: {{ .name }}
        {{- end }}
    {{- end }}
  {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container
based on the mode configured.
*/}}
{{- define "frontend.mounts" -}}
  {{ if .Values.frontend.extraVolumes }}
          volumeMounts:
    {{- range .Values.frontend.extraVolumes }}
          - name: {{ .name }}
            readOnly: true
            mountPath: {{ .path | default "/mnt" }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "frontend.hostAliases" -}}
  {{- if .Values.frontend.hostAliases -}}
      hostAliases:
    {{- tpl .Values.frontend.hostAliases . | nindent 6 }}
  {{ else }}
  {{ end }}
{{- end -}}


