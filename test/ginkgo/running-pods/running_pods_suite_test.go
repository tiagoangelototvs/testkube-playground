package running_pods_test

import (
	"runtime"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func TestRunningPods(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "RunningPods Suite")
}

var _ = BeforeSuite(func() {
	GinkgoWriter.Printf("Go version: %s\n", runtime.Version())
})
