{{/*
=============================================================================
Helm Template Helpers
=============================================================================
*/}}

{{/*
Chart name
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
=============================================================================
Cascade helpers
=============================================================================
Only ONE section is used at a time (SC > PV > PVC priority)
*/}}

{{/*
Should PV be created?
*/}}
{{- define "app.pvEnabled" -}}
{{- if or .Values.storageClass.enabled .Values.persistentVolume.enabled }}true{{- end }}
{{- end }}

{{/*
Should PVC be created?
*/}}
{{- define "app.pvcEnabled" -}}
{{- if or .Values.storageClass.enabled .Values.persistentVolume.enabled .Values.persistentVolumeClaim.enabled }}true{{- end }}
{{- end }}

{{/*
Should storage-secret be created?
*/}}
{{- define "app.storageSecretEnabled" -}}
{{- if or .Values.storageClass.enabled .Values.persistentVolume.enabled }}true{{- end }}
{{- end }}

{{/*
=============================================================================
PV name — always "pv-{namespace}"
=============================================================================
*/}}
{{- define "app.pvName" -}}
{{- printf "pv-%s" .Release.Namespace }}
{{- end }}

{{/*
=============================================================================
PVC name — uses existingPvc if set, otherwise "pvc-{namespace}"
=============================================================================
*/}}
{{- define "app.pvcName" -}}
{{- if .Values.existingPvc -}}
{{- .Values.existingPvc -}}
{{- else -}}
{{- printf "pvc-%s" .Release.Namespace -}}
{{- end -}}
{{- end }}

{{/*
=============================================================================
StorageClassName resolver (reads from whichever section is active)
=============================================================================
*/}}
{{- define "app.storageClassName" -}}
{{- if .Values.storageClass.enabled }}
{{- .Values.storageClass.name }}
{{- else if .Values.persistentVolume.enabled }}
{{- .Values.persistentVolume.storageClassName }}
{{- else }}
{{- .Values.persistentVolumeClaim.storageClassName }}
{{- end }}
{{- end }}

{{/*
=============================================================================
ResourceGroup resolver (reads from SC or PV section)
=============================================================================
*/}}
{{- define "app.resourceGroup" -}}
{{- if .Values.storageClass.enabled }}
{{- .Values.storageClass.resourceGroup }}
{{- else }}
{{- .Values.persistentVolume.resourceGroup }}
{{- end }}
{{- end }}

{{/*
=============================================================================
ShareName resolver (reads from SC or PV section)
=============================================================================
*/}}
{{- define "app.shareName" -}}
{{- if .Values.storageClass.enabled }}
{{- .Values.storageClass.shareName }}
{{- else }}
{{- .Values.persistentVolume.shareName }}
{{- end }}
{{- end }}

{{/*
=============================================================================
Storage Secret values resolver (reads from SC or PV section)
=============================================================================
*/}}
{{- define "app.storageAccountName" -}}
{{- if .Values.storageClass.enabled }}
{{- .Values.storageClass.storageSecret.azurestorageaccountname }}
{{- else }}
{{- .Values.persistentVolume.storageSecret.azurestorageaccountname }}
{{- end }}
{{- end }}

{{- define "app.storageAccountKey" -}}
{{- if .Values.storageClass.enabled }}
{{- .Values.storageClass.storageSecret.azurestorageaccountkey }}
{{- else }}
{{- .Values.persistentVolume.storageSecret.azurestorageaccountkey }}
{{- end }}
{{- end }}

{{/*
=============================================================================
PVC volumeName resolver
=============================================================================
*/}}
{{- define "app.pvcVolumeName" -}}
{{- if or .Values.storageClass.enabled .Values.persistentVolume.enabled }}
{{- include "app.pvName" . }}
{{- else }}
{{- .Values.persistentVolumeClaim.volumeName }}
{{- end }}
{{- end }}

{{/*
=============================================================================
Database URL builders
=============================================================================
Builds: mysql:host={host};port={port};dbname={dbname}
Each role (master/slave/report) can have a different host
*/}}
{{- define "app.masterDbUrl" -}}
mysql:host={{ .global.Values.database.masterHost }};port={{ .global.Values.database.port }};dbname={{ .dbname }}
{{- end }}

{{- define "app.slaveDbUrl" -}}
mysql:host={{ .global.Values.database.slaveHost }};port={{ .global.Values.database.port }};dbname={{ .dbname }}
{{- end }}

{{- define "app.reportDbUrl" -}}
mysql:host={{ .global.Values.database.reportHost }};port={{ .global.Values.database.port }};dbname={{ .dbname }}
{{- end }}

{{/*
=============================================================================
Image resolver
=============================================================================
Uses per-deployment image if set, otherwise falls back to global.image
*/}}
{{- define "app.image" -}}
{{- if .local -}}
{{- .local -}}
{{- else -}}
{{- .global -}}
{{- end -}}
{{- end }}
