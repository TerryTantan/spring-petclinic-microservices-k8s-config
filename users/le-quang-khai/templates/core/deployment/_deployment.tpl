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
          {{- $imageName := "" }}
          {{- $envSuffix := "dev" }}
          {{- if eq .namespace "staging" }}
            {{- $envSuffix = "staging" }}
          {{- end }}
          {{- $serviceKey := print .root.appName "-" $envSuffix }}
          {{- if and .image.names (index .image.names $serviceKey) }}
            {{- $imageName = index .image.names $serviceKey }}
          {{- else }}
            {{- $imageName = printf "%s%s%s" (and (not (empty .image.repository)) (not (contains "/" .root.image.name)) | ternary (print .image.repository "/") "") .root.image.name (and (not (empty .image.repository)) (not (contains "/" .root.image.name)) | ternary (print "-" .namespace) "") }}
          {{- end }}
          image: {{ $imageName }}:{{ required "A tag must be provided" .tag }}
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