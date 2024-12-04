{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper {! cookiecutter.chart_title !} image name
*/}}
{{- define "{! cookiecutter.chart_name !}.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "{! cookiecutter.chart_name !}.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
 */}}
{{- define "{! cookiecutter.chart_name !}.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{% if cookiecutter.use_db != "none" -%}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "{! cookiecutter.chart_name !}.{! cookiecutter.use_db !}.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "{! cookiecutter.use_db !}" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "{! cookiecutter.chart_name !}.database.host" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled }}
    {{- if eq .Values.{! cookiecutter.use_db !}.architecture "replication" }}
        {{- printf "%s-primary" (include "{! cookiecutter.chart_name !}.{! cookiecutter.use_db !}.fullname" .) | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "{! cookiecutter.chart_name !}.{! cookiecutter.use_db !}.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "{! cookiecutter.chart_name !}.database.port" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled }}
    {{- print .Values.{! cookiecutter.use_db !}.primary.service.ports.{! cookiecutter.use_db !} -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database database name
*/}}
{{- define "{! cookiecutter.chart_name !}.database.name" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled }}
    {{- printf "%s" .Values.{! cookiecutter.use_db !}.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "{! cookiecutter.chart_name !}.database.user" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled }}
    {{- printf "%s" .Values.{! cookiecutter.use_db !}.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database secret name
*/}}
{{- define "{! cookiecutter.chart_name !}.database.secretName" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled }}
    {{- if .Values.{! cookiecutter.use_db !}.auth.existingSecret -}}
        {{- printf "%s" .Values.{! cookiecutter.use_db !}.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "{! cookiecutter.chart_name !}.{! cookiecutter.use_db !}.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -}}
{{- else -}}
    {{- printf "%s-externaldb" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database password secret key
*/}}
{{- define "{! cookiecutter.chart_name !}.database.secretPasswordKey" -}}
{{- if .Values.{! cookiecutter.use_db !}.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{%- if cookiecutter.use_db == "postgresql" %}
{{/*
Return the Database password secret key
*/}}
{{- define "{! cookiecutter.chart_name !}.database.secretPostgresPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "postgres-password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- default "postgres-password" .Values.externalDatabase.existingSecretPostgresPasswordKey }}
    {{- else -}}
        {{- print "postgres-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
{% endif -%}

{{/*
Return whether Database uses password authentication or not
*/}}
{{- define "{! cookiecutter.chart_name !}.database.auth.enabled" -}}
{{- if or (and .Values.{! cookiecutter.use_db !}.enabled .Values.{! cookiecutter.use_db !}.auth.enabled) (and (not .Values.{! cookiecutter.use_db !}.enabled) (or .Values.externalDatabase.password .Values.externalDatabase.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Database is enabled or not.
*/}}
{{- define "{! cookiecutter.chart_name !}.database.enabled" -}}
{{- if or .Values.{! cookiecutter.use_db !}.enabled (and (not .Values.{! cookiecutter.use_db !}.enabled) (ne .Values.externalDatabase.host "localhost")) }}
    {{- true -}}
{{- end -}}
{{- end -}}
{% endif -%}

{%- if cookiecutter.use_cache %}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Return the Redis hostname
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s-master" (include "{! cookiecutter.chart_name !}.redis.fullname" .) -}}
{{- else -}}
    {{- print .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis port
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.port" -}}
{{- if .Values.redis.enabled -}}
    {{- print .Values.redis.master.service.ports.redis -}}
{{- else -}}
    {{- print .Values.externalRedis.port  -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "{! cookiecutter.chart_name !}.redis.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-redis" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret key
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- print "redis-password" -}}
{{- else -}}
    {{- if .Values.externalRedis.existingSecret -}}
        {{- default "redis-password" .Values.externalRedis.existingSecretPasswordKey }}
    {{- else -}}
        {{- print "redis-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis uses password authentication or not
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis is enabled or not.
*/}}
{{- define "{! cookiecutter.chart_name !}.redis.enabled" -}}
{{- if or .Values.redis.enabled (and (not .Values.redis.enabled) (ne .Values.externalRedis.host "localhost")) }}
    {{- true -}}
{{- end -}}
{{- end -}}
{% endif -%}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "{! cookiecutter.chart_name !}.initContainers.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{- define "{! cookiecutter.chart_name !}.initContainers.volumePermissions" -}}
- name: volume-permissions
  image: "{{ include "{! cookiecutter.chart_name !}.initContainers.volumePermissions.image" . }}"
  imagePullPolicy: {{ .Values.defaultInitContainers.volumePermissions.image.pullPolicy | quote }}
  command:
    - /bin/bash
  args:
    - -ec
    - |
      mkdir -p {{ .Values.persistence.mountPath }}
      {{- if eq ( toString ( .Values.defaultInitContainers.volumePermissions.containerSecurityContext.runAsUser )) "auto" }}
      find {{ .Values.persistence.mountPath }} -mindepth 0 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | xargs -r chown -R $(id -u):$(id -G | cut -d " " -f2)
      {{- else }}
      find {{ .Values.persistence.mountPath }} -mindepth 0 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | xargs -r chown -R {{ .Values.containerSecurityContext.runAsUser }}:{{ .Values.podSecurityContext.fsGroup }}
      {{- end }}
  {{- if .Values.defaultInitContainers.volumePermissions.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.volumePermissions.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.volumePermissions.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.volumePermissions.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.volumePermissions.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.volumePermissions.resourcesPreset) | nindent 4 }}
  {{- end }}
  volumeMounts:
    - name: data
      mountPath: {{ .Values.persistence.mountPath }}
      subPath: {{ .Values.persistence.subPath }}
{{- end -}}

{{/*
Return the proper image name (for the default init containers)
*/}}
{{- define "{! cookiecutter.chart_name !}.initContainers.wait.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.defaultInitContainers.wait.image "global" .Values.global) }}
{{- end -}}

{{/*
Init container definition for waiting for Container to be ready
*/}}

{{- define "{! cookiecutter.chart_name !}.initContainers.wait" -}}
- name: wait-for-it
  image: {{ include "{! cookiecutter.chart_name !}.initContainers.wait.image" . }}
  imagePullPolicy: {{ .Values.defaultInitContainers.wait.image.pullPolicy }}
  {{- if .Values.defaultInitContainers.wait.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.wait.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.wait.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.wait.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.wait.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.wait.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
    - -ec
    - |
      #!/bin/bash

      set -o errexit
      set -o nounset
      set -o pipefail

      {{- if .Values.waitForInitContainer.config.services -}}
      wait-for-it \
        {{- range $service := .Values.waitForInitContainer.config.services }}
        --service {{ $service.url }} \
        {{- end }}
        {{- if .Values.waitForInitContainer.config.timeout }}
        --timeout {{ .Values.waitForInitContainer.config.timeout }} \
        {{- end -}}
        {{- if .Values.waitForInitContainer.config.parallel }}
        --parallel \
        {{- end -}}
        {{- if .Values.waitForInitContainer.config.message }}
        -- echo "{{ .Values.waitForInitContainer.config.message }}"
        {{- end -}}
      {{- else -}}
      echo "No services to wait for."
      {{- end -}}

  env:
    - name: BITNAMI_DEBUG
      value: {{ ternary "true" "false" (or .Values.image.debug .Values.diagnosticMode.enabled) | quote }}
{{- end -}}
