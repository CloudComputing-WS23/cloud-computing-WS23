#!/bin/sh

# Modifications copyright (C) 2024 Daniel Etzinger, Andreas Leeb, Bahara Muradi, Daniel Wimmer

echo "\n🏴️ Destroying Kubernetes cluster...\n"

minikube stop --profile bookshop

minikube delete --profile bookshop

echo "\n🏴️ Cluster destroyed\n"
