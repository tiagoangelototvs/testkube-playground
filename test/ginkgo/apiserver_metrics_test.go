package ginkgo_test

import (
	"context"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"github.com/prometheus/client_golang/api"
	v1 "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
)

var _ = Describe("API server", func() {
	config := api.Config{Address: "http://prometheus-server.prometheus:80"}

	Context("when Prometheus is configured to scrape its metrics", func() {
		client, err := api.NewClient(config)
		Expect(err).NotTo(HaveOccurred())

		prometheus := v1.NewAPI(client)

		It("should have the total requests metric greater than 1", func(ctx SpecContext) {

			// the total count of successful API server requests in the last 5 minutes
			successfulAPIServerResponses := func() model.SampleValue {
				query := `sum(increase(apiserver_request_total{code=~"2.."}[5m]))`
				result, _, err := prometheus.Query(context.Background(), query, time.Now(), v1.WithTimeout(5*time.Second))
				if err != nil {
					return 0
				}

				var value model.SampleValue
				if vector, ok := result.(model.Vector); ok {
					for _, sample := range vector {
						value = sample.Value
						break
					}
				}

				return value
			}

			Eventually(successfulAPIServerResponses, ctx).Should(BeNumerically(">", 1))
		}, SpecTimeout(time.Second*5))
	})
})
