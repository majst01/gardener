/*
Copyright (c) 2019 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by client-gen. DO NOT EDIT.

package fake

import (
	v1alpha1 "github.com/gardener/machine-controller-manager/pkg/apis/machine/v1alpha1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	labels "k8s.io/apimachinery/pkg/labels"
	schema "k8s.io/apimachinery/pkg/runtime/schema"
	types "k8s.io/apimachinery/pkg/types"
	watch "k8s.io/apimachinery/pkg/watch"
	testing "k8s.io/client-go/testing"
)

// FakeMetalMachineClasses implements MetalMachineClassInterface
type FakeMetalMachineClasses struct {
	Fake *FakeMachineV1alpha1
	ns   string
}

var metalmachineclassesResource = schema.GroupVersionResource{Group: "machine.sapcloud.io", Version: "v1alpha1", Resource: "metalmachineclasses"}

var metalmachineclassesKind = schema.GroupVersionKind{Group: "machine.sapcloud.io", Version: "v1alpha1", Kind: "MetalMachineClass"}

// Get takes name of the metalMachineClass, and returns the corresponding metalMachineClass object, and an error if there is any.
func (c *FakeMetalMachineClasses) Get(name string, options v1.GetOptions) (result *v1alpha1.MetalMachineClass, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewGetAction(metalmachineclassesResource, c.ns, name), &v1alpha1.MetalMachineClass{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.MetalMachineClass), err
}

// List takes label and field selectors, and returns the list of MetalMachineClasses that match those selectors.
func (c *FakeMetalMachineClasses) List(opts v1.ListOptions) (result *v1alpha1.MetalMachineClassList, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewListAction(metalmachineclassesResource, metalmachineclassesKind, c.ns, opts), &v1alpha1.MetalMachineClassList{})

	if obj == nil {
		return nil, err
	}

	label, _, _ := testing.ExtractFromListOptions(opts)
	if label == nil {
		label = labels.Everything()
	}
	list := &v1alpha1.MetalMachineClassList{ListMeta: obj.(*v1alpha1.MetalMachineClassList).ListMeta}
	for _, item := range obj.(*v1alpha1.MetalMachineClassList).Items {
		if label.Matches(labels.Set(item.Labels)) {
			list.Items = append(list.Items, item)
		}
	}
	return list, err
}

// Watch returns a watch.Interface that watches the requested metalMachineClasses.
func (c *FakeMetalMachineClasses) Watch(opts v1.ListOptions) (watch.Interface, error) {
	return c.Fake.
		InvokesWatch(testing.NewWatchAction(metalmachineclassesResource, c.ns, opts))

}

// Create takes the representation of a metalMachineClass and creates it.  Returns the server's representation of the metalMachineClass, and an error, if there is any.
func (c *FakeMetalMachineClasses) Create(metalMachineClass *v1alpha1.MetalMachineClass) (result *v1alpha1.MetalMachineClass, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewCreateAction(metalmachineclassesResource, c.ns, metalMachineClass), &v1alpha1.MetalMachineClass{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.MetalMachineClass), err
}

// Update takes the representation of a metalMachineClass and updates it. Returns the server's representation of the metalMachineClass, and an error, if there is any.
func (c *FakeMetalMachineClasses) Update(metalMachineClass *v1alpha1.MetalMachineClass) (result *v1alpha1.MetalMachineClass, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewUpdateAction(metalmachineclassesResource, c.ns, metalMachineClass), &v1alpha1.MetalMachineClass{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.MetalMachineClass), err
}

// Delete takes name of the metalMachineClass and deletes it. Returns an error if one occurs.
func (c *FakeMetalMachineClasses) Delete(name string, options *v1.DeleteOptions) error {
	_, err := c.Fake.
		Invokes(testing.NewDeleteAction(metalmachineclassesResource, c.ns, name), &v1alpha1.MetalMachineClass{})

	return err
}

// DeleteCollection deletes a collection of objects.
func (c *FakeMetalMachineClasses) DeleteCollection(options *v1.DeleteOptions, listOptions v1.ListOptions) error {
	action := testing.NewDeleteCollectionAction(metalmachineclassesResource, c.ns, listOptions)

	_, err := c.Fake.Invokes(action, &v1alpha1.MetalMachineClassList{})
	return err
}

// Patch applies the patch and returns the patched metalMachineClass.
func (c *FakeMetalMachineClasses) Patch(name string, pt types.PatchType, data []byte, subresources ...string) (result *v1alpha1.MetalMachineClass, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewPatchSubresourceAction(metalmachineclassesResource, c.ns, name, pt, data, subresources...), &v1alpha1.MetalMachineClass{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.MetalMachineClass), err
}