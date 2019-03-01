// Code generated by informer-gen. DO NOT EDIT.

package v1alpha1

import (
	time "time"

	versioned "github.com/gardener/gardener/pkg/client/machine/clientset/versioned"
	internalinterfaces "github.com/gardener/gardener/pkg/client/machine/informers/externalversions/internalinterfaces"
	v1alpha1 "github.com/gardener/gardener/pkg/client/machine/listers/machine/v1alpha1"
	machinev1alpha1 "github.com/gardener/machine-controller-manager/pkg/apis/machine/v1alpha1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	runtime "k8s.io/apimachinery/pkg/runtime"
	watch "k8s.io/apimachinery/pkg/watch"
	cache "k8s.io/client-go/tools/cache"
)

// MetalMachineClassInformer provides access to a shared informer and lister for
// MetalMachineClasses.
type MetalMachineClassInformer interface {
	Informer() cache.SharedIndexInformer
	Lister() v1alpha1.MetalMachineClassLister
}

type metalMachineClassInformer struct {
	factory          internalinterfaces.SharedInformerFactory
	tweakListOptions internalinterfaces.TweakListOptionsFunc
	namespace        string
}

// NewMetalMachineClassInformer constructs a new informer for MetalMachineClass type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewMetalMachineClassInformer(client versioned.Interface, namespace string, resyncPeriod time.Duration, indexers cache.Indexers) cache.SharedIndexInformer {
	return NewFilteredMetalMachineClassInformer(client, namespace, resyncPeriod, indexers, nil)
}

// NewFilteredMetalMachineClassInformer constructs a new informer for MetalMachineClass type.
// Always prefer using an informer factory to get a shared informer instead of getting an independent
// one. This reduces memory footprint and number of connections to the server.
func NewFilteredMetalMachineClassInformer(client versioned.Interface, namespace string, resyncPeriod time.Duration, indexers cache.Indexers, tweakListOptions internalinterfaces.TweakListOptionsFunc) cache.SharedIndexInformer {
	return cache.NewSharedIndexInformer(
		&cache.ListWatch{
			ListFunc: func(options v1.ListOptions) (runtime.Object, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.MachineV1alpha1().MetalMachineClasses(namespace).List(options)
			},
			WatchFunc: func(options v1.ListOptions) (watch.Interface, error) {
				if tweakListOptions != nil {
					tweakListOptions(&options)
				}
				return client.MachineV1alpha1().MetalMachineClasses(namespace).Watch(options)
			},
		},
		&machinev1alpha1.MetalMachineClass{},
		resyncPeriod,
		indexers,
	)
}

func (f *metalMachineClassInformer) defaultInformer(client versioned.Interface, resyncPeriod time.Duration) cache.SharedIndexInformer {
	return NewFilteredMetalMachineClassInformer(client, f.namespace, resyncPeriod, cache.Indexers{cache.NamespaceIndex: cache.MetaNamespaceIndexFunc}, f.tweakListOptions)
}

func (f *metalMachineClassInformer) Informer() cache.SharedIndexInformer {
	return f.factory.InformerFor(&machinev1alpha1.MetalMachineClass{}, f.defaultInformer)
}

func (f *metalMachineClassInformer) Lister() v1alpha1.MetalMachineClassLister {
	return v1alpha1.NewMetalMachineClassLister(f.Informer().GetIndexer())
}
