resource "kubectl_manifest" "test_postman_test" {
  yaml_body = <<-YAML
    apiVersion: tests.testkube.io/v3
    kind: Test
    metadata:
      name: postman-test
      namespace: ${kubernetes_namespace_v1.testkube.metadata[0].name}
      labels:
        executor: postman-executor
        test-type: postman-collection
    spec:
      type: postman/collection
      content:
        type: git-file
        repository:
          uri: https://github.com/tiagoangelototvs/testkube-playground
          path: test/postman/apiserver-metrics.postman_collection.json
          branch: main
  YAML

  depends_on = [helm_release.testkube]
}
