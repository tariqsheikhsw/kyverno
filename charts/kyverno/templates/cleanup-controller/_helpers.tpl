{{/* vim: set filetype=mustache: */}}

{{- define "kyverno.cleanup-controller.name" -}}
{{ template "kyverno.name" . }}-cleanup-controller
{{- end -}}

{{- define "kyverno.cleanup-controller.labels" -}}
{{- template "kyverno.labels.merge" (list
  (include "kyverno.labels.common" .)
  (include "kyverno.cleanup-controller.matchLabels" .)
) -}}
{{- end -}}

{{- define "kyverno.cleanup-controller.matchLabels" -}}
{{- template "kyverno.labels.merge" (list
  (include "kyverno.matchLabels.common" .)
  (include "kyverno.labels.component" "cleanup-controller")
) -}}
{{- end -}}

{{- define "kyverno.cleanup-controller.image" -}}
{{- if .image.registry -}}
  {{ .image.registry }}/{{ required "An image repository is required" .image.repository }}:{{ default .defaultTag .image.tag }}
{{- else -}}
  {{ required "An image repository is required" .image.repository }}:{{ default .defaultTag .image.tag }}
{{- end -}}
{{- end -}}

{{- define "kyverno.cleanup-controller.roleName" -}}
{{ .Release.Name }}:cleanup-controller
{{- end -}}

{{- define "kyverno.cleanup-controller.serviceAccountName" -}}
{{- if .Values.cleanupController.rbac.create -}}
    {{ default (include "kyverno.cleanup-controller.name" .) .Values.cleanupController.rbac.serviceAccount.name }}
{{- else -}}
    {{ required "A service account name is required when `rbac.create` is set to `false`" .Values.cleanupController.rbac.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "kyverno.cleanup-controller.securityContext" -}}
{{- if semverCompare "<1.19" .Capabilities.KubeVersion.Version -}}
  {{- toYaml (omit .Values.cleanupController.securityContext "seccompProfile") -}}
{{- else -}}
  {{- toYaml .Values.cleanupController.securityContext -}}
{{- end }}
{{- end }}

{{/* Create the default PodDisruptionBudget to use */}}
{{- define "kyverno.cleanup-controller.podDisruptionBudget.spec" -}}
{{- if and .Values.cleanupController.podDisruptionBudget.minAvailable .Values.cleanupController.podDisruptionBudget.maxUnavailable }}
{{- fail "Cannot set both .Values.cleanupController.podDisruptionBudget.minAvailable and .Values.cleanupController.podDisruptionBudget.maxUnavailable" -}}
{{- end }}
{{- if not .Values.cleanupController.podDisruptionBudget.maxUnavailable }}
minAvailable: {{ default 1 .Values.cleanupController.podDisruptionBudget.minAvailable }}
{{- end }}
{{- if .Values.cleanupController.podDisruptionBudget.maxUnavailable }}
maxUnavailable: {{ .Values.cleanupController.podDisruptionBudget.maxUnavailable }}
{{- end }}
{{- end }}
