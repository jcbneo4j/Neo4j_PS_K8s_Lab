
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d cluster create --config cluster-config.yml


helm repo add neo4j https://helm.neo4j.com/neo4j
helm repo update

kubectl create namespace neo4j
kubectl config set-context --current --namespace=neo4j
