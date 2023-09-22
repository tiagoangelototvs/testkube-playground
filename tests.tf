resource "kubectl_manifest" "test_source_testkube_playground" {
  yaml_body = <<-YAML
    apiVersion: tests.testkube.io/v1
    kind: TestSource
    metadata:
      name: testkube-playground
      namespace: ${kubernetes_namespace_v1.testkube.metadata[0].name}
    spec:
      repository:
        type: git
        uri: https://github.com/tiagoangelototvs/testkube-playground
  YAML

  depends_on = [helm_release.testkube]
}

resource "kubectl_manifest" "test_postman" {
  yaml_body = <<-YAML
    apiVersion: tests.testkube.io/v3
    kind: Test
    metadata:
      name: postman
      namespace: ${kubernetes_namespace_v1.testkube.metadata[0].name}
    spec:
      type: postman/collection
      source: testkube-playground
      content:
        repository:
          branch: main
          path: test/postman/apiserver-metrics/apiserver-metrics.postman_collection.json
  YAML

  depends_on = [
    helm_release.testkube,
    kubectl_manifest.test_source_testkube_playground,
  ]
}

resource "kubectl_manifest" "test_ginkgo" {
  yaml_body = <<-YAML
    apiVersion: tests.testkube.io/v3
    kind: Test
    metadata:
      name: ginkgo
      namespace: ${kubernetes_namespace_v1.testkube.metadata[0].name}
    spec:
      type: ginkgo/test
      source: testkube-playground
      content:
        repository:
          branch: main
          path: test/ginkgo/apiserver-metrics
  YAML

  depends_on = [
    helm_release.testkube,
    kubectl_manifest.test_source_testkube_playground,
  ]
}
