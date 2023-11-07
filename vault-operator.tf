resource "helm_release" "vault_operator" {
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "vault-operator"

  name    = "vault-operator"
  version = "1.19.0"

  namespace = kubernetes_namespace_v1.vault.metadata[0].name
}

resource "kubernetes_namespace_v1" "vault" {
  metadata { name = "vault" }
}
