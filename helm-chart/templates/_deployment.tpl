{{- define "spring-petclinic.deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .root.deploymentName }}
  namespace: {{ required "A namespace must be provided" .namespace }}
  labels:
    app: {{ .root.appName }}
spec:
  replicas: {{ .root.replicas }}
  selector:
    matchLabels:
      app: {{ .root.appName }}
  template:
    metadata:
      labels:
        app: {{ .root.appName }}
    spec:
      containers:
        - name: {{ .root.containerName }}
          image: {{ and (not (empty .imageRepository)) (not (contains "/" .root.image.name)) | ternary (print $.imageRepository "/") "" }}{{ .root.image.name }}:{{ .root.image.tag }}
          ports:
            - containerPort: {{ .root.port }}
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: {{ .profile }} 
          resources:
            requests:
              cpu: 100m
              memory: 32Mi
            limits:
              cpu: 200m
              memory: 512Mi
{{- end }}