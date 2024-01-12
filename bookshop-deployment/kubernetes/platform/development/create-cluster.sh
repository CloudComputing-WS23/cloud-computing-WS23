#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile bookshop

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

echo "\n⛵ Happy Sailing!\n"
