{{/*
Expand the name of the chart.
*/}}
{{- define "scenario-2.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "scenario-2.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "scenario-2.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "scenario-2.labels" -}}
helm.sh/chart: {{ include "scenario-2.chart" . }}
{{ include "scenario-2.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: devopsbeerer
scenario: {{ .Chart.Name }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "scenario-2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "scenario-2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common ingress template
*/}}
{{- define "scenario-2.ingress" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if $config.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $config.name }}
  labels:
    {{- include "scenario-2.labels" $root | nindent 4 }}
    app.kubernetes.io/component: {{ $component }}
  annotations:
    {{- toYaml $config.annotations | nindent 4 }}
spec:
  ingressClassName: {{ $config.className }}
  tls:
    - hosts:
        - {{ $config.host }}
      secretName: {{ $component }}-tls
  rules:
    - host: {{ $config.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $config.name }}
                port:
                  number: {{ $config.servicePort }}
{{- end }}
{{- end }}

{{/*
Common security context
*/}}
{{- define "scenario-2.podSecurityContext" -}}
runAsNonRoot: {{ .Values.security.podSecurityContext.runAsNonRoot }}
seccompProfile:
  type: {{ .Values.security.podSecurityContext.seccompProfile.type }}
{{- end }}

{{/*
Common container security context
*/}}
{{- define "scenario-2.containerSecurityContext" -}}
allowPrivilegeEscalation: {{ .Values.security.containerSecurityContext.allowPrivilegeEscalation }}
readOnlyRootFilesystem: {{ .Values.security.containerSecurityContext.readOnlyRootFilesystem }}
runAsNonRoot: {{ .Values.security.containerSecurityContext.runAsNonRoot }}
capabilities:
  drop:
    {{- toYaml .Values.security.containerSecurityContext.capabilities.drop | nindent 4 }}
seccompProfile:
  type: {{ .Values.security.containerSecurityContext.seccompProfile.type }}
{{- end }}

{{/*
Common DNS configuration
*/}}
{{- define "scenario-2.dnsConfig" -}}
dnsPolicy: ClusterFirst
dnsConfig:
  options:
    {{- toYaml .Values.dnsConfig.options | nindent 4 }}
{{- end }}

{{/*
Generate API URLs based on environment
*/}}
{{- define "scenario-2.apiUrl" -}}
{{- if eq .Values.global.environment "development" -}}
https://{{ .Values.api.ingress.host }}
{{- else -}}
https://api.scenario2.{{ .Values.global.domain }}
{{- end -}}
{{- end }}

{{/*
Generate SSO URLs based on environment
*/}}
{{- define "scenario-2.ssoPublicUrl" -}}
{{- if eq .Values.global.environment "development" -}}
{{ .Values.sso.publicUrl }}
{{- else -}}
https://sso.{{ .Values.global.domain }}
{{- end -}}
{{- end }}