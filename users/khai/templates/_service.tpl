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
      targetPort: {{ .root.port }}
  selector:
    app: {{ .root.appName }}
{{- end }}
