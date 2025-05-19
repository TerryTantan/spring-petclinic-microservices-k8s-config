{{- define "spring-petclinic.ingress-rule" }}
{{- if or (eq .namespace "prod") (eq .namespace "production") -}}
- host: {{ .root.host }}
{{- else -}}
- host: {{ required "A namespace must be provided" .namespace }}.{{ .root.host }}
{{- end }}
  http:
    paths:
    - path: {{ .root.path }}
      pathType: Prefix
      backend:
        service:
          name: {{ .root.service.name }}
          port:
            number: {{ .root.service.port }}
{{- end }}