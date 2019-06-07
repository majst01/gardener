#!/usr/bin/env bash
# based on https://github.com/gardener/gardener/blob/master/docs/deployment/aks.md

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GO111MODULE=off
GOPATH=${GOPATH-~}

echo "Installing tools to ~/bin, please add this to your PATH"

mkdir -p ~/bin ~/.garden gen

if [[ $# -ge 1 && $1 == "reinstall-tools" ]]; then
    sudo rm -f $(which minikube)
    sudo rm -f $(which gardenctl)
    sudo rm -f $(which kubectl)
    sudo rm -f $(which helm)
    sudo rm -f $(which stern)
fi

if ! which minikube >/dev/null; then
  curl -LSs https://storage.googleapis.com/minikube/releases/v1.1.0/minikube-linux-amd64 -o ~/bin/minikube
  chmod +x ~/bin/minikube
fi

if ! which gardenctl >/dev/null; then
  curl -LSs https://github.com/gardener/gardenctl/releases/download/0.10.0/gardenctl-linux-amd64 -o ~/bin/gardenctl
  chmod +x ~/bin/gardenctl
fi

if ! which kubectl >/dev/null; then
  curl -LSs https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o ~/bin/kubectl
  chmod +x ~/bin/kubectl
fi

if ! which helm >/dev/null; then
  curl -LSs https://get.helm.sh/helm-v2.14.0-linux-amd64.tar.gz -o helm.tar.gz
  tar xvf helm.tar.gz --strip-components 1 -C ~/bin linux-amd64/helm
  rm helm.tar.gz
fi

if ! which yaml2json >/dev/null; then
  go get github.com/bronze1man/yaml2json
fi

if ! which jq >/dev/null; then
  sudo apt install -y jq
fi

if ! which virsh >/dev/null; then
  sudo apt install -y libvirt-bin libvirt-doc
fi

if ! which docker-machine-driver-kvm2 >/dev/null; then
  sudo apt install -y libvirt-clients libvirt-daemon-system qemu-kvm
  curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
  sudo install docker-machine-driver-kvm2 /usr/local/bin/
  rm -f docker-machine-driver-kvm2
  set +e
  sudo systemctl enable libvirtd.service
  sudo systemctl start libvirtd.service
  sudo usermod -a -G libvirt $(whoami)
  newgrp libvirt
  set -e
fi

# optional
if ! which stern >/dev/null; then
  curl -LSs https://github.com/wercker/stern/releases/download/1.10.0/stern_linux_amd64 -o ~/bin/stern
  chmod +x ~/bin/stern
fi

echo "Cloning projects to parent-dir"

if [[ ! -d "$DIR/../etcd-backup-restore" ]]; then
  cd ..
  git clone https://github.com/gardener/etcd-backup-restore.git
  cd ${DIR}
fi

if [[ ! -d "$DIR/../machine-controller-manager" ]]; then
  cd ..
  git clone https://github.com/majst01/machine-controller-manager.git
  cd ${DIR}
fi

cd ../machine-controller-manager
git checkout metal-driver
cd ${DIR}

echo "Starting minikube"
set +e
minikube delete
set -e

minikube start \
  --vm-driver kvm2 \
  --memory=8192 \
  --cpus=4 \
  --extra-config=apiserver.authorization-mode=RBAC

# Allow Tiller and Dashboard to run in RBAC mode
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

echo "Initializing helm"
helm init --wait --history-max 200

kubectl apply -f example/00-namespace-garden.yaml
kubectl apply -f example/10-secret-internal-domain-unmanaged.yaml

kubectl get pods --all-namespaces

echo "Installing metallb"
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml

cat <<EOF > gen/metallb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.222.0.1-10.222.0.10
EOF
kubectl apply -f gen/metallb-config.yaml

echo "Installing nginx-ingress"
helm upgrade \
    --install \
    --namespace kube-system \
    --wait \
    nginx-ingress stable/nginx-ingress

echo "Installing etcd-backup"
helm upgrade \
    --install \
    --set tls= \
    --namespace garden \
    --wait \
    etcd ${DIR}/../etcd-backup-restore/chart

# This points docker to push images to the docker daemon inside minikube
eval $(minikube docker-env)

echo "Building gardener images --> will be pushed to docker daemon inside minikube"
make docker-images

echo "Building machine-controller-manager image --> will be pushed to docker daemon inside minikube"
cd ../machine-controller-manager \
    && hack/generate-code \
    && make build docker-images
cd ${DIR}

GARDENER_RELEASE=0.23.0-dev
MACHINE_CONTROLLER_RELEASE=0.19.0-dev

cat <<EOF > gen/gardener-values.yaml
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

echo "Installing gardener"
helm upgrade \
    --install \
    --namespace garden \
    --values=charts/gardener/values.yaml \
    --values=charts/gardener/local-values.yaml \
    --values gen/gardener-values.yaml \
    --wait \
    garden charts/gardener

kubectl delete secret -n garden internal-domain

kubectl wait -n kube-system pod --all --for condition=ready --timeout=60s
kubectl wait -n garden pod --all --for condition=ready --timeout=60s

kubectl apply -f example/30-cloudprofile-metal.yaml
kubectl describe -f example/30-cloudprofile-metal.yaml

KUBECONFIG_BASE64=$(kubectl config view --flatten=true | base64 -w 0)
METAL_API_URL=$(echo http://metal.test.fi-ts.io | base64)
METAL_API_KEY=$(echo "your secret metal api token" | base64)
cat <<EOF > gen/40-secret-seed-metal.yaml
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

kubectl apply -f gen/40-secret-seed-metal.yaml

kubectl apply -f example/50-seed-metal.yaml
kubectl wait -f example/50-seed-metal.yaml --for condition=available --timeout=20s
kubectl get seed metal -o json | jq .status

echo "Creating a namespace for the first shoot cluster (control-plane is running in a namespace of the seed cluster)"
kubectl apply -f example/00-namespace-garden-dev.yaml
kubectl apply -f example/05-project-dev.yaml

cat <<EOF > ~/.garden/config
---
gardenClusters:
- name: dev
  kubeConfig: ~/.kube/config
EOF

gardenctl ls seeds

gardenctl target garden dev
kubectl get project dev
kubectl get ns garden-dev
gardenctl ls projects

cat <<EOF > gen/70-secret-cloudprovider-metal.yaml
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

kubectl apply -f gen/70-secret-cloudprovider-metal.yaml

kubectl apply -f example/80-secretbinding-cloudprovider-metal.yaml

hack/dev-setup-extensions-os-coreos

kubectl apply -f example/100-operatingsystemconfig-metal.yaml

echo "Creating shoot"
kubectl apply -f example/90-shoot-metal.yaml

# look for logs with
gardenctl ls issues
kubectl -n garden logs -f deployment/gardener-controller-manager
