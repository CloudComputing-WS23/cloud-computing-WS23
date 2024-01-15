# Cloud Computing Project for winter term 2023

## Team members:
* Daniel Etzinger
* Andreas Leeb
* Bahara Muradi
* Daniel Wimmer

## Project proposal
[Proposal](./PROPOSAL.md)

# Documentation
## Instrumenting Spring Boot Microservices
TODO

## Jaeger Setup in Kubernetes

### Prerequisites
As a Kubernetes cluster we are using a local Minikube cluster for this tutorial
* Minikube
* a VM/container engine supported by Minikube (WSL, VirtualBox, Docker Engine etc.)
* kubectl connected to the local Minikube cluster

### Minikube startup
```
minikube start
```
with WSL this worked fine, with VirtualBox it can happen that Minikube wrongly detects that virtualization (VT-X) is disabled in the BIOS even though it is activated, then add the `--no-vtx-check` option.
```
minikube addons enable ingress
```
enables the ingress plugin, enabling us access services hosted in the Kubernetes cluster to be accessed via an IP from outside, e.g. for our Jaeger UI.
### Jaeger Operator installation
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.6.3/cert-manager.yaml
```
adds the cert-manager to the K8s cluster, required by Jaeger.
```
kubectl create -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.52.0/jaeger-operator.yaml
```
adds the Jaeger operator, enabling us to create Jaeger objects in the K8s cluster.
Now we can create a Jaeger instance.
### Jaeger instance creation
```
kubectl apply -f .\simplest.yml
```
using the YAML file in the repo

or
```
kubectl apply -n observability -f - <<EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: simplest
EOF
```
creates the Jaeger instance using the ready-to-use "AllInOne" deployment strategy that stores the traces in-memory.
### Troubleshooting
If you get an error like
```
Error from server (InternalError): error when creating ".\\simplest.yaml":
Internal error occurred: failed calling webhook "mjaeger.kb.io": failed to call webhook:
Post "https://jaeger-operator-webhook-service.observability.svc:443/mutate-jaegertracing-io-v1-jaeger?timeout=10s":
dial tcp 10.111.124.159:443: connect: connection refused
```
display the MutatingWebhookConfiguration with 
```
kubectl get mutatingwebhookconfigurations
```
resulting in something like 
```
NAME                                             WEBHOOKS   AGE
cert-manager-webhook                             1          116m
jaeger-operator-mutating-webhook-configuration   2          116m
```
```
kubectl delete mutatingwebhookconfiguration cert-manager-webhook
kubectl delete mutatingwebhookconfiguration jaeger-operator-mutating-webhook-configuration
```
and then applying `cert-manager.yaml` and `jaeger-operator.yaml` again solves the error.
### Verifying that it works
```
kubectl get jaegers
```
should show you the running jaeger instance, like this:
```
NAME       STATUS    VERSION   STRATEGY   STORAGE   AGE
simplest   Running   1.52.0    allinone   memory    71m
```
Also, check whether the `simplest-query` ingress has an IP address with `kubectl get ingress`.
If there is no address, you might have forgotten to enable the ingress plugin at the beginning. ```minikube stop```, enabling the ingress plugin if forgotten and ```minikube start``` helps here.

## Microservice Deployment in Kubernetes
TODO

## Jaeger UI
When your services are instrumented, up and running and you have made a few requests to them, browse to the IP address from the Jaeger instance ingress in your browser to open the Jaeger UI.

In the "Search" tab you can filter the traces by service, operation and time.
![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/498467b3-b5de-4521-9ba6-0aa45cbbfa66)
By clicking on a trace you can see the detailed way of the request through the microservices of the application, even including the database operations.
![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/608fc9e5-a05e-484e-b992-af045b6ac360)
TODO continue

## OpenSearch
We had planned to use OpenSearch (the open-source fork of ElasticSearch) as a storage backend for a Jaeger instance deployed with the "Production strategy" (details [here](https://www.jaegertracing.io/docs/1.53/operator/#production-strategy) and [here](https://www.jaegertracing.io/docs/1.53/operator/#elasticsearch-storage)). However, we have not been able to get the default running on our local Minikube clusters, presumably due to the resource requirements.

TODO Bahara step-by-step how you got it somewhat running on your PC
