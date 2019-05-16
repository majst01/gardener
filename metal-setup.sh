minikube start \
    --vm-driver kvm2 \
    --memory=8192 \
    --cpus=4

echo "Waiting for minikube to be ready"
timeout --foreground 180 bash -c 'until [ "$(kubectl get pods --all-namespaces)" != "" ]; do echo -n "." && sleep 3; done'

helm init --history-max 200
echo "Waiting for tiller to be ready"
timeout --foreground 180 bash -c 'until [ "$(helm status)" != "release name is required" ]; do echo -n "." && sleep 3; done'


kubectl apply -f example/00-namespace-garden.yaml
kubectl get pods --all-namespaces
helm upgrade \
    --install \
    --namespace kube-system \
    nginx-ingress stable/nginx-ingress
helm upgrade \
    --install \
    --set tls= \
    --namespace garden \
    etcd ~/dev/etcd-backup-restore/chart
eval $(minikube docker-env)

# build gardener images
make docker-images 

# build machine-controller-manager image
cd ~/go/src/github.com/gardener/machine-controller-manager \
    && make docker-images \
    && cd -

GARDENER_RELEASE=0.23.0-dev
MACHINE_CONTROLLER_RELEASE=0.18.0-dev
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

helm upgrade \
    --install \
    --namespace garden \
    garden charts/gardener \
    -f charts/gardener/local-values.yaml \
    -f gardener-values.yaml

kubectl apply -f example/30-cloudprofile-metal.yaml
kubectl describe -f example/30-cloudprofile-metal.yaml


KUBECONFIG=$(kubectl config view --flatten=true | base64 -w 0)
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
  kubeconfig: ${KUBECONFIG}
EOF

kubectl apply -f example/40-secret-seed-metal.yaml
kubectl apply -f example/50-seed-metal.yaml

gardenctl target garden dev
kubectl get seed metal
gardenctl ls seeds

kubectl get seed metal -o json | jq .status

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
