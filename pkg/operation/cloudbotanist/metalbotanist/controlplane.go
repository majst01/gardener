// Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package metalbotanist

import (
	"fmt"

	"github.com/gardener/gardener/pkg/operation/common"
)

const cloudProviderConfigTemplate = `
[Global]
auth-url=%q
domain-name=%q
tenant-name=%q
username=%q
password=%q
`

// GenerateCloudProviderConfig generates the Metal cloud provider config.
// See this for more details:
// https://github.com/kubernetes/kubernetes/blob/master/pkg/cloudprovider/providers/openstack/openstack.go
func (b *MetalBotanist) GenerateCloudProviderConfig() (string, error) {
	cloudProviderConfig := fmt.Sprintf(
		cloudProviderConfigTemplate,
		string(b.Shoot.Secret.Data[MetalAPIURL]),
		string(b.Shoot.Secret.Data[DomainName]),
		string(b.Shoot.Secret.Data[TenantName]),
		string(b.Shoot.Secret.Data[UserName]),
		string(b.Shoot.Secret.Data[Password]),
	)

	return cloudProviderConfig, nil
}

// RefreshCloudProviderConfig refreshes the cloud provider credentials in the existing cloud
// provider config.
func (b *MetalBotanist) RefreshCloudProviderConfig(currentConfig map[string]string) map[string]string {
	var (
		existing  = currentConfig[common.CloudProviderConfigMapKey]
		updated   = existing
		separator = "="
	)

	// FIXME metalapiurl ??
	// updated = common.ReplaceCloudProviderConfigKey(updated, separator, "auth-url", b.Shoot.CloudProfile.Spec.Metal.KeyStoneURL)
	updated = common.ReplaceCloudProviderConfigKey(updated, separator, "domain-name", string(b.Shoot.Secret.Data[DomainName]))
	updated = common.ReplaceCloudProviderConfigKey(updated, separator, "tenant-name", string(b.Shoot.Secret.Data[TenantName]))
	updated = common.ReplaceCloudProviderConfigKey(updated, separator, "username", string(b.Shoot.Secret.Data[UserName]))
	updated = common.ReplaceCloudProviderConfigKey(updated, separator, "password", string(b.Shoot.Secret.Data[Password]))

	return map[string]string{
		common.CloudProviderConfigMapKey: updated,
	}
}

// GenerateKubeAPIServerServiceConfig generates the cloud provider specific values which are required to render the
// Service manifest of the kube-apiserver-service properly.
func (b *MetalBotanist) GenerateKubeAPIServerServiceConfig() (map[string]interface{}, error) {
	return nil, nil
}

// GenerateKubeAPIServerExposeConfig defines the cloud provider specific values which configure how the kube-apiserver
// is exposed to the public.
func (b *MetalBotanist) GenerateKubeAPIServerExposeConfig() (map[string]interface{}, error) {
	return map[string]interface{}{
		"advertiseAddress": b.APIServerAddress,
		"additionalParameters": []string{
			fmt.Sprintf("--external-hostname=%s", b.APIServerAddress),
		},
	}, nil
}

// GenerateKubeAPIServerConfig generates the cloud provider specific values which are required to render the
// Deployment manifest of the kube-apiserver properly.
func (b *MetalBotanist) GenerateKubeAPIServerConfig() (map[string]interface{}, error) {
	return nil, nil
}

// GenerateCloudControllerManagerConfig generates the cloud provider specific values which are required to
// render the Deployment manifest of the cloud-controller-manager properly.
func (b *MetalBotanist) GenerateCloudControllerManagerConfig() (map[string]interface{}, string, error) {
	return nil, common.CloudControllerManagerDeploymentName + "-metal", nil
}

// GenerateCSIConfig generates the configuration for CSI charts
func (b *MetalBotanist) GenerateCSIConfig() (map[string]interface{}, error) {
	return nil, nil
}

// GenerateKubeControllerManagerConfig generates the cloud provider specific values which are required to
// render the Deployment manifest of the kube-controller-manager properly.
func (b *MetalBotanist) GenerateKubeControllerManagerConfig() (map[string]interface{}, error) {
	return map[string]interface{}{
		"enableCSI": true,
	}, nil
}

// GenerateKubeSchedulerConfig generates the cloud provider specific values which are required to render the
// Deployment manifest of the kube-scheduler properly.
func (b *MetalBotanist) GenerateKubeSchedulerConfig() (map[string]interface{}, error) {
	return nil, nil
}

// GenerateETCDStorageClassConfig generates values which are required to create etcd volume storageclass properly.
func (b *MetalBotanist) GenerateETCDStorageClassConfig() map[string]interface{} {
	// FIXME Metal ETC Storage Class
	return map[string]interface{}{
		"name":        "gardener.cloud-fast",
		"capacity":    "25Gi",
		"provisioner": "rancher.io/local-path", //  TODO: Just use default storage class?
		"parameters":  map[string]interface{}{},
	}
}

// GenerateEtcdBackupConfig returns the etcd backup configuration for the etcd Helm chart.
func (b *MetalBotanist) GenerateEtcdBackupConfig() (map[string][]byte, map[string]interface{}, error) {

	// FIXME

	//containerName := "containerName"
	//
	//tf, err := b.NewBackupInfrastructureTerraformer()
	//if err != nil {
	//	return nil, nil, err
	//}
	//
	//stateVariables, err := tf.GetStateOutputVariables(containerName)
	//if err != nil {
	//	return nil, nil, err
	//}
	//
	//secretData := map[string][]byte{
	//	UserName:   b.Seed.Secret.Data[UserName],
	//	Password:   b.Seed.Secret.Data[Password],
	//	TenantName: b.Seed.Secret.Data[TenantName],
	//	DomainName: b.Seed.Secret.Data[DomainName],
	//}
	//
	//backupConfigData := map[string]interface{}{
	//	"schedule":         b.Operation.ShootBackup.Schedule,
	//	"storageProvider":  "Swift",
	//	"storageContainer": stateVariables[containerName],
	//	"env": []map[string]interface{}{
	//		{
	//			"name": "OS_AUTH_URL",
	//			"valueFrom": map[string]interface{}{
	//				"secretKeyRef": map[string]interface{}{
	//					"name": common.BackupSecretName,
	//					"key":  AuthURL,
	//				},
	//			},
	//		},
	//		{
	//			"name": "OS_DOMAIN_NAME",
	//			"valueFrom": map[string]interface{}{
	//				"secretKeyRef": map[string]interface{}{
	//					"name": common.BackupSecretName,
	//					"key":  DomainName,
	//				},
	//			},
	//		},
	//		{
	//			"name": "OS_USERNAME",
	//			"valueFrom": map[string]interface{}{
	//				"secretKeyRef": map[string]interface{}{
	//					"name": common.BackupSecretName,
	//					"key":  UserName,
	//				},
	//			},
	//		},
	//		{
	//			"name": "OS_PASSWORD",
	//			"valueFrom": map[string]interface{}{
	//				"secretKeyRef": map[string]interface{}{
	//					"name": common.BackupSecretName,
	//					"key":  Password,
	//				},
	//			},
	//		},
	//		{
	//			"name": "OS_TENANT_NAME",
	//			"valueFrom": map[string]interface{}{
	//				"secretKeyRef": map[string]interface{}{
	//					"name": common.BackupSecretName,
	//					"key":  TenantName,
	//				},
	//			},
	//		},
	//	},
	//	"volumeMount": []map[string]interface{}{},
	//}
	//return secretData, backupConfigData, nil

	return nil, nil, nil
}

// DeployCloudSpecificControlPlane does currently nothing for Metal.
func (b *MetalBotanist) DeployCloudSpecificControlPlane() error {
	return nil
}
