minikube start \
  --vm-driver kvm2 \
  --memory=8192 \
  --cpus=4 \
  --extra-config=apiserver.authorization-mode=RBAC

# Allow Tiller and Dashboard to run in RBAC mode
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

echo "initializing helm"
helm init --wait --history-max 200

kubectl apply -f example/00-namespace-garden.yaml
kubectl get pods --all-namespaces

echo "install ingress"
helm upgrade \
    --install \
    --namespace kube-system \
    nginx-ingress stable/nginx-ingress
echo "install etcd-backup"
helm upgrade \
    --install \
    --set tls= \
    --namespace garden \
    etcd ~/dev/etcd-backup-restore/chart


# This points docker to push images to the docker daemon inside minikube
eval $(minikube docker-env)


# build gardener images --> pushed to docker daemon inside minikube
make docker-images 


# build machine-controller-manager image --> pushed to docker daemon inside minikube
cd ~/go/src/github.com/gardener/machine-controller-manager \
    && make docker-images \
    && cd -

GARDENER_RELEASE=0.23.0-dev
MACHINE_CONTROLLER_RELEASE=0.19.0-dev

cat <<EOF > gardener-values.yaml
global:
  apiserver:
    image:
      tag: ${GARDENER_RELEASE:?"GARDENER_RELEASE is missing"}
    etcd:
      servers: http://etcd-for-test-client:2379
      useSidecar: false
  controller:
    image:
      tag: ${GARDENER_RELEASE:?"GARDENER_RELEASE is missing"}
  machine-controller:
    image:
      tag: ${MACHINE_CONTROLLER_RELEASE:?"MACHINE_CONTROLLER_RELEASE is missing"}
EOF

helm upgrade garden charts/gardener \
  --install \
  --namespace garden \
  --values=charts/gardener/values.yaml \
  --values=charts/gardener/local-values.yaml \
  --values gardener-values.yaml

kubectl apply -f example/30-cloudprofile-metal.yaml
kubectl describe -f example/30-cloudprofile-metal.yaml


KUBECONFIG_BASE64=$(kubectl config view --flatten=true | base64 -w 0)
METAL_API_URL=$(echo metal.test.fi-ts.io | base64)
METAL_API_KEY=$(echo "your secret metal api token" | base64)
cat <<EOF > example/40-secret-seed-metal.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: seed-metal
  namespace: garden
type: Opaque
data:
  metalAPIURL: ${METAL_API_URL}
  metalAPIKey: ${METAL_API_KEY}
  kubeconfig: ${KUBECONFIG_BASE64}
EOF

kubectl apply -f example/40-secret-seed-metal.yaml
kubectl apply -f example/50-seed-metal.yaml

gardenctl target garden dev
kubectl get seed metal
gardenctl ls seeds

kubectl get seed metal -o json | jq .status

# Create a namespace for the first shoot cluster (control-plane is running in a namespace of the seed cluster)
kubectl apply -f example/00-namespace-garden-dev.yaml
kubectl apply -f example/05-project-dev.yaml

gardenctl target garden dev
kubectl get project dev
kubectl get ns garden-dev
gardenctl ls projects

cat <<EOF > example/70-secret-cloudprovider-metal.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: core-metal
  namespace: garden-dev
  labels:
    cloudprofile.garden.sapcloud.io/name: metal # label is only meaningful for Gardener dashboard
type: Opaque
data:
  metalAPIURL: ${METAL_API_URL}
  metalAPIKey: ${METAL_API_KEY}
EOF

kubectl apply -f example/70-secret-cloudprovider-metal.yaml
kubectl apply -f example/80-secretbinding-cloudprovider-metal.yaml


sed -i -e "s/provider: aws-route53/provider: unmanaged/" example/90-shoot-metal.yaml
kubectl apply -f example/90-shoot-metal.yaml



```
garden gardener-controller-manager-f8997db45-kk6rh gardener-controller-manager time="2019-05-27T13:46:43Z" level=error msg="Could not initialize Shoot client for health check: secrets \"gardener\" not found" shoot=garden-dev/johndoe-metal
garden gardener-controller-manager-f8997db45-kk6rh gardener-controller-manager time="2019-05-27T13:46:43Z" level=error msg="Could not initialize Shoot client for garbage collection of shoot garden-dev/johndoe-metal: secrets \"gardener\" not found" shoot=garden-dev/johndoe-metal
garden gardener-controller-manager-f8997db45-kk6rh gardener-controller-manager time="2019-05-27T13:46:43Z" level=error msg="Attempt 1 failed to update Shoot garden-dev/johndoe-metal due to Operation cannot be fulfilled on shoots.garden.sapcloud.io \"johndoe-metal\": the object has been modified; please apply your changes to the latest version and try again"                                                              
```
