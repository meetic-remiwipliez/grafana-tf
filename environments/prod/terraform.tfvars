# Configuration pour l'environnement PROD
# Généré automatiquement depuis les fichiers YAML

# Variables globales
grafana_url = "http://localhost:3000"
grafana_token = "TOKEN_A_FOURNIR"
folder_uid = "alerts"
prometheus_datasource_uid = "PROMETHEUS_UID_A_FOURNIR"
interval_seconds = 60

# Labels par défaut
default_labels = {
  environment = "prod"
  team        = "platform"
}

# Seuils d'alertes configurables
alert_thresholds = {
  # Alertes kubernetes-apps
  pod_crash_loop_duration = "15m"
  pod_not_ready_duration  = "15m"
  deployment_generation_mismatch_duration = "15m"
  deployment_replicas_mismatch_duration = "15m"
  deployment_rollout_stuck_duration = "15m"
  statefulset_replicas_mismatch_duration = "15m"
  statefulset_generation_mismatch_duration = "15m"
  statefulset_update_not_rolled_out_duration = "15m"
  daemonset_rollout_stuck_duration = "15m"
  container_waiting_duration = "1h"
  daemonset_not_scheduled_duration = "10m"
  daemonset_misscheduled_duration = "15m"
  job_not_completed_duration = "12h"
  
  # Alertes kubernetes-resources
  node_cpu_usage_threshold = 80
  node_memory_usage_threshold = 80
  node_disk_usage_threshold = 85
  node_inodes_usage_threshold = 85
  container_cpu_usage_threshold = 80
  container_memory_usage_threshold = 80
  container_memory_requests_threshold = 80
  container_cpu_requests_threshold = 80
  container_memory_limits_threshold = 80
  container_cpu_limits_threshold = 80
  
  # Alertes kubernetes-storage
  persistentvolumeclaim_information_available_duration = "5m"
  persistentvolumeclaim_information_not_available_duration = "5m"
  persistentvolumeclaim_phase_pending_duration = "5m"
  persistentvolumeclaim_phase_failed_duration = "5m"
  storage_quota_exceeded_threshold = 80
  
  # Alertes kubernetes-system
  apiserver_availability_threshold = 99.9
  apiserver_burnrate_threshold = 0.1
  scheduler_burnrate_threshold = 0.1
  controller_manager_burnrate_threshold = 0.1
  kube_proxy_burnrate_threshold = 0.1
  kubelet_burnrate_threshold = 0.1
  node_burnrate_threshold = 0.1
}

# Intervalles d'évaluation spécifiques
rule_intervals = {
  kube_apiserver_availability = 180  # 3m
  kube_apiserver_burnrate = 60       # 1m
  kube_apiserver_histogram = 60      # 1m
  k8s_rules = 60                     # 1m
  kube_scheduler = 60                # 1m
  node_rules = 60                    # 1m
  kubelet_rules = 60                 # 1m
}

# Groupes d'alertes convertis depuis prometheus_alerts.yaml
alert_groups = {
  kubernetes_apps = {
    name = "kubernetes-apps"
    rules = [
      {
        name = "KubePodCrashLooping"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason: "CrashLoopBackOff")."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodcrashlooping"
          "summary" = "Pod is crash looping."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "max_over_time(kube_pod_container_status_waiting_reason{reason=\"CrashLoopBackOff\", job=\"kube-state-metrics\"}[5m]) >= 1"
          }
        }
      }
      {
        name = "KubePodNotReady"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-ready state for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodnotready"
          "summary" = "Pod has been in a non-ready state for more than 15 minutes."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (namespace, pod, cluster) (
  max by(namespace, pod, cluster) (
    kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown|Failed"}
  ) * on(namespace, pod, cluster) group_left(owner_kind) topk by(namespace, pod, cluster) (
    1, max by(namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!="Job"})
  )
) > 0
EOT
          }
        }
      }
      {
        name = "KubeDeploymentGenerationMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentgenerationmismatch"
          "summary" = "Deployment generation mismatch due to possible roll-back"
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_deployment_status_observed_generation{job="kube-state-metrics"}
  !=
kube_deployment_metadata_generation{job="kube-state-metrics"}
EOT
          }
        }
      }
      {
        name = "KubeDeploymentReplicasMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentreplicasmismatch"
          "summary" = "Deployment has not matched the expected number of replicas."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kube_deployment_spec_replicas{job="kube-state-metrics"}
    >
  kube_deployment_status_replicas_available{job="kube-state-metrics"}
) and (
  changes(kube_deployment_status_replicas_updated{job="kube-state-metrics"}[10m])
    ==
  0
)
EOT
          }
        }
      }
      {
        name = "KubeDeploymentRolloutStuck"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Rollout of deployment {{ $labels.namespace }}/{{ $labels.deployment }} is not progressing for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentrolloutstuck"
          "summary" = "Deployment rollout is not progressing."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_deployment_status_condition{condition="Progressing", status="false",job="kube-state-metrics"}
!= 0
EOT
          }
        }
      }
      {
        name = "KubeStatefulSetReplicasMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetreplicasmismatch"
          "summary" = "StatefulSet has not matched the expected number of replicas."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kube_statefulset_status_replicas_ready{job="kube-state-metrics"}
    !=
  kube_statefulset_replicas{job="kube-state-metrics"}
) and (
  changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[10m])
    ==
  0
)
EOT
          }
        }
      }
      {
        name = "KubeStatefulSetGenerationMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetgenerationmismatch"
          "summary" = "StatefulSet generation mismatch due to possible roll-back"
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_statefulset_status_observed_generation{job="kube-state-metrics"}
  !=
kube_statefulset_metadata_generation{job="kube-state-metrics"}
EOT
          }
        }
      }
      {
        name = "KubeStatefulSetUpdateNotRolledOut"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetupdatenotrolledout"
          "summary" = "StatefulSet update has not been rolled out."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  max by(namespace, statefulset, job, cluster) (
    kube_statefulset_status_current_revision{job="kube-state-metrics"}
      unless
    kube_statefulset_status_update_revision{job="kube-state-metrics"}
  )
    * on(namespace, statefulset, job, cluster)
  (
    kube_statefulset_replicas{job="kube-state-metrics"}
      !=
    kube_statefulset_status_replicas_updated{job="kube-state-metrics"}
  )
)  and on(namespace, statefulset, job, cluster) (
  changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[5m])
    ==
  0
)
EOT
          }
        }
      }
      {
        name = "KubeDaemonSetRolloutStuck"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15m."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetrolloutstuck"
          "summary" = "DaemonSet rollout is stuck."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    kube_daemonset_status_current_number_scheduled{job="kube-state-metrics"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
  ) or (
    kube_daemonset_status_number_misscheduled{job="kube-state-metrics"}
     !=
    0
  ) or (
    kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
  ) or (
    kube_daemonset_status_number_available{job="kube-state-metrics"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
  )
) and (
  changes(kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics"}[5m])
    ==
  0
)
EOT
          }
        }
      }
      {
        name = "KubeContainerWaiting"
        condition = "B"
        for = "1h"
        annotations = {
          "description" = "pod/{{ $labels.pod }} in namespace {{ $labels.namespace }} on container {{ $labels.container}} has been in waiting state for longer than 1 hour. (reason: "{{ $labels.reason }}")."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecontainerwaiting"
          "summary" = "Pod container waiting longer than 1 hour"
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kube_pod_container_status_waiting_reason{reason!=\"CrashLoopBackOff\", job=\"kube-state-metrics\"} > 0"
          }
        }
      }
      {
        name = "KubeDaemonSetNotScheduled"
        condition = "B"
        for = "10m"
        annotations = {
          "description" = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetnotscheduled"
          "summary" = "DaemonSet pods are not scheduled."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
  -
kube_daemonset_status_current_number_scheduled{job="kube-state-metrics"} > 0
EOT
          }
        }
      }
      {
        name = "KubeDaemonSetMisScheduled"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetmisscheduled"
          "summary" = "DaemonSet pods are misscheduled."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kube_daemonset_status_number_misscheduled{job=\"kube-state-metrics\"} > 0"
          }
        }
      }
      {
        name = "KubeJobNotCompleted"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than {{ "43200" | humanizeDuration }} to complete."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubejobnotcompleted"
          "summary" = "Job did not complete in time"
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
time() - max by(namespace, job_name, cluster) (kube_job_status_start_time{job="kube-state-metrics"}
  and
kube_job_status_active{job="kube-state-metrics"} > 0) > 43200
EOT
          }
        }
      }
      {
        name = "KubeJobFailed"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubejobfailed"
          "summary" = "Job failed to complete."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kube_job_failed{job=\"kube-state-metrics\"}  > 0"
          }
        }
      }
      {
        name = "KubeHpaReplicasMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has not matched the desired number of replicas for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubehpareplicasmismatch"
          "summary" = "HPA has not matched desired number of replicas."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics"}
  !=
kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"})
  and
(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
  >
kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics"})
  and
(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
  <
kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"})
  and
changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}[15m]) == 0
EOT
          }
        }
      }
      {
        name = "KubeHpaMaxedOut"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has been running at max replicas for longer than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubehpamaxedout"
          "summary" = "HPA is running at max replicas"
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
  ==
kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"}
EOT
          }
        }
      }
      {
        name = "KubePdbNotEnoughHealthyPods"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "PDB {{ $labels.namespace }}/{{ $labels.poddisruptionbudget }} expects {{ $value }} more healthy pods. The desired number of healthy pods has not been met for at least 15m."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepdbnotenoughhealthypods"
          "summary" = "PDB does not have enough healthy pods."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kube_poddisruptionbudget_status_desired_healthy{job="kube-state-metrics"}
  -
  kube_poddisruptionbudget_status_current_healthy{job="kube-state-metrics"}
)
> 0
EOT
          }
        }
      }
    ]
  }
  kubernetes_resources = {
    name = "kubernetes-resources"
    rules = [
      {
        name = "KubeCPUOvercommit"
        condition = "B"
        for = "10m"
        annotations = {
          "description" = "Cluster has overcommitted CPU resource requests for Pods by {{ $value }} CPU shares and cannot tolerate node failure."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuovercommit"
          "summary" = "Cluster has overcommitted CPU resource requests."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(namespace_cpu:kube_pod_container_resource_requests:sum{}) - (sum(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"}) - max(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"})) > 0
and
(sum(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"}) - max(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"})) > 0
EOT
          }
        }
      }
      {
        name = "KubeMemoryOvercommit"
        condition = "B"
        for = "10m"
        annotations = {
          "description" = "Cluster has overcommitted memory resource requests for Pods by {{ $value | humanize }} bytes and cannot tolerate node failure."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememoryovercommit"
          "summary" = "Cluster has overcommitted memory resource requests."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(namespace_memory:kube_pod_container_resource_requests:sum{}) - (sum(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"}) - max(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"})) > 0
and
(sum(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"}) - max(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"})) > 0
EOT
          }
        }
      }
      {
        name = "KubeCPUQuotaOvercommit"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Cluster has overcommitted CPU resource requests for Namespaces."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecpuquotaovercommit"
          "summary" = "Cluster has overcommitted CPU resource requests."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(min without(resource) (kube_resourcequota{job="kube-state-metrics", type="hard", resource=~"(cpu|requests.cpu)"}))
  /
sum(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"})
  > 1.5
EOT
          }
        }
      }
      {
        name = "KubeMemoryQuotaOvercommit"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Cluster has overcommitted memory resource requests for Namespaces."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubememoryquotaovercommit"
          "summary" = "Cluster has overcommitted memory resource requests."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(min without(resource) (kube_resourcequota{job="kube-state-metrics", type="hard", resource=~"(memory|requests.memory)"}))
  /
sum(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"})
  > 1.5
EOT
          }
        }
      }
      {
        name = "KubeQuotaAlmostFull"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubequotaalmostfull"
          "summary" = "Namespace quota is going to be full."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_resourcequota{job="kube-state-metrics", type="used"}
  / ignoring(instance, job, type)
(kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
  > 0.9 < 1
EOT
          }
        }
      }
      {
        name = "KubeQuotaFullyUsed"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubequotafullyused"
          "summary" = "Namespace quota is fully used."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_resourcequota{job="kube-state-metrics", type="used"}
  / ignoring(instance, job, type)
(kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
  == 1
EOT
          }
        }
      }
      {
        name = "KubeQuotaExceeded"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubequotaexceeded"
          "summary" = "Namespace quota has exceeded the limits."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_resourcequota{job="kube-state-metrics", type="used"}
  / ignoring(instance, job, type)
(kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
  > 1
EOT
          }
        }
      }
      {
        name = "CPUThrottlingHigh"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "{{ $value | humanizePercentage }} throttling of CPU in namespace {{ $labels.namespace }} for container {{ $labels.container }} in pod {{ $labels.pod }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-cputhrottlinghigh"
          "summary" = "Processes experience elevated CPU throttling."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(increase(container_cpu_cfs_throttled_periods_total{container!="", job="cadvisor", }[5m])) without (id, metrics_path, name, image, endpoint, job, node)
  / on (cluster, namespace, pod, container, instance) group_left
sum(increase(container_cpu_cfs_periods_total{job="cadvisor", }[5m])) without (id, metrics_path, name, image, endpoint, job, node)
  > ( 25 / 100 )
EOT
          }
        }
      }
    ]
  }
  kubernetes_storage = {
    name = "kubernetes-storage"
    rules = [
      {
        name = "KubePersistentVolumeFillingUp"
        condition = "B"
        for = "1m"
        annotations = {
          "description" = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is only {{ $value | humanizePercentage }} free."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumefillingup"
          "summary" = "PersistentVolume is filling up."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kubelet_volume_stats_available_bytes{job="kubelet"}
    /
  kubelet_volume_stats_capacity_bytes{job="kubelet"}
) < 0.03
and
kubelet_volume_stats_used_bytes{job="kubelet"} > 0
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
EOT
          }
        }
      }
      {
        name = "KubePersistentVolumeFillingUp"
        condition = "B"
        for = "1h"
        annotations = {
          "description" = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is expected to fill up within four days. Currently {{ $value | humanizePercentage }} is available."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumefillingup"
          "summary" = "PersistentVolume is filling up."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kubelet_volume_stats_available_bytes{job="kubelet"}
    /
  kubelet_volume_stats_capacity_bytes{job="kubelet"}
) < 0.15
and
kubelet_volume_stats_used_bytes{job="kubelet"} > 0
and
predict_linear(kubelet_volume_stats_available_bytes{job="kubelet"}[6h], 4 * 24 * 3600) < 0
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
EOT
          }
        }
      }
      {
        name = "KubePersistentVolumeInodesFillingUp"
        condition = "B"
        for = "1m"
        annotations = {
          "description" = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} only has {{ $value | humanizePercentage }} free inodes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeinodesfillingup"
          "summary" = "PersistentVolumeInodes are filling up."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kubelet_volume_stats_inodes_free{job="kubelet"}
    /
  kubelet_volume_stats_inodes{job="kubelet"}
) < 0.03
and
kubelet_volume_stats_inodes_used{job="kubelet"} > 0
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
EOT
          }
        }
      }
      {
        name = "KubePersistentVolumeInodesFillingUp"
        condition = "B"
        for = "1h"
        annotations = {
          "description" = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is expected to run out of inodes within four days. Currently {{ $value | humanizePercentage }} of its inodes are free."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeinodesfillingup"
          "summary" = "PersistentVolumeInodes are filling up."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  kubelet_volume_stats_inodes_free{job="kubelet"}
    /
  kubelet_volume_stats_inodes{job="kubelet"}
) < 0.15
and
kubelet_volume_stats_inodes_used{job="kubelet"} > 0
and
predict_linear(kubelet_volume_stats_inodes_free{job="kubelet"}[6h], 4 * 24 * 3600) < 0
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on(cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
EOT
          }
        }
      }
      {
        name = "KubePersistentVolumeErrors"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "The persistent volume {{ $labels.persistentvolume }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} has status {{ $labels.phase }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeerrors"
          "summary" = "PersistentVolume is having issues with provisioning."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kube_persistentvolume_status_phase{phase=~\"Failed|Pending\",job=\"kube-state-metrics\"} > 0"
          }
        }
      }
    ]
  }
  kubernetes_system = {
    name = "kubernetes-system"
    rules = [
      {
        name = "KubeVersionMismatch"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "There are {{ $value }} different semantic versions of Kubernetes components running."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeversionmismatch"
          "summary" = "Different semantic versions of Kubernetes components running."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "count by (cluster) (count by (git_version, cluster) (label_replace(kubernetes_build_info{job!~\"kube-dns|coredns\"},\"git_version\",\"$1\",\"git_version\",\"(v[0-9]*.[0-9]*).*\"))) > 1"
          }
        }
      }
      {
        name = "KubeClientErrors"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeclienterrors"
          "summary" = "Kubernetes API server client is experiencing errors."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(sum(rate(rest_client_requests_total{job="kube-apiserver",code=~"5.."}[5m])) by (cluster, instance, job, namespace)
  /
sum(rate(rest_client_requests_total{job="kube-apiserver"}[5m])) by (cluster, instance, job, namespace))
> 0.01
EOT
          }
        }
      }
    ]
  }
  kube_apiserver_slos = {
    name = "kube-apiserver-slos"
    rules = [
      {
        name = "KubeAPIErrorBudgetBurn"
        condition = "B"
        for = "2m"
        annotations = {
          "description" = "The API server is burning too much error budget."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapierrorbudgetburn"
          "summary" = "The API server is burning too much error budget."
        }
        labels = {
          "long" = "1h"
          "severity" = "critical"
          "short" = "5m"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by(cluster) (apiserver_request:burnrate1h) > (14.40 * 0.01000)
and on(cluster)
sum by(cluster) (apiserver_request:burnrate5m) > (14.40 * 0.01000)
EOT
          }
        }
      }
      {
        name = "KubeAPIErrorBudgetBurn"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "The API server is burning too much error budget."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapierrorbudgetburn"
          "summary" = "The API server is burning too much error budget."
        }
        labels = {
          "long" = "6h"
          "severity" = "critical"
          "short" = "30m"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by(cluster) (apiserver_request:burnrate6h) > (6.00 * 0.01000)
and on(cluster)
sum by(cluster) (apiserver_request:burnrate30m) > (6.00 * 0.01000)
EOT
          }
        }
      }
      {
        name = "KubeAPIErrorBudgetBurn"
        condition = "B"
        for = "1h"
        annotations = {
          "description" = "The API server is burning too much error budget."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapierrorbudgetburn"
          "summary" = "The API server is burning too much error budget."
        }
        labels = {
          "long" = "1d"
          "severity" = "warning"
          "short" = "2h"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by(cluster) (apiserver_request:burnrate1d) > (3.00 * 0.01000)
and on(cluster)
sum by(cluster) (apiserver_request:burnrate2h) > (3.00 * 0.01000)
EOT
          }
        }
      }
      {
        name = "KubeAPIErrorBudgetBurn"
        condition = "B"
        for = "3h"
        annotations = {
          "description" = "The API server is burning too much error budget."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapierrorbudgetburn"
          "summary" = "The API server is burning too much error budget."
        }
        labels = {
          "long" = "3d"
          "severity" = "warning"
          "short" = "6h"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by(cluster) (apiserver_request:burnrate3d) > (1.00 * 0.01000)
and on(cluster)
sum by(cluster) (apiserver_request:burnrate6h) > (1.00 * 0.01000)
EOT
          }
        }
      }
    ]
  }
  kubernetes_system_apiserver = {
    name = "kubernetes-system-apiserver"
    rules = [
      {
        name = "KubeClientCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "A client certificate used to authenticate to kubernetes apiserver is expiring in less than 7.0 days."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeclientcertificateexpiration"
          "summary" = "Client certificate is about to expire."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
histogram_quantile(0.01, sum without (namespace, service, endpoint) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="kube-apiserver"}[5m]))) < 604800
and
on(job, cluster, instance) apiserver_client_certificate_expiration_seconds_count{job="kube-apiserver"} > 0
EOT
          }
        }
      }
      {
        name = "KubeClientCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "A client certificate used to authenticate to kubernetes apiserver is expiring in less than 24.0 hours."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeclientcertificateexpiration"
          "summary" = "Client certificate is about to expire."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
histogram_quantile(0.01, sum without (namespace, service, endpoint) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="kube-apiserver"}[5m]))) < 86400
and
on(job, cluster, instance) apiserver_client_certificate_expiration_seconds_count{job="kube-apiserver"} > 0
EOT
          }
        }
      }
      {
        name = "KubeAggregatedAPIErrors"
        condition = "B"
        for = "10m"
        annotations = {
          "description" = "Kubernetes aggregated API {{ $labels.instance }}/{{ $labels.name }} has reported {{ $labels.reason }} errors."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeaggregatedapierrors"
          "summary" = "Kubernetes aggregated API has reported errors."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by(cluster, instance, name, reason)(increase(aggregator_unavailable_apiservice_total{job=\"kube-apiserver\"}[1m])) > 0"
          }
        }
      }
      {
        name = "KubeAggregatedAPIDown"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has been only {{ $value | humanize }}% available over the last 10m."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeaggregatedapidown"
          "summary" = "Kubernetes aggregated API is down."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "(1 - max by(name, namespace, cluster)(avg_over_time(aggregator_unavailable_apiservice{job=\"kube-apiserver\"}[10m]))) * 100 < 85"
          }
        }
      }
      {
        name = "KubeAPIDown"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "KubeAPI has disappeared from Prometheus target discovery."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapidown"
          "summary" = "Target disappeared from Prometheus target discovery."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "absent(up{job=\"kube-apiserver\"} == 1)"
          }
        }
      }
      {
        name = "KubeAPITerminatedRequests"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapiterminatedrequests"
          "summary" = "The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by(cluster) (rate(apiserver_request_terminations_total{job=\"kube-apiserver\"}[10m])) / ( sum by(cluster) (rate(apiserver_request_total{job=\"kube-apiserver\"}[10m])) + sum by(cluster) (rate(apiserver_request_terminations_total{job=\"kube-apiserver\"}[10m])) ) > 0.20"
          }
        }
      }
    ]
  }
  kubernetes_system_kubelet = {
    name = "kubernetes-system-kubelet"
    rules = [
      {
        name = "KubeNodeNotReady"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "{{ $labels.node }} has been unready for more than 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodenotready"
          "summary" = "Node is not ready."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_node_status_condition{job="kube-state-metrics",condition="Ready",status="true"} == 0
and on (cluster, node)
kube_node_spec_unschedulable{job="kube-state-metrics"} == 0
EOT
          }
        }
      }
      {
        name = "KubeNodePressure"
        condition = "B"
        for = "10m"
        annotations = {
          "description" = "{{ $labels.node }} has active Condition {{ $labels.condition }}. This is caused by resource usage exceeding eviction thresholds."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodepressure"
          "summary" = "Node has as active Condition."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_node_status_condition{job="kube-state-metrics",condition=~"(MemoryPressure|DiskPressure|PIDPressure)",status="true"} == 1
and on (cluster, node)
kube_node_spec_unschedulable{job="kube-state-metrics"} == 0
EOT
          }
        }
      }
      {
        name = "KubeNodeUnreachable"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "{{ $labels.node }} is unreachable and some workloads may be rescheduled."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodeunreachable"
          "summary" = "Node is unreachable."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "(kube_node_spec_taint{job=\"kube-state-metrics\",key=\"node.kubernetes.io/unreachable\",effect=\"NoSchedule\"} unless ignoring(key,value) kube_node_spec_taint{job=\"kube-state-metrics\",key=~\"ToBeDeletedByClusterAutoscaler|cloud.google.com/impending-node-termination|aws-node-termination-handler/spot-itn\"}) == 1"
          }
        }
      }
      {
        name = "KubeletTooManyPods"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubelet '{{ $labels.node }}' is running at {{ $value | humanizePercentage }} of its Pod capacity."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubelettoomanypods"
          "summary" = "Kubelet is running at capacity."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  max by (cluster, instance) (
    kubelet_running_pods{job="kubelet"} > 1
  )
  * on (cluster, instance) group_left(node)
  max by (cluster, instance, node) (
    kubelet_node_name{job="kubelet"}
  )
)
/ on (cluster, node) group_left()
max by (cluster, node) (
  kube_node_status_capacity{job="kube-state-metrics", resource="pods"} != 1
) > 0.95
EOT
          }
        }
      }
      {
        name = "KubeNodeReadinessFlapping"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "The readiness status of node {{ $labels.node }} has changed {{ $value }} times in the last 15 minutes."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodereadinessflapping"
          "summary" = "Node readiness status is flapping."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(changes(kube_node_status_condition{job="kube-state-metrics",status="true",condition="Ready"}[15m])) by (cluster, node) > 2
and on (cluster, node)
kube_node_spec_unschedulable{job="kube-state-metrics"} == 0
EOT
          }
        }
      }
      {
        name = "KubeNodeEviction"
        condition = "B"
        for = "0s"
        annotations = {
          "description" = "Node {{ $labels.node }} is evicting Pods due to {{ $labels.eviction_signal }}.  Eviction occurs when eviction thresholds are crossed, typically caused by Pods exceeding RAM/ephemeral-storage limits."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodeeviction"
          "summary" = "Node is evicting pods."
        }
        labels = {
          "severity" = "info"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(rate(kubelet_evictions{job="kubelet"}[15m])) by(cluster, eviction_signal, instance)
* on (cluster, instance) group_left(node)
max by (cluster, instance, node) (
  kubelet_node_name{job="kubelet"}
)
> 0
EOT
          }
        }
      }
      {
        name = "KubeletPlegDurationHigh"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "The Kubelet Pod Lifecycle Event Generator has a 99th percentile duration of {{ $value }} seconds on node {{ $labels.node }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletplegdurationhigh"
          "summary" = "Kubelet Pod Lifecycle Event Generator is taking too long to relist."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile{quantile=\"0.99\"} >= 10"
          }
        }
      }
      {
        name = "KubeletPodStartUpLatencyHigh"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubelet Pod startup 99th percentile latency is {{ $value }} seconds on node {{ $labels.node }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletpodstartuplatencyhigh"
          "summary" = "Kubelet Pod startup latency is too high."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum(rate(kubelet_pod_worker_duration_seconds_bucket{job=\"kubelet\"}[5m])) by (cluster, instance, le)) * on(cluster, instance) group_left(node) kubelet_node_name{job=\"kubelet\"} > 60"
          }
        }
      }
      {
        name = "KubeletClientCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletclientcertificateexpiration"
          "summary" = "Kubelet client certificate is about to expire."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kubelet_certificate_manager_client_ttl_seconds < 604800"
          }
        }
      }
      {
        name = "KubeletClientCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletclientcertificateexpiration"
          "summary" = "Kubelet client certificate is about to expire."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kubelet_certificate_manager_client_ttl_seconds < 86400"
          }
        }
      }
      {
        name = "KubeletServerCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletservercertificateexpiration"
          "summary" = "Kubelet server certificate is about to expire."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kubelet_certificate_manager_server_ttl_seconds < 604800"
          }
        }
      }
      {
        name = "KubeletServerCertificateExpiration"
        condition = "B"
        for = "5m"
        annotations = {
          "description" = "Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletservercertificateexpiration"
          "summary" = "Kubelet server certificate is about to expire."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "kubelet_certificate_manager_server_ttl_seconds < 86400"
          }
        }
      }
      {
        name = "KubeletClientCertificateRenewalErrors"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubelet on node {{ $labels.node }} has failed to renew its client certificate ({{ $value | humanize }} errors in the last 5 minutes)."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletclientcertificaterenewalerrors"
          "summary" = "Kubelet has failed to renew its client certificate."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "increase(kubelet_certificate_manager_client_expiration_renew_errors[5m]) > 0"
          }
        }
      }
      {
        name = "KubeletServerCertificateRenewalErrors"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubelet on node {{ $labels.node }} has failed to renew its server certificate ({{ $value | humanize }} errors in the last 5 minutes)."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletservercertificaterenewalerrors"
          "summary" = "Kubelet has failed to renew its server certificate."
        }
        labels = {
          "severity" = "warning"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "increase(kubelet_server_expiration_renew_errors[5m]) > 0"
          }
        }
      }
      {
        name = "KubeletDown"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "Kubelet has disappeared from Prometheus target discovery."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeletdown"
          "summary" = "Target disappeared from Prometheus target discovery."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "absent(up{job=\"kubelet\"} == 1)"
          }
        }
      }
    ]
  }
  kubernetes_system_scheduler = {
    name = "kubernetes-system-scheduler"
    rules = [
      {
        name = "KubeSchedulerDown"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "KubeScheduler has disappeared from Prometheus target discovery."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeschedulerdown"
          "summary" = "Target disappeared from Prometheus target discovery."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "absent(up{job=\"kube-scheduler\"} == 1)"
          }
        }
      }
    ]
  }
  kubernetes_system_controller_manager = {
    name = "kubernetes-system-controller-manager"
    rules = [
      {
        name = "KubeControllerManagerDown"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "KubeControllerManager has disappeared from Prometheus target discovery."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecontrollermanagerdown"
          "summary" = "Target disappeared from Prometheus target discovery."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "absent(up{job=\"kube-controller-manager\"} == 1)"
          }
        }
      }
    ]
  }
  kubernetes_system_kube_proxy = {
    name = "kubernetes-system-kube-proxy"
    rules = [
      {
        name = "KubeProxyDown"
        condition = "B"
        for = "15m"
        annotations = {
          "description" = "KubeProxy has disappeared from Prometheus target discovery."
          "runbook_url" = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeproxydown"
          "summary" = "Target disappeared from Prometheus target discovery."
        }
        labels = {
          "severity" = "critical"
        }
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "absent(up{job=\"kube-proxy\"} == 1)"
          }
        }
      }
    ]
  }
}

# Groupes de règles d'enregistrement convertis depuis prometheus_rules.yaml
recording_groups = {
  kube_apiserver_availability_rules = {
    name = "kube-apiserver-availability.rules"
    rules = [
      {
        name = "code_verb:apiserver_request_total:increase30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30"
          }
        }
      }
      {
        name = "code:apiserver_request_total:increase30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~\"LIST|GET\"})"
          }
        }
      }
      {
        name = "code:apiserver_request_total:increase30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~\"POST|PUT|PATCH|DELETE\"})"
          }
        }
      }
      {
        name = "cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, verb, scope, le) (increase(apiserver_request_sli_duration_seconds_bucket[1h]))"
          }
        }
      }
      {
        name = "cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, verb, scope, le) (avg_over_time(cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase1h[30d]) * 24 * 30)"
          }
        }
      }
      {
        name = "cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, verb, scope) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase1h{le=\"+Inf\"})"
          }
        }
      }
      {
        name = "cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, verb, scope) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{le=\"+Inf\"})"
          }
        }
      }
      {
        name = "apiserver_request:availability30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
1 - (
  (
    # write too slow
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
    -
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le=~"1(\\.0)?"} or vector(0))
  ) +
  (
    # read too slow
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"LIST|GET"})
    -
    (
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le=~"1(\\.0)?"} or vector(0))
      +
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le=~"5(\\.0)?"} or vector(0))
      +
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le=~"30(\\.0)?"} or vector(0))
    )
  ) +
  # errors
  sum by (cluster) (code:apiserver_request_total:increase30d{code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d)
EOT
          }
        }
      }
      {
        name = "apiserver_request:availability30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
1 - (
  sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"LIST|GET"})
  -
  (
    # too slow
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le=~"1(\\.0)?"} or vector(0))
    +
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le=~"5(\\.0)?"} or vector(0))
    +
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le=~"30(\\.0)?"} or vector(0))
  )
  +
  # errors
  sum by (cluster) (code:apiserver_request_total:increase30d{verb="read",code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d{verb="read"})
EOT
          }
        }
      }
      {
        name = "apiserver_request:availability30d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
1 - (
  (
    # too slow
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
    -
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le=~"1(\\.0)?"} or vector(0))
  )
  +
  # errors
  sum by (cluster) (code:apiserver_request_total:increase30d{verb="write",code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d{verb="write"})
EOT
          }
        }
      }
      {
        name = "code_resource:apiserver_request_total:rate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster,code,resource) (rate(apiserver_request_total{job=\"kube-apiserver\",verb=~\"LIST|GET\"}[5m]))"
          }
        }
      }
      {
        name = "code_resource:apiserver_request_total:rate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster,code,resource) (rate(apiserver_request_total{job=\"kube-apiserver\",verb=~\"POST|PUT|PATCH|DELETE\"}[5m]))"
          }
        }
      }
      {
        name = "code_verb:apiserver_request_total:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code, verb) (increase(apiserver_request_total{job=\"kube-apiserver\",verb=~\"LIST|GET|POST|PUT|PATCH|DELETE\",code=~\"2..\"}[1h]))"
          }
        }
      }
      {
        name = "code_verb:apiserver_request_total:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code, verb) (increase(apiserver_request_total{job=\"kube-apiserver\",verb=~\"LIST|GET|POST|PUT|PATCH|DELETE\",code=~\"3..\"}[1h]))"
          }
        }
      }
      {
        name = "code_verb:apiserver_request_total:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code, verb) (increase(apiserver_request_total{job=\"kube-apiserver\",verb=~\"LIST|GET|POST|PUT|PATCH|DELETE\",code=~\"4..\"}[1h]))"
          }
        }
      }
      {
        name = "code_verb:apiserver_request_total:increase1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "sum by (cluster, code, verb) (increase(apiserver_request_total{job=\"kube-apiserver\",verb=~\"LIST|GET|POST|PUT|PATCH|DELETE\",code=~\"5..\"}[1h]))"
          }
        }
      }
    ]
  }
  kube_apiserver_burnrate_rules = {
    name = "kube-apiserver-burnrate.rules"
    rules = [
      {
        name = "apiserver_request:burnrate1d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[1d]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[1d]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[1d]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[1d]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[1d]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[1d]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[1h]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[1h]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[1h]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[1h]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[1h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[1h]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate2h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[2h]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[2h]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[2h]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[2h]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[2h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[2h]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate30m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[30m]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[30m]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[30m]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[30m]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[30m]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[30m]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate3d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[3d]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[3d]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[3d]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[3d]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[3d]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[3d]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[5m]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[5m]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[5m]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[5m]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[5m]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[5m]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate6h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[6h]))
    -
    (
      (
        sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le=~"1(\\.0)?"}[6h]))
        or
        vector(0)
      )
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le=~"5(\\.0)?"}[6h]))
      +
      sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le=~"30(\\.0)?"}[6h]))
    )
  )
  +
  # errors
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET",code=~"5.."}[6h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"LIST|GET"}[6h]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate1d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[1d]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[1d]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[1d]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate1h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[1h]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[1h]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[1h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate2h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[2h]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[2h]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[2h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate30m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[30m]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[30m]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[30m]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate3d"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[3d]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[3d]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[3d]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[5m]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[5m]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[5m]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
EOT
          }
        }
      }
      {
        name = "apiserver_request:burnrate6h"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
(
  (
    # too slow
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_count{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[6h]))
    -
    sum by (cluster) (rate(apiserver_request_sli_duration_seconds_bucket{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le=~"1(\\.0)?"}[6h]))
  )
  +
  sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[6h]))
)
/
sum by (cluster) (rate(apiserver_request_total{job="kube-apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))
EOT
          }
        }
      }
    ]
  }
  kube_apiserver_histogram_rules = {
    name = "kube-apiserver-histogram.rules"
    rules = [
      {
        name = "cluster_quantile:apiserver_request_sli_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_sli_duration_seconds_bucket{job=\"kube-apiserver\",verb=~\"LIST|GET\",subresource!~\"proxy|attach|log|exec|portforward\"}[5m]))) > 0"
          }
        }
      }
      {
        name = "cluster_quantile:apiserver_request_sli_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_sli_duration_seconds_bucket{job=\"kube-apiserver\",verb=~\"POST|PUT|PATCH|DELETE\",subresource!~\"proxy|attach|log|exec|portforward\"}[5m]))) > 0"
          }
        }
      }
    ]
  }
  k8s_rules_container_cpu_usage_seconds_total = {
    name = "k8s.rules.container_cpu_usage_seconds_total"
    rules = [
      {
        name = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (cluster, namespace, pod, container) (
  rate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])
) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (
  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
      {
        name = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (cluster, namespace, pod, container) (
  irate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])
) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (
  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_working_set_bytes = {
    name = "k8s.rules.container_memory_working_set_bytes"
    rules = [
      {
        name = "node_namespace_pod_container:container_memory_working_set_bytes"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
container_memory_working_set_bytes{job="cadvisor", image!=""}
* on (cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1,
  max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_rss = {
    name = "k8s.rules.container_memory_rss"
    rules = [
      {
        name = "node_namespace_pod_container:container_memory_rss"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
container_memory_rss{job="cadvisor", image!=""}
* on (cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1,
  max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_cache = {
    name = "k8s.rules.container_memory_cache"
    rules = [
      {
        name = "node_namespace_pod_container:container_memory_cache"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
container_memory_cache{job="cadvisor", image!=""}
* on (cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1,
  max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_swap = {
    name = "k8s.rules.container_memory_swap"
    rules = [
      {
        name = "node_namespace_pod_container:container_memory_swap"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
container_memory_swap{job="cadvisor", image!=""}
* on (cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1,
  max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_requests = {
    name = "k8s.rules.container_memory_requests"
    rules = [
      {
        name = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)
group_left() max by (namespace, pod, cluster) (
  (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
)
EOT
          }
        }
      }
      {
        name = "namespace_memory:kube_pod_container_resource_requests:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (namespace, cluster) (
    sum by (namespace, pod, cluster) (
        max by (namespace, pod, container, cluster) (
          kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}
        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
          kube_pod_status_phase{phase=~"Pending|Running"} == 1
        )
    )
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_cpu_requests = {
    name = "k8s.rules.container_cpu_requests"
    rules = [
      {
        name = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)
group_left() max by (namespace, pod, cluster) (
  (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
)
EOT
          }
        }
      }
      {
        name = "namespace_cpu:kube_pod_container_resource_requests:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (namespace, cluster) (
    sum by (namespace, pod, cluster) (
        max by (namespace, pod, container, cluster) (
          kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}
        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
          kube_pod_status_phase{phase=~"Pending|Running"} == 1
        )
    )
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_memory_limits = {
    name = "k8s.rules.container_memory_limits"
    rules = [
      {
        name = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)
group_left() max by (namespace, pod, cluster) (
  (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
)
EOT
          }
        }
      }
      {
        name = "namespace_memory:kube_pod_container_resource_limits:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (namespace, cluster) (
    sum by (namespace, pod, cluster) (
        max by (namespace, pod, container, cluster) (
          kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}
        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
          kube_pod_status_phase{phase=~"Pending|Running"} == 1
        )
    )
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_container_cpu_limits = {
    name = "k8s.rules.container_cpu_limits"
    rules = [
      {
        name = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)
group_left() max by (namespace, pod, cluster) (
 (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
 )
EOT
          }
        }
      }
      {
        name = "namespace_cpu:kube_pod_container_resource_limits:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum by (namespace, cluster) (
    sum by (namespace, pod, cluster) (
        max by (namespace, pod, container, cluster) (
          kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}
        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
          kube_pod_status_phase{phase=~"Pending|Running"} == 1
        )
    )
)
EOT
          }
        }
      }
    ]
  }
  k8s_rules_pod_owner = {
    name = "k8s.rules.pod_owner"
    rules = [
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    label_replace(
      kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},
      "replicaset", "$1", "owner_name", "(.*)"
    ) * on (cluster, replicaset, namespace) group_left(owner_name) topk by(cluster, replicaset, namespace) (
      1, max by (cluster, replicaset, namespace, owner_name) (
        kube_replicaset_owner{job="kube-state-metrics", owner_kind=""}
      )
    ),
    "workload", "$1", "replicaset", "(.*)"
  )
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    label_replace(
      kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},
      "replicaset", "$1", "owner_name", "(.*)"
    ) * on(replicaset, namespace, cluster) group_left(owner_name) topk by(cluster, replicaset, namespace) (
      1, max by (cluster, replicaset, namespace, owner_name) (
        kube_replicaset_owner{job="kube-state-metrics", owner_kind="Deployment"}
      )
    ),
    "workload", "$1", "owner_name", "(.*)"
  )
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"},
    "workload", "$1", "owner_name", "(.*)"
  )
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"},
  "workload", "$1", "owner_name", "(.*)")
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
group by (cluster, namespace, workload, pod) (
  label_join(
    group by (cluster, namespace, job_name, pod, owner_name) (
      label_join(
        kube_pod_owner{job="kube-state-metrics", owner_kind="Job"}
      , "job_name", "", "owner_name")
    )
    * on (cluster, namespace, job_name) group_left()
    group by (cluster, namespace, job_name) (
      kube_job_owner{job="kube-state-metrics", owner_kind=~"Pod|"}
    )
  , "workload", "", "owner_name")
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    kube_pod_owner{job="kube-state-metrics", owner_kind="", owner_name=""},
  "workload", "$1", "pod", "(.+)")
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
max by (cluster, namespace, workload, pod) (
  label_replace(
    kube_pod_owner{job="kube-state-metrics", owner_kind="Node"},
  "workload", "$1", "pod", "(.+)")
)
EOT
          }
        }
      }
      {
        name = "namespace_workload_pod:kube_pod_owner:relabel"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
group by (cluster, namespace, workload, workload_type, pod) (
  label_join(
    label_join(
      group by (cluster, namespace, job_name, pod) (
        label_join(
          kube_pod_owner{job="kube-state-metrics", owner_kind="Job"}
        , "job_name", "", "owner_name")
      )
      * on (cluster, namespace, job_name) group_left(owner_kind, owner_name)
      group by (cluster, namespace, job_name, owner_kind, owner_name) (
        kube_job_owner{job="kube-state-metrics", owner_kind!="Pod", owner_kind!=""}
      )
    , "workload", "", "owner_name")
  , "workload_type", "", "owner_kind")
  
  OR

  label_replace(
    label_replace(
      label_replace(
        kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"}
        , "replicaset", "$1", "owner_name", "(.+)"
      )
      * on(cluster, namespace, replicaset) group_left(owner_kind, owner_name)
      group by (cluster, namespace, replicaset, owner_kind, owner_name) (
        kube_replicaset_owner{job="kube-state-metrics", owner_kind!="Deployment", owner_kind!=""}
      )
    , "workload", "$1", "owner_name", "(.+)")
    OR
    label_replace(
      group by (cluster, namespace, pod, owner_name, owner_kind) (
        kube_pod_owner{job="kube-state-metrics", owner_kind!="ReplicaSet", owner_kind!="DaemonSet", owner_kind!="StatefulSet", owner_kind!="Job", owner_kind!="Node", owner_kind!=""}
      )
      , "workload", "$1", "owner_name", "(.+)"
    )
  , "workload_type", "$1", "owner_kind", "(.+)")
)
EOT
          }
        }
      }
    ]
  }
  kube_scheduler_rules = {
    name = "kube-scheduler.rules"
    rules = [
      {
        name = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum(rate(scheduler_binding_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.9, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.9, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.9, sum(rate(scheduler_binding_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.5, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.5, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
      {
        name = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.5, sum(rate(scheduler_binding_duration_seconds_bucket{job=\"kube-scheduler\"}[5m])) without(instance, pod))"
          }
        }
      }
    ]
  }
  node_rules = {
    name = "node.rules"
    rules = [
      {
        name = "node_namespace_pod:kube_pod_info:"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
topk by(cluster, namespace, pod) (1,
  max by (cluster, node, namespace, pod) (
    label_replace(kube_pod_info{job="kube-state-metrics",node!=""}, "pod", "$1", "pod", "(.*)")
))
EOT
          }
        }
      }
      {
        name = "node:node_num_cpu:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
count by (cluster, node) (
  node_cpu_seconds_total{mode="idle",job="node-exporter"}
  * on (cluster, namespace, pod) group_left(node)
  topk by(cluster, namespace, pod) (1, node_namespace_pod:kube_pod_info:)
)
EOT
          }
        }
      }
      {
        name = ":node_memory_MemAvailable_bytes:sum"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
sum(
  node_memory_MemAvailable_bytes{job="node-exporter"} or
  (
    node_memory_Buffers_bytes{job="node-exporter"} +
    node_memory_Cached_bytes{job="node-exporter"} +
    node_memory_MemFree_bytes{job="node-exporter"} +
    node_memory_Slab_bytes{job="node-exporter"}
  )
) by (cluster)
EOT
          }
        }
      }
      {
        name = "node:node_cpu_utilization:ratio_rate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
avg by (cluster, node) (
  sum without (mode) (
    rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal",job="node-exporter"}[5m])
  )
)
EOT
          }
        }
      }
      {
        name = "cluster:node_cpu:ratio_rate5m"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = <<EOT
avg by (cluster) (
  node:node_cpu_utilization:ratio_rate5m
)
EOT
          }
        }
      }
    ]
  }
  kubelet_rules = {
    name = "kubelet.rules"
    rules = [
      {
        name = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.99, sum(rate(kubelet_pleg_relist_duration_seconds_bucket{job=\"kubelet\"}[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job=\"kubelet\"})"
          }
        }
      }
      {
        name = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.9, sum(rate(kubelet_pleg_relist_duration_seconds_bucket{job=\"kubelet\"}[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job=\"kubelet\"})"
          }
        }
      }
      {
        name = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
        condition = "A"
        data = {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to = 0
          }
          model = {
            expr = "histogram_quantile(0.5, sum(rate(kubelet_pleg_relist_duration_seconds_bucket{job=\"kubelet\"}[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job=\"kubelet\"})"
          }
        }
      }
    ]
  }
}
