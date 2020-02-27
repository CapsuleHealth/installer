{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stash.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stash.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "stash.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "stash.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "stash.labels" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app: "{{ template "stash.name" . }}"
release: {{ .Release.Name | quote}}
heritage: "{{ .Release.Service }}"
{{- end -}}

{{- define "stash.gen-certs" -}}
{{- if .Values.apiserver.servingCerts.generate }}
{{- $ca := genCA "ca" 3650 }}
{{- $cn := include "stash.fullname" . -}}
{{- $altName1 := printf "%s.%s" $cn .Release.Namespace }}
{{- $altName2 := printf "%s.%s.svc" $cn .Release.Namespace }}
{{- $server := genSignedCert $cn nil (list $altName1 $altName2) 3650 $ca }}
{{- $caCrt := b64enc $ca.Cert }}
{{- $serverCrt := b64enc $server.Cert }}
{{- $serverKey := b64enc $server.Key }}
caBundle: {{ $caCrt }}
tlsCrt: {{ $serverCrt }}
tlsKey: {{ $serverKey }}
{{- else }}
{{- $caCrt := required "Required when apiserver.servingCerts.generate is false" .Values.apiserver.servingCerts.caCrt }}
{{- $serverCrt := required "Required when apiserver.servingCerts.generate is false" .Values.apiserver.servingCerts.serverCrt }}
{{- $serverKey := required "Required when apiserver.servingCerts.generate is false" .Values.apiserver.servingCerts.serverKey }}
caBundle: {{ $caCrt }}
tlsCrt: {{ $serverCrt }}
tlsKey: {{ $serverKey }}
{{- end }}
{{- end -}}
