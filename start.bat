@echo off
REM prerequisites minikube
minikube start
minikube addons enable ingress
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\postgresql.yml
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\redis.yml
kubectl apply -f .\bookshop-deployment\kubernetes\platform\development\services\rabbitmq.yml
kubectl apply -f .\catalog-service\k8s\deployment.yml
kubectl apply -f .\catalog-service\k8s\service.yml
kubectl apply -f .\dispatcher-service\k8s\deployment.yml
kubectl apply -f .\dispatcher-service\k8s\service.yml
kubectl apply -f .\edge-service\k8s\deployment.yml
kubectl apply -f .\edge-service\k8s\service.yml
kubectl apply -f .\edge-service\k8s\ingress.yml
kubectl apply -f .\order-service\k8s\deployment.yml
kubectl apply -f .\order-service\k8s\service.yml


REM prerequisites: Helm
helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator/
helm install opensearch-operator opensearch-operator/opensearch-operator