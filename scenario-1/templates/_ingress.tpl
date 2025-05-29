{{/*
Common ingress template
*/}}
{{- define "scenario-1.ingress" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if $config.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $config.name | default (printf "%s-%s" $root.Release.Name $component) }}
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "scenario-1.labels" $root | nindent 4 }}
    app.kubernetes.io/component: {{ $component }}
  {{- if $config.annotations }}
  annotations:
    {{- toYaml $config.annotations | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ $config.className | default "nginx" }}
  {{- if $config.host }}
  tls:
    - hosts:
        - {{ $config.host }}
      secretName: {{ $component }}-tls
  {{- end }}
  rules:
    - host: {{ $config.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $config.serviceName | default (printf "%s-%s" $root.Release.Name $component) }}
                port:
                  number: {{ $config.servicePort }}
{{- end }}
{{- end }}
