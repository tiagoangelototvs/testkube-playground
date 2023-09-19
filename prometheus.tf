resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  name       = "prometheus"
  version    = "25.0.0"

  namespace  = kubernetes_namespace_v1.prometheus.metadata[0].name

  values = [
    yamlencode({
      prometheus-node-exporter = { enabled = false }
      kube-state-metrics       = { enabled = false }
      prometheus-pushgateway   = { enabled = false }
      alertmanager             = { enabled = false }
      serverFiles              = { "prometheus.yml" = { scrape_configs = [] } }
      server                   = {
        ingress    = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "nginx" }
      }
    })
  ]

  depends_on = [helm_release.ingress_nginx]
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}
