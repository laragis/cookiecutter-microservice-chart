{{ "{{" }}/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/{{ "}}" }}

{{ "{{" }}/* vim: set filetype=mustache: */{{ "}}" }}

{{ "{{" }}/*
Return the proper {{ cookiecutter.chart_title }} image name
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.image" -{{ "}}" }}
{{ "{{" }}- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the proper image name (for the init container volume-permissions image)
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.volumePermissions.image" -{{ "}}" }}
{{ "{{" }}- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the proper Docker Image Registry Secret Names
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.imagePullSecrets" -{{ "}}" }}
{{ "{{" }}- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Create the name of the service account to use
 */{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.serviceAccountName" -{{ "}}" }}
{{ "{{" }}- if .Values.serviceAccount.create -{{ "}}" }}
    {{ "{{" }} default (include "common.names.fullname" .) .Values.serviceAccount.name {{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }} default "default" .Values.serviceAccount.name {{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the WordPress configuration secret
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.configSecretName" -{{ "}}" }}
{{ "{{" }}- if .Values.existingWordPressConfigurationSecret -{{ "}}" }}
    {{ "{{" }}- printf "%s" (tpl .Values.existingWordPressConfigurationSecret $) -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s-configuration" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return true if a secret object should be created for WordPress configuration
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.createConfigSecret" -{{ "}}" }}
{{ "{{" }}- if and .Values.wordpressConfiguration (not .Values.existingWordPressConfigurationSecret) {{ "}}" }}
    {{ "{{" }}- true -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the WordPress Secret Name
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.secretName" -{{ "}}" }}
{{ "{{" }}- if .Values.existingSecret {{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.existingSecret -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s" (include "common.names.fullname" .) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{% if cookiecutter.use_db != "none" -%}
{{ "{{" }}/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.{{ cookiecutter.use_db }}.fullname" -{{ "}}" }}
{{ "{{" }}- include "common.names.dependency.fullname" (dict "chartName" "{{ cookiecutter.use_db }}" "chartValues" .Values.postgresql "context" $) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}/*
Return the DB Hostname
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.databaseHost" -{{ "}}" }}
{{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.enabled {{ "}}" }}
    {{ "{{" }}- if eq .Values.{{ cookiecutter.use_db }}.architecture "replication" {{ "}}" }}
        {{ "{{" }}- printf "%s-primary" (include "{{ cookiecutter.chart_name }}.{{ cookiecutter.use_db }}.fullname" .) | trunc 63 | trimSuffix "-" -{{ "}}" }}
    {{ "{{" }}- else -{{ "}}" }}
        {{ "{{" }}- printf "%s" (include "{{ cookiecutter.chart_name }}.{{ cookiecutter.use_db }}.fullname" .) -{{ "}}" }}
    {{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.externalDatabase.host -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the DB Port
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.databasePort" -{{ "}}" }}
{{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.enabled {{ "}}" }}
    {{ "{{" }}- printf "3306" -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%d" (.Values.externalDatabase.port | int ) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the DB Database Name
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.databaseName" -{{ "}}" }}
{{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.enabled {{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.{{ cookiecutter.use_db }}.auth.database -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.externalDatabase.database -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the DB User
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.databaseUser" -{{ "}}" }}
{{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.enabled {{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.{{ cookiecutter.use_db }}.auth.username -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.externalDatabase.user -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the DB Secret Name
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.databaseSecretName" -{{ "}}" }}
{{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.enabled {{ "}}" }}
    {{ "{{" }}- if .Values.{{ cookiecutter.use_db }}.auth.existingSecret -{{ "}}" }}
        {{ "{{" }}- printf "%s" .Values.{{ cookiecutter.use_db }}.auth.existingSecret -{{ "}}" }}
    {{ "{{" }}- else -{{ "}}" }}
        {{ "{{" }}- printf "%s" (include "{{ cookiecutter.chart_name }}.{{ cookiecutter.use_db }}.fullname" .) -{{ "}}" }}
    {{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- else if .Values.externalDatabase.existingSecret -{{ "}}" }}
    {{ "{{" }}- include "common.tplvalues.render" (dict "value" .Values.externalDatabase.existingSecret "context" $) -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s-externaldb" (include "common.names.fullname" .) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the DB password Secret Key
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.database.secretPasswordKey" -{{ "}}" }}
{{ "{{" }}- if .Values.postgresql.enabled -{{ "}}" }}
    {{ "{{" }}- print "password" -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- if .Values.externalDatabase.existingSecret -{{ "}}" }}
        {{ "{{" }}- default "password" .Values.externalDatabase.existingSecretPasswordKey {{ "}}" }}
    {{ "{{" }}- else -{{ "}}" }}
        {{ "{{" }}- print "password" -{{ "}}" }}
    {{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{% endif -%}

{%- if cookiecutter.use_cache %}
{{ "{{" }}/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.redis.fullname" -{{ "}}" }}
{{ "{{" }}- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the Redis hostname
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.redis.host" -{{ "}}" }}
{{ "{{" }}- if .Values.redis.enabled -{{ "}}" }}
    {{ "{{" }}- printf "%s-master" (include "{{ cookiecutter.chart_name }}.redis.fullname" .) -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- print .Values.externalRedis.host -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the Redis port
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.redis.port" -{{ "}}" }}
{{ "{{" }}- if .Values.redis.enabled -{{ "}}" }}
    {{ "{{" }}- print .Values.redis.master.service.ports.redis -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- print .Values.externalRedis.port  -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the Redis secret name
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.redis.secretName" -{{ "}}" }}
{{ "{{" }}- if .Values.redis.enabled {{ "}}" }}
    {{ "{{" }}- if .Values.redis.auth.existingSecret {{ "}}" }}
        {{ "{{" }}- printf "%s" .Values.redis.auth.existingSecret -{{ "}}" }}
    {{ "{{" }}- else -{{ "}}" }}
        {{ "{{" }}- printf "%s" (include "{{ cookiecutter.chart_name }}.redis.fullname" .) -{{ "}}" }}
    {{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- else if .Values.externalRedis.existingSecret {{ "}}" }}
    {{ "{{" }}- printf "%s" .Values.externalRedis.existingSecret -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- printf "%s-redis" (include "common.names.fullname" .) -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}

{{ "{{" }}/*
Return the Redis secret key
*/{{ "}}" }}
{{ "{{" }}- define "{{ cookiecutter.chart_name }}.redis.secretPasswordKey" -{{ "}}" }}
{{ "{{" }}- if .Values.redis.enabled -{{ "}}" }}
    {{ "{{" }}- print "redis-password" -{{ "}}" }}
{{ "{{" }}- else -{{ "}}" }}
    {{ "{{" }}- if .Values.externalRedis.existingSecret -{{ "}}" }}
        {{ "{{" }}- default "redis-password" .Values.externalRedis.existingSecretPasswordKey {{ "}}" }}
    {{ "{{" }}- else -{{ "}}" }}
        {{ "{{" }}- print "redis-password" -{{ "}}" }}
    {{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{{ "{{" }}- end -{{ "}}" }}
{% endif -%}
