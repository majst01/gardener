# Allow Tiller and Dashboard to run in RBAC mode
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default


kind create cluster --name gardener
export KUBECONFIG="$(kind get kubeconfig-path --name="gardener")"

# Create tiller service account
kubectl -n kube-system create serviceaccount tiller

# Create cluster role binding for tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

echo "initializing helm"
helm init --service-account tiller --wait --history-max 200

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

kind load docker-image --name gardener eu.gcr.io/gardener-project/gardener/apiserver:${GARDENER_RELEASE}
kind load docker-image --name gardener eu.gcr.io/gardener-project/gardener/controller-manager:${GARDENER_RELEASE}
kind load docker-image --name gardener eu.gcr.io/gardener-project/gardener/machine-controller-manager:${MACHINE_CONTROLLER_RELEASE}

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


# beware: save your old kubeconfig
cp /home/stefan/.kube/kind-config-gardener /home/stefan/.kube/config

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
