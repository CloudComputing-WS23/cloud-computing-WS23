@echo off
minikube start --no-vtx-check --profile bookshop
minikube addons enable ingress --profile bookshop
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\postgresql.yml
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\redis.yml
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\rabbitmq.yml
kubectl apply -f .\catalog-service\k8s\deployment.yml
kubectl apply -f .\catalog-service\k8s\service.yml
kubectl apply -f .\config-service\k8s\deployment.yml
kubectl apply -f .\config-service\k8s\service.yml
kubectl apply -f .\dispatcher-service\k8s\deployment.yml
kubectl apply -f .\dispatcher-service\k8s\service.yml
kubectl apply -f .\edge-service\k8s\deployment.yml
kubectl apply -f .\edge-service\k8s\service.yml
kubectl apply -f .\edge-service\k8s\ingress.yml
kubectl apply -f .\order-service\k8s\deployment.yml
kubectl apply -f .\order-service\k8s\service.yml