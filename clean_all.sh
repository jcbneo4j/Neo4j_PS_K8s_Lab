k3d cluster delete neo4jcluster

./install.sh

helm repo add neo4j https://helm.neo4j.com/neo4j
helm repo update

kubectl create namespace neo4j
kubectl config set-context --current --namespace=neo4j

