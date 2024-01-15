#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile bookshop

echo "\n📦 Get Kubernetes cluster ip and set the context to bookshop ...\n"

minikube ip --profile bookshop
kubectl config use-context bookshop
minikube tunnel --profile bookshop

echo "\n🔌 Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile bookshop

sleep 15

echo "\n📦 Deploying PostgreSQL..."

kubectl apply -f  bookshop-deployment/kubernetes/platform/development/services/postgresql.yml

sleep 5

echo "\n⌛ Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=bookshop-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-postgres \
  --timeout=180s

echo "\n📦 Deploying Redis..."

kubectl apply -f  bookshop-deployment/kubernetes/platform/development/services/redis.yml

sleep 5

echo "\n⌛ Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=bookshop-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-redis \
  --timeout=180s

echo "\n📦 Deploying RabbitMQ..."

kubectl apply -f  bookshop-deployment/kubernetes/platform/development/services/rabbitmq.yml

sleep 5

echo "\n⌛ Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=bookshop-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=bookshop-rabbitmq \
  --timeout=180s

echo "\n📦 Deploying Jaeger Operator ..."

kubectl create -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.53.0/jaeger-operator.yaml
kubectl get deployment jaeger-operator

echo "\n📦 Deploying the AllInOne image of Jaeger..."

kubectl apply -f bookshop-deployment/kubernetes/platform/development/services/jaeger.yaml

sleep 5

echo "\n⌛ Waiting for Jaeger to be deployed..."

while [ $(kubectl get pods -l app.kubernetes.io/instance=jaeger | wc -l) -eq 0 ] ; do
  sleep 5
done

helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator/
helm install opensearch-operator opensearch-operator/opensearch-operator

echo "\n⛵ Happy Sailing!\n"
