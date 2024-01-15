#!/bin/sh

# Modifications copyright (C) 2024 Daniel Etzinger, Andreas Leeb, Bahara Muradi, Daniel Wimmer

echo "\n📦 Get Kubernetes cluster ip and set the context to bookshop ...\n"

kubectl config use-context bookshop
minikube tunnel --profile bookshop

helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator/
helm install opensearch-operator opensearch-operator/opensearch-operator

echo "\n⛵ Happy Sailing!\n"
