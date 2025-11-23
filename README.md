# Event-Driven Microservices on Azure Container Apps

This repository contains the source code and infrastructure configuration for an event-driven microservices architecture using **Java Spring Boot**, **Dapr**, and **Azure Container Apps (ACA)**.

The system demonstrates a decoupled Pub/Sub pattern using **Redis** as the message broker, emphasizing resilience and portability in a cloud-native environment.

## 🏗️ System Architecture



### Core Components

| Component | Type | Description |
| :--- | :--- | :--- |
| **Order Service** | `Publisher` | Spring Boot microservice that ingests order requests and publishes events via Dapr sidecar. |
| **Notification Service** | `Subscriber` | Spring Boot microservice that subscribes to order events and handles downstream processing. |
| **Redis Broker** | `Infrastructure` | A containerized Redis instance serving as the state store and message bus for Dapr. |
| **Dapr Sidecars** | `Middleware` | Manages distributed system concerns such as service discovery, retries, and message delivery. |

## 📐 Architectural Decisions

### 1. Data Plane Strategy: Self-Hosted Redis
Instead of relying on external managed services, the architecture utilizes a **self-hosted Redis container** running within the Container Apps Environment.
* **Reasoning:** This approach ensures complete network isolation (Internal Ingress), reduces latency by keeping traffic within the same environment, and provides a cost-effective solution for development/test environments.
* **Configuration:** The Redis instance runs on TCP port `6379` and is not exposed to the public internet.

### 2. Runtime & Security
* **Base Images:** The application containers are built on top of **`eclipse-temurin:17-jre`**. This decision was made to leverage the security patches and long-term support (LTS) provided by the Eclipse Foundation, replacing legacy OpenJDK images.
* **Executable Generation:** The build process explicitly enforces the `repackage` goal to ensure robust JAR execution within the container runtime.

## 🚀 Technology Stack

* **Platform:** Azure Container Apps
* **Application Runtime:** Dapr (Distributed Application Runtime)
* **Languages:** Java 17
* **Framework:** Spring Boot 3.x
* **Build Tool:** Maven
* **CI/CD & Registry:** Azure Container Registry (ACR)

## ⚙️ Deployment Configuration

The deployment consists of three primary container apps configured with Dapr sidecars.

### Dapr Component Configuration (`pubsub.redis`)
The system uses a `pubsub.redis` component configured to communicate with the internal Redis container:

```yaml
componentType: pubsub.redis
metadata:
  - name: redisHost
    value: "redis-app:6379"
  - name: enableTLS
    value: "false"
