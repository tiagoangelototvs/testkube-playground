resource "helm_release" "testkube" {
  repository = "https://kubeshop.github.io/helm-charts"
  chart      = "testkube"

  name    = "testkube"
  version = "1.14.10"

  namespace = kubernetes_namespace_v1.testkube.metadata[0].name

  values = [
    yamlencode({
      testkube-api = {
        uiIngress = {
          enabled   = true
          className = "nginx"
          path      = "/", hosts = ["testkube-api.${local.cluster_host}"]
        }
      }
      testkube-dashboard = {
        ingress = {
          enabled   = true
          className = "nginx"
          path      = "/", hosts = ["testkube.${local.cluster_host}"]
        }
        apiServerEndpoint = "testkube-api.${local.cluster_host}"
      }
    })
  ]

  depends_on = [helm_release.ingress_nginx]
}

resource "kubernetes_namespace_v1" "testkube" {
  metadata { name = "testkube" }
}
