resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  name    = "grafana"
  version = "7.0.6"

  namespace = kubernetes_namespace_v1.grafana.metadata[0].name

  values = [
    yamlencode({
      ingress = { enabled = true, hosts = ["grafana.${local.cluster_host}"], ingressClassName = "nginx" }
      admin   = { existingSecret = kubernetes_secret_v1.grafana_credentials.metadata[0].name }
      "grafana.ini" = {
        "auth.anonymous" = {
          enabled  = true
          org_name = "Main Org."
          org_role = "Viewer"
        }
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}:80"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              disableDeletion = false
              editable        = true
              folder          = ""
              name            = "default"
              options         = { path = "/var/lib/grafana/dashboards/default" }
              orgId           = 1
              type            = "file"
            },
          ]
        }
      }
      dashboardsConfigMaps = { default = kubernetes_config_map_v1.grafana_dashboards.metadata[0].name }
    })
  ]

  depends_on = [helm_release.ingress_nginx]
}

resource "kubernetes_secret_v1" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  data = {
    admin-user     = "admin"
    admin-password = "admin"
  }
}

resource "kubernetes_config_map_v1" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  binary_data = {
    "cardinality-explorer.json"   = filebase64("dashboards/cardinality-explorer.json")
    "kubernetes-pod-metrics.json" = filebase64("dashboards/kubernetes-pod-metrics.json")
  }
}

resource "kubernetes_namespace_v1" "grafana" {
  metadata { name = "grafana" }
}
