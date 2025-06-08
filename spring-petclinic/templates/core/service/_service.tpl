{{- define "spring-petclinic.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .root.serviceName }}
  namespace: {{ required "A namespace must be provided" .namespace }}
  labels:
    app: {{ .root.appName }}
spec:
  type: ClusterIP
  ports:
    - name: http
      port: {{ .root.port }} 
      targetPort: {{ if .root.targetPort }}{{- .root.targetPort -}}{{ else }}{{- .root.port -}}{{ end }}
  selector:
    app: {{ .root.appName }}
{{- end }}