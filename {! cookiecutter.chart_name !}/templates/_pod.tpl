{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Pod Spec
*/}}
{{- define "{! cookiecutter.chart_name !}.pod" -}}
{{- include "{! cookiecutter.chart_name !}.imagePullSecrets" . | nindent 6 }}
automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
{{- if .Values.hostAliases }}
# yamllint disable rule:indentation
hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.hostAliases "context" $) | nindent 8 }}
# yamllint enable rule:indentation
{{- end }}
{{- if .Values.affinity }}
affinity: {{- include "common.tplvalues.render" (dict "value" .Values.affinity "context" $) | nindent 8 }}
{{- else }}
affinity:
  podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAffinityPreset "customLabels" $podLabels "context" $) | nindent 10 }}
  podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAntiAffinityPreset "customLabels" $podLabels "context" $) | nindent 10 }}
  nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.nodeAffinityPreset.type "key" .Values.nodeAffinityPreset.key "values" .Values.nodeAffinityPreset.values) | nindent 10 }}
{{- end }}
{{- if .Values.nodeSelector }}
nodeSelector: {{- include "common.tplvalues.render" (dict "value" .Values.nodeSelector "context" $) | nindent 8 }}
{{- end }}
{{- if .Values.tolerations }}
tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.tolerations "context" $) | nindent 8 }}
{{- end }}
{{- if .Values.topologySpreadConstraints }}
topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.topologySpreadConstraints "context" .) | nindent 8 }}
{{- end }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- end }}
{{- if .Values.schedulerName }}
schedulerName: {{ .Values.schedulerName | quote }}
{{- end }}
{{- if .Values.podSecurityContext.enabled }}
securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.podSecurityContext "context" $) | nindent 8 }}
{{- end }}
serviceAccountName: {{ include "{! cookiecutter.chart_name !}.serviceAccountName" .}}
{{- if .Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
initContainers:
  {{- if .Values.defaultInitContainers.wait.enabled }}
  {{- include "{! cookiecutter.chart_name !}.initContainers.wait" . | nindent 8 }}
  {{- end }}
  {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
  {{- include "{! cookiecutter.chart_name !}.initContainers.volumePermissions" . | nindent 8 }}
  {{- end }}
  {{- if .Values.initContainers }}
  {{- include "common.tplvalues.render" (dict "value" .Values.initContainers "context" $) | nindent 8 }}
  {{- end }}
containers:
  - name: {! cookiecutter.image_name !}
    image: {{ include "{! cookiecutter.chart_name !}.image" . }}
    imagePullPolicy: {{ .Values.image.pullPolicy | quote }}
    {{- if .Values.containerSecurityContext.enabled }}
    securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.containerSecurityContext "context" $) | nindent 12 }}
    {{- end }}
    {{- if .Values.diagnosticMode.enabled }}
    command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 12 }}
    {{- else if .Values.command }}
    command: {{- include "common.tplvalues.render" ( dict "value" .Values.command "context" $) | nindent 12 }}
    {{- end }}
    {{- if .Values.diagnosticMode.enabled }}
    args: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.args "context" $) | nindent 12 }}
    {{- else if .Values.args }}
    args: {{- include "common.tplvalues.render" ( dict "value" .Values.args "context" $) | nindent 12 }}
    {{- end }}
    env:
      - name: BITNAMI_DEBUG
        value: {{ ternary "true" "false" (or .Values.image.debug .Values.diagnosticMode.enabled) | quote }}
      {% if cookiecutter.use_db != "none" -%}
      {{- if include "{! cookiecutter.chart_name !}.database.enabled" . }}
      - name: DB_HOST
        value: {{ include "{! cookiecutter.chart_name !}.database.host" . }}
      - name: DB_PORT
        value: {{ include "{! cookiecutter.chart_name !}.database.port" . | quote }}
      - name: DB_DATABASE
        value: {{ include "{! cookiecutter.chart_name !}.database.name" . }}
      - name: DB_USERNAME
        value: {{ include "{! cookiecutter.chart_name !}.database.user" . }}
      {{- if (include "{! cookiecutter.chart_name !}.database.auth.enabled" .) }}
      - name: DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: {{ include "{! cookiecutter.chart_name !}.database.secretName" . }}
            key: {{ include "{! cookiecutter.chart_name !}.database.secretPasswordKey" . }}
      {{- end }}
      {{- end }}
      {% endif -%}
      {% if cookiecutter.use_cache -%}
      {{- if include "{! cookiecutter.chart_name !}.redis.enabled" . }}
      - name: REDIS_HOST
        value: {{ include "{! cookiecutter.chart_name !}.redis.host" . }}
      - name: REDIS_PORT
        value: {{ include "{! cookiecutter.chart_name !}.redis.port" . | quote }}
      {{- if (include "{! cookiecutter.chart_name !}.redis.auth.enabled" .) }}
      - name: REDIS_PASSWORD
        valueFrom:
          secretKeyRef:
            name: {{ include "{! cookiecutter.chart_name !}.redis.secretName" . }}
            key: {{ include "{! cookiecutter.chart_name !}.redis.secretPasswordKey" . }}
      {{- end }}
      {{- end }}
      {% endif -%}
      {{- if .Values.extraEnvVars }}
      {{- include "common.tplvalues.render" (dict "value" .Values.extraEnvVars "context" $) | nindent 12 }}
      {{- end }}
    envFrom:
      {{- if .Values.extraEnvVarsCM }}
      - configMapRef:
          name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsCM "context" $) }}
      {{- end }}
      {{- if .Values.extraEnvVarsSecret }}
      - secretRef:
          name: {{ include "common.tplvalues.render" (dict "value" .Values.extraEnvVarsSecret "context" $) }}
      {{- end }}
    ports:
      {{- if .Values.containerPorts.http }}
      - name: http
        containerPort: {{ .Values.containerPorts.http }}
      {{- end }}
      {{- if .Values.containerPorts.https }}
      - name: https
        containerPort: {{ .Values.containerPorts.https }}
      {{- end }}
      {{- if .Values.extraContainerPorts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.extraContainerPorts "context" $) | nindent 12 }}
      {{- end }}
    {{- if .Values.resources }}
    resources: {{- toYaml .Values.resources | nindent 12 }}
    {{- else if ne .Values.resourcesPreset "none" }}
    resources: {{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) | nindent 12 }}
    {{- end }}
    volumeMounts:
      {{- if and .Values.persistence.enabled .Values.persistence.mountPath }}
      - name: data
        mountPath: {{ .Values.persistence.mountPath }}
        subPath: {{ .Values.persistence.subPath }}
      {{- end }}
      {{- if .Values.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.extraVolumeMounts "context" $) | nindent 12 }}
      {{- end }}
    {{- if not .Values.diagnosticMode.enabled }}
    {{- if .Values.customStartupProbe }}
    startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customStartupProbe "context" $) | nindent 12 }}
    {{- else if .Values.startupProbe.enabled }}
    startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.startupProbe "enabled") "context" $) | nindent 12 }}
    {{- end }}
    {{- if .Values.customLivenessProbe }}
    livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customLivenessProbe "context" $) | nindent 12 }}
    {{- else if .Values.livenessProbe.enabled }}
    livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.livenessProbe "enabled") "context" $) | nindent 12 }}
    {{- end }}
    {{- if .Values.customReadinessProbe }}
    readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.customReadinessProbe "context" $) | nindent 12 }}
    {{- else if .Values.readinessProbe.enabled }}
    readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.readinessProbe "enabled") "context" $) | nindent 12 }}
    {{- end }}
    {{- end }}
    {{- if .Values.lifecycleHooks }}
    lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.lifecycleHooks "context" $) | nindent 12 }}
    {{- end }}
  {{- if .Values.sidecars }}
  {{- include "common.tplvalues.render" (dict "value" .Values.sidecars "context" $) | nindent 8 }}
  {{- end }}
volumes:
  - name: data
    {{- if .Values.persistence.enabled }}
    persistentVolumeClaim:
      claimName: {{ .Values.persistence.existingClaim | default (include "common.names.fullname" .) }}
    {{- else }}
    emptyDir: {}
    {{- end }}
  {{- if .Values.extraVolumes }}
  {{- include "common.tplvalues.render" (dict "value" .Values.extraVolumes "context" $) | nindent 8 }}
  {{- end }}
{{- if .Values.extraPodSpec }}
{{- include "common.tplvalues.render" (dict "value" .Values.extraPodSpec "context" $) | nindent 6 }}
{{- end }}
{{- end -}}