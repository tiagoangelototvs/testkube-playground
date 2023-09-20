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

		It("should have the total requests metric greater than 1", func() {
			query := "sum(increase(apiserver_request_total[5m]))"
			result, _, err := prometheus.Query(context.Background(), query, time.Now(), v1.WithTimeout(5*time.Second))
			Expect(err).NotTo(HaveOccurred())

			vector, ok := result.(model.Vector)
			Expect(ok).Should(BeTrue(), "The query result should be a sample vector")

			Expect(vector).Should(HaveLen(1))
			for _, sample := range vector {
				Expect(sample.Value).Should(BeNumerically(">", 1))
			}
		})
	})
})
