# The Bookshop Software System
![Software System](./pics/SoftwareSystem.png)

## Building Spring Boot application
### Generate services projects
Generate the project of all services from [Spring Initializr](https://start.spring.io)
NOTE: for any test class of an application run:
```
./gradlew test --tests TEST_CLASS_NAME
```

## Build Images using Cloud Native Buildpacks
navigate to the root folder of each service and run
 ```
./gradlew bootBuildImage
```
show newly created images by providing the project name and the version:
 ```
docker images <project_name>:<version>
```
check if the containerized application is working providing correct values. The command removes the container after its execution completes.
```
docker run --rm --name CONTAINER_NAME -p PORT_NO:PORT_NO <project_name>:<version>
```
navigate to a browser and `http://localhost:PORT_NO` and see if you get an OK message.
To remove containers:
```
ddocker rm -fv CONTAINER_NAME
```

### Work with Kubernetes
Start the Kubernetes cluster:
```
minikube start
minikube image load <project_name>:<version>
```
Remember to create the docker images beforehand. In a production scenario, the image would be fetched from a container registry.
An example of `<project_name>:<version>` could be `catalog-service:latest`, where `<project_name>` is always the service root project name and the `<version>` is the corresponding project version in the build.gradle file or the tag `latest`.
We now navigate to `bookshop-deployment/kubernetes/platform/development` and apply the services that are needed by our applications including database, RabbitMQ and Redis.
```
kubectl apply -f services
```
Now let's create the deployments for our microservices. There are two ways to do it:
1) run the following commands for each service
```
kubectl create deplyment DEPLOYMENT_NAME --image=<project_name>:<version>
```
2) make use of the YAML file under the root project file of each service
```
kubectl apply -f k8s/deployment.yml
``` 
Verify the creation of the Depolyments
```
kubectl get deployment
kubectl get pod
```
By default, applications running in Kubernetes are not accessible. Fix it by running:
```
kubectl expose deployment DEPLOYMENT_NAME --name=SERVICE_NAME --port=PORT_NO
```
The Service object exposes the application (microservices) to other components inside the cluster.
```
kubectl apply -f k8s/service.yml
kubectl get service SERVICE_NAME
kubectl get svc -l app=SERVICE_NAME
```
To forward the traffic from a local port on the computer (for example, 8000) to the port exposed by the Service inside the cluster (8080) run:
```
kubectl port-forward service/SERVICE_NAME LOCAL_PORT:PORT_NO
```
Now navigate to localhost on the mentioned LOCAL_PORT and see if the service is up and running and test further endpoints.
Stop port-forwarding with `(Ctrl-C)` and clean up by navigating to the root folder of each application where the Kubernetes manifests are defined:
```
kubectl delete -f k8s
```
or for each services and deployments:
```
kubectl delete service SERVICE_NAME
kubectl delete deployment DEPLOYMENT_NAME
```
and delete backing services too by navigating to `bookshop-deployment/kubernetes/platform/development`:
```
kubectl delete -f services
```
and then stop minikube:
```
minikube stop
```
### Tilt configuration
To automate the whole commands regarding building images and running kubernetes manifests, we could use `bookshop-deployment/kubernetes/applications/development`:
```
tilt up
```
Priorly, start the cluster and go to bookshop-deployment repository, navigate to the `kubernetes/platform/development` folder, and run the installations with `kubectl apply -f services`.
Go to the URL where Tilt started its services (by default, it should be (http://localhost:10350)), and monitor the process that Tilt follows to build and deploy the services.
Tilt has also activated port forwarding to the local machine, we can go ahead and verify that the applications are working correctly. Stop Tilt with `(Ctrl-C)` or `tilt down`.
Remember to go to bookshop-deployment repository, navigate to the `kubernetes/platform/development` folder, and delete the installations with `kubectl delete -f services`. Finally, stop the cluster `minikube stop`.
Tilt ensures the application remains synchronized with the source code. Any changes made to the applications prompt Tilt to initiate an update process, which involves building and deploying new container images. This entire procedure occurs automatically and continuously.

## Orderflow in action
1) make sure all backing services (containers) and applications are running -> navigate to `bookshop-deployment/docker`:
```
docker-compose up -d bookshop-postgres bookshop-rabbitmq bookshop-redis
```
and then start the applications `/gradlew bootRun` or from Docker Compose after building the images first and running them:
```
./gradlew bootBuildImage
docker-compose up -d edge-service dispatch-service catalog-service order-service
```

2) open up a browser and navigate to ` http://localhost:15672` to access the RabbitMQ management console after logging in with the credentials.
Then send a request to catalog service and add a new book in the catalog:
```
curl http:9001/books
curl -X POST http://localhost:9001/books \
    -H "Content-Type: application/json" \
    -d '{"author": "Thomas Vitale", "title": "New Cloud Native Spring in Action", "isbn": "1234567897", "price": 9.90}'
```
3) Then order 3 copies of that book
```
curl -X POST http://localhost:9002/orders \
    -H "Content-Type: application/json" \
    -d '{"isbn": "1234567891", "quantity": "3"}'
```
When we place an order for an existing book, the order gets accepted, and the Order Service publishes an OrderAcceptedEvent message. The Dispatcher Service, which subscribes to this event, then processes the order and publishes an OrderDispatchedEvent message. Following this, the Order Service receives a notification and updates the order status in the database.
4) Fetch the orders:
```
curl http://localhost:9002/orders
```
The status should be "DISPATCHED".

5) Stopp all applications with `(Ctrl-C)` and Docker containers with:
```
docker-compose down
```

### Dockerfile for the Catalog Service Image
Build the executable file for the application from the root file:
```
./gradlew clean bootJar
```
we have Dockerfile:
```
FROM eclipse-temurin:17
WORKDIR workspace
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} catalog-service.jar
ENTRYPOINT ["java", "-jar", "catalog-service.jar"]
```
Run the following commands in a Terminal to build the image:
```
docker build -t catalog-service .
```
Publishing images to GitHub Container Registry
```
docker login ghcr.io
docker push ghcr.io/<github_username>/catalog-service:latest
```
or run 
```
./gradlew bootBuildImage \
    --imageName ghcr.io/<github_username>/catalog-service \
    --publishImage \
    -PregistryUrl=ghcr.io \
    -PregistryUsername=<github_username> \
    -PregistryToken=<github_token>
```
In a browser see if the application works `http://localhost:9001/books`.

## Useful commands
`chmod +x create-cluster.sh` and `chmod +x destroy-cluster.sh` to make the scripts executable.
```
minikube start --cpus 2 --memory 4g --driver docker --profile bookshop
minikube ip --profile bookshop
minikube tunnel --profile bookshop # to expose the cluster to the local environment, and then use the 127.0.0.1 IP address to call the cluster
kubectl get nodes
kubectl config get-contexts
kubectl config current-context
kubectl config use-context bookshop
kubectl apply -f services
kubectl get pod
```
Then build containers for the applications
```
./gradlew bootBuildImage
```
Further commands:
```
minikube image load catalog-service --profile bookshop
kubectl apply -f k8s/deployment.yml
kubectl get pods -l app=catalog-service
kubectl get svc -l app=catalog-service
kubectl get all -l app=catalog-service
kubectl logs deployment/catalog-service
kubectl describe pod <pod_name>
kubectl logs <pod_name>
kubectl delete pod <pod-name>
kubectl delete -f k8s
kubectl delete -f services
minikube stop --profile bookshop
```

## Observability
Event logs, health probes, and metrics offer an extensive range of important data to know the internal state of an application. Nonetheless, these tools do not take into account that cloud-native applications operate as distributed systems. For distributed tracing in our system we opted for OpenTelemetry.
In the [docker-compose.yml](bookshop-deployment/docker/docker-compose.yml) we added the following lines to every service:
```
- JAVA_TOOL_OPTIONS=-javaagent:/workspace/BOOT-INF/lib/opentelemetry-javaagent-1.32.0.jar
- OTEL_SERVICE_NAME=catalog-service
- OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger-collector:4317
- OTEL_TRACES_EXPORTER=jaeger
- OTEL_METRICS_EXPORTER=none
```
In every different `build.gradle` files we also set 
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
in `src/main/resources/application.yml`. Now when we look at `docker logs catalog-service` we can see `[catalog-service,d9e61c8cf853fe7fdf953422c5ff567a,eef9e08caea9e32a]` showing us the trace id as well as the span id.
- A trace is a record of the activities linked to a specific request or transaction, uniquely identified by a trace ID. It consists of multiple spans, which can span across various services.
- Every stage in the processing of a request is termed a span, marked by its start and end times and uniquely identified by a combination of the trace ID and a span ID.
