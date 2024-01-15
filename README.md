# Cloud Computing Project for winter term 2023

## Team members:
* Daniel Etzinger
* Andreas Leeb
* Bahara Muradi
* Daniel Wimmer

## Project proposal
[Proposal](./PROPOSAL.md)

# Documentation
## Spring Boot Microservices Application
Our Spring Boot Microservices application is a based on the implementations of [Thomas Vitale](https://github.com/ThomasVitale/cloud-native-spring-in-action/tree/main/PolarBookshop). In his implementations, he developed a bookshop consisting of five microservices (catalog, order, dispatcher, edge and config). Under the repositories of each microservice (README.md) we can see the endpoints they expose.

## Instrumenting Spring Boot Microservices with OpenTelemetry
For the microservices (instrumented to send OpenTelemetry traces), a few settings need to be passed via environment variables in their Kubernetes deployments. These changes are already done in the deployment.yml files of each microservice's repo.

Example:
```
...
      containers:
        - name: catalog-service
          image: ghcr.io/cloudcomputing-ws23/catalog-service
...
          env:
            - name: JAVA_TOOL_OPTIONS
              value: -javaagent:/workspace/BOOT-INF/lib/opentelemetry-javaagent-1.32.0.jar
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: http://jaeger-collector:4317
            - name: OTEL_TRACES_EXPORTER
              value: jaeger
            - name: OTEL_METRICS_EXPORTER
              value: none
...
```
* `JAVA_TOOL_OPTIONS` tells the JVM to load the OpenTelemetry agent as well, which automatically executes the instrumentation.
* `OTEL_EXPORTER_OLTP_ENDPOINT` specifies the Kubernetes service name and the gRPC port of the Jaeger collector to which the traces are to be sent.
* `OTEL_TRACES_EXPORTER` selects the Jaeger exporter
* `OTEL_METRICS_EXPORTER` is set to `none` as Jaeger cannot handle metrics but only traces. For metrics, solutions like Prometheus can be used.

Additionally, in every different `build.gradle` files we also set 
```
ext {
    set('otelVersion', "1.32.0")
    ...
    }
	
dependencies {
    ...
    runtimeOnly "io.opentelemetry.javaagent:opentelemetry-javaagent:${otelVersion}"
    runtimeOnly "io.opentelemetry:opentelemetry-exporter-otlp:${otelVersion}"
    ...
}
```
As well as adding
```
logging:
    pattern:
       level: "%5p [${spring.application.name},%X{trace_id},%X{span_id}]"
```
in `src/main/resources/application.yml`. The logging pattern is only relevant if we have the service as a container and we want to look at `docker logs catalog-service` we can see `[catalog-service,d9e61c8cf853fe7fdf953422c5ff567a,eef9e08caea9e32a]` showing us the trace id as well as the span id.

## Jaeger Setup in Kubernetes

### Prerequisites
As a Kubernetes cluster we are using a local Minikube cluster for this tutorial
* Minikube
* a VM/container driver [supported](https://minikube.sigs.k8s.io/docs/drivers/) by Minikube (Hyper-V, VirtualBox, Docker Engine etc.)
* kubectl connected to the local Minikube cluster

### Minikube startup
```
minikube start
```
with Hyper-V this worked fine, with VirtualBox it can happen that Minikube wrongly detects that virtualization (VT-X) is disabled in the BIOS even though it is activated, then add the `--no-vtx-check` option.
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
kubectl create namespace observability 
kubectl create -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.52.0/jaeger-operator.yaml -n observability
```
adds the Jaeger operator, enabling us to create Jaeger objects in the K8s cluster.
Now we can create a Jaeger instance.
### Jaeger instance creation
```
kubectl apply -f jaeger.yml
```
using the YAML file in the repo

or putting
```
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
```
into a file and applying it creates the Jaeger instance using the ready-to-use "AllInOne" deployment strategy that stores the traces in-memory.
### Troubleshooting
If you get an error like
```
Error from server (InternalError): error when creating ".\\jaeger.yml":
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
jaeger     Running   1.52.0    allinone   memory    71m
```
Also, check whether the `jaeger-query` ingress has an IP address with `kubectl get ingress`.
If there is no address, you might have forgotten to enable the ingress plugin at the beginning. ```minikube stop```, enabling the ingress plugin if forgotten and ```minikube start``` helps here.

## Microservice Deployment in Kubernetes
### Spring Boot application images
The images of the services are already being pushed to the repository:
```
./gradlew bootBuildImage \
    --imageName ghcr.io/<github_username>/SERVICE_NAME \
    --publishImage \
    -PregistryUrl=ghcr.io \
    -PregistryUsername=<github_username> \
    -PregistryToken=<github_token>
```
These images are available in the GitHub container registry and are ready to be deployed in Kubernetes.
In the file DOCUMENTATION.md we can see alternative ways how to build Spring Boot application images! Furthermore, the document reveals further details regarding docker and useful set of commands in k8s.

### Deployment
Execute the following commands one after another (it is recommended to wait until the corresponding pod has been started, check it via `kubectl get pods`, as starting all at once can lead to some containers restarting multiple times due to not reaching their availability and health probes because of the high load)
```
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
```
Now you can expose services to the world outside of the Kubernetes cluster with
```
kubectl port-forward service/SERVICE_NAME LOCAL_PORT:PORT_NO
```
To use the application from outside, execute
```
kubectl port-forward services/edge-service 8080:80
```
and browse to `localhost:8080`.

Then you can try
```
GET http://localhost:8080/books
```
to get all books.

With e.g.
```
POST http://localhost:8080/orders
Content-Type: application/json
Body:
{
    "isbn": "1234567891",
    "quantity": 2
}
```
you can submit an order, that you can then query with
```
GET http://localhost:8080/orders
```

All these requests and their paths through the application can be seen as traces in the Jaeger UI.

## Jaeger UI
When your services are instrumented, up and running and you have made a few requests to them, browse to the IP address from the Jaeger instance ingress in your browser to open the Jaeger UI.

In the "Search" tab you can filter the traces by service, operation and time.
![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/498467b3-b5de-4521-9ba6-0aa45cbbfa66)

By clicking on a trace you can see the detailed way and duration of the request through the microservices of the application, even including the database operations.
![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/608fc9e5-a05e-484e-b992-af045b6ac360)

In the "Compare" tab you can compare two traces, but this is easier done by selecting to traces in the "Search" tab and clicking "Compare".

In the "System Architecture" tab you can see graphs describing the microservice architecture. These diagrams are generated when Jaeger has collected enough data to analyze the architecture.

![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/4344c8da-3d17-44f2-9920-678f2aded2dc)

![image](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/30859615/0d417e3e-7249-47a0-b7bb-29ee05b6bf9c)

## OpenSearch
We had planned to use OpenSearch (the open-source fork of ElasticSearch) as a storage backend for a Jaeger instance deployed with the "Production strategy" (details [here](https://www.jaegertracing.io/docs/1.53/operator/#production-strategy) and [here](https://www.jaegertracing.io/docs/1.53/operator/#elasticsearch-storage)). However, we have not been able to get the default running on our local Minikube clusters, presumably due to the resource requirements.

### Attempt
Prerequisites: Since the helm chart sets up a cluster of 3 nodes, it is advised to have at least 8GB of RAM for this deployment.
Installation steps:
1. Install [HELM](https://helm.sh/docs/intro/install/)
2. Add HELM OpenSearch repo and install the operator
```
helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator/
helm install opensearch-operator opensearch-operator/opensearch-operator
```
After the operator is installed, create an OpenSearchCluster custom object in Kubernetes.
```
kubectl apply -f opensearch-cluster.yaml
```
After the cluster gets created, we saw all relative nodes were up and running: ```kubectl get pod```
![OpenSearch Cluster](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/67308427/6062c56f-eef2-4de7-9548-786265c2469b)
- a bootstrap pod will be created that helps with initial master discovery
- further pods for the OpenSearch cluster will be created (masters, nodes and coordinators), and one pod for the dashboards instance.
After the pods are appearing as ready, which normally takes about 1-2 minutes, we can connect to our cluster using port-forwarding ```kubectl port-forward svc/opensearch-cluster 9200```, which for our attempt crashed.
![Pods are no more reachable](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/67308427/131cfae7-fb11-40a9-9f64-4fd6e08445e1)
![Connection lost](https://github.com/CloudComputing-WS23/cloud-computing-WS23/assets/67308427/42ae9630-2df3-4a13-b097-0d299e191f50)

If it had passed, for username=admin and password=admin we had seen the dashboard.

## Cloud Deployment
TODO Wimmer

## Lessons Learned
TODO
