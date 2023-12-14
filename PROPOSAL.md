# The Cloud Bookshop
**A specialized bookshop for spreading knowledge about the cloud native technologies**
> The `the-cloud-bookshop` is a project developed as part of our KV Cloud Computing class WS2023. For this project we agreed to build a Spring Boot microservices application and observe the microservices communication with OpenTelemetry and Jaeger.

# Table of Contents
1. [Definition and Scope](#def-scope)
2. [Milestones](#milestones)
3. [Task Division](#task-division)

## Definition and Scope
The project instruments Spring Boot microservices, hosted in a Kubernetes cluster, with Java OpenTelemetry-Agent and visualizes the communication traces with Jaeger. Our application consists of four microservices (OrderService, CatalogService, DispatchService, EdgeService) from an existing open-source project that communicate with each other. Jaeger runs as a Kubernetes-Operator in the cluster. As a backend for Jaeger we use OpenSearch. These microservices will be hosted on a Kubernetes cluster in Microsoft Azure.

## Milestones
- Design and Implement microservices
- OpenTelemetry Instrumentation
- Demo Setup and Test
- Presentation

## Task Division
- Cloud setup (Daniel Wimmer)
- OpenTelemetry instrumentation (Daniel Etzinger, Bahara Muradi)
- Jaeger implementation (Andreas Leeb, Daniel Wimmer)
- OpenSearch integration/deployment (Andreas Leeb, Bahara Muradi)
- Deployment (Daniel Etzinger)

### Cross-Functional Collaboration (all team members)
  - Documentation
  - Presentation