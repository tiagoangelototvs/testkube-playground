resource "helm_release" "testkube" {
  repository = "https://kubeshop.github.io/helm-charts"
  chart      = "testkube"

  name    = "testkube"
  version = "1.15.26"

  namespace = kubernetes_namespace_v1.testkube.metadata[0].name

  values = [
    yamlencode({
      testkube-api = {
        uiIngress = {
          enabled   = true
          className = "nginx"
          path      = "/", hosts = ["testkube-api.${local.cluster_host}"]
        }
        jobServiceAccountName = kubernetes_service_account_v1.testkube_job.metadata[0].name
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

resource "kubernetes_service_account_v1" "testkube_job" {
  metadata {
    name      = "testkube-job"
    namespace = kubernetes_namespace_v1.testkube.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "testkube_job" {
  metadata { name = "testkube-job" }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "serviceaccounts"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["vault.banzaicloud.com"]
    resources  = ["vaults"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "testkube_job" {
  metadata { name = "testkube-job" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.testkube_job.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.testkube_job.metadata[0].name
    namespace = kubernetes_service_account_v1.testkube_job.metadata[0].namespace
  }
}

resource "kubernetes_namespace_v1" "testkube" {
  metadata { name = "testkube" }
}
