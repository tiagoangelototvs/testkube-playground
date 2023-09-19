#!/usr/bin/env bash

# Creating a Test with Git file
kubectl testkube create test \
  --name "postman-test" \
  --type "postman/collection" \
  --test-content-type "git-file" \
  --git-uri "https://github.com/tiagoangelototvs/testkube-playground" \
  --git-branch "main" \
  --git-path "test/postman/apiserver-metrics.postman_collection.json"

# Running a Test
kubectl testkube run test -l "test-type=postman-collection"

# Listing executions
kubectl testkube get executions

# Watching an execution
kubectl testkube watch execution "postman-test-1"
