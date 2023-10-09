package running_pods_test

import (
	"context"
	"github.com/hashicorp/go-multierror"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"path"
)

var _ = Describe("Given Prometheus", func() {
	Context("When it is installed", func() {
		It("All pods should be in a running state", func() {
			config, err := loadRestConfig()
			Expect(err).NotTo(HaveOccurred())

			clientset, err := kubernetes.NewForConfig(config)
			Expect(err).NotTo(HaveOccurred())

			pods, err := clientset.CoreV1().Pods("prometheus").List(context.Background(), metav1.ListOptions{})
			Expect(err).NotTo(HaveOccurred())

			for _, pod := range pods.Items {
				Expect(pod.Status.Phase).Should(Equal(v1.PodRunning))
			}
		})
	})
})

func loadRestConfig() (*rest.Config, error) {
	var result error

	// Attempt to retrieve the Kubernetes cluster configuration first from the in-cluster environment
	config, err1 := rest.InClusterConfig()
	if err1 == nil {
		return config, nil
	}

	result = multierror.Append(result, err1)

	// If that doesn't work, try getting it locally using the kubeconfig file in your home directory
	homeDir, err2 := os.UserHomeDir()
	if err2 != nil {
		return nil, multierror.Append(result, err2)
	}

	config, err3 := clientcmd.BuildConfigFromFlags("", path.Join(homeDir, ".kube", "config"))
	if err3 != nil {
		return nil, multierror.Append(result, err3)
	}

	return config, nil
}
