module github.com/gardener/gardener

go 1.13

require (
	github.com/Masterminds/goutils v1.1.0 // indirect
	github.com/Masterminds/semver v1.4.2
	github.com/Masterminds/sprig v2.22.0+incompatible // indirect
	github.com/ahmetb/gen-crd-api-reference-docs v0.1.5
	github.com/coreos/etcd v3.3.15+incompatible
	github.com/cyphar/filepath-securejoin v0.2.2 // indirect
	github.com/dsnet/compress v0.0.1 // indirect
	github.com/elazarl/goproxy v0.0.0-20191011121108-aa519ddbe484 // indirect
	github.com/frankban/quicktest v1.5.0 // indirect
	github.com/gardener/controller-manager-library v0.1.1-0.20191212112146-917449ad760c // indirect
	github.com/gardener/external-dns-management v0.7.3
	github.com/gardener/gardener-resource-manager v0.9.1-0.20200124091350-6ea41bbae81f
	github.com/gardener/hvpa-controller v0.0.0-20191014062307-fad3bdf06a25
	github.com/ghodss/yaml v1.0.0
	github.com/go-openapi/spec v0.19.2
	github.com/gobwas/glob v0.2.3 // indirect
	github.com/golang/mock v1.3.1
	github.com/golang/snappy v0.0.1 // indirect
	github.com/googleapis/gnostic v0.3.1
	github.com/grpc-ecosystem/grpc-gateway v1.11.3 // indirect
	github.com/hashicorp/go-multierror v1.0.0
	github.com/huandu/xstrings v1.3.0 // indirect
	github.com/json-iterator/go v1.1.7
	github.com/mholt/archiver v3.1.1+incompatible
	github.com/mitchellh/copystructure v1.0.0 // indirect
	github.com/nwaples/rardecode v1.0.0 // indirect
	github.com/onsi/ginkgo v1.8.0
	github.com/onsi/gomega v1.5.0
	github.com/pierrec/lz4 v2.3.0+incompatible // indirect
	github.com/pkg/errors v0.8.1
	github.com/prometheus/client_golang v1.1.0
	github.com/prometheus/common v0.6.0
	github.com/robfig/cron v1.2.0
	github.com/sirupsen/logrus v1.4.2
	github.com/spf13/cobra v0.0.5
	github.com/spf13/pflag v1.0.5
	github.com/spf13/viper v1.6.1
	github.com/xi2/xz v0.0.0-20171230120015-48954b6210f8 // indirect
	go.uber.org/zap v1.10.0
	golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
	golang.org/x/lint v0.0.0-20190409202823-959b441ac422
	google.golang.org/grpc v1.23.0
	gopkg.in/yaml.v2 v2.2.4
	k8s.io/api v0.0.0
	k8s.io/apiextensions-apiserver v0.0.0
	k8s.io/apimachinery v0.0.0
	k8s.io/apiserver v0.0.0
	k8s.io/client-go v0.0.0
	k8s.io/cluster-bootstrap v0.0.0
	k8s.io/code-generator v0.0.0
	k8s.io/component-base v0.0.0
	k8s.io/helm v2.14.2+incompatible
	k8s.io/klog v1.0.0
	k8s.io/kube-aggregator v0.0.0
	k8s.io/kube-openapi v0.0.0
	k8s.io/metrics v0.0.0
	k8s.io/utils v0.0.0
	sigs.k8s.io/controller-runtime v0.4.0
	sigs.k8s.io/yaml v1.1.0
)

replace (
	github.com/prometheus/client_golang => github.com/prometheus/client_golang v0.9.2
	k8s.io/api => k8s.io/api v0.16.0
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.16.0
	k8s.io/apimachinery => k8s.io/apimachinery v0.16.0
	k8s.io/apiserver => k8s.io/apiserver v0.16.0
	k8s.io/client-go => k8s.io/client-go v0.16.0
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.16.0
	k8s.io/code-generator => k8s.io/code-generator v0.16.0
	k8s.io/component-base => k8s.io/component-base v0.16.0
	k8s.io/helm => k8s.io/helm v2.13.1+incompatible
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.16.0
	k8s.io/kube-openapi => k8s.io/kube-openapi v0.16.0
)
