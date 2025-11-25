# Event-Driven Microservices on Azure Container Apps

This repository contains the source code and infrastructure configuration for an event-driven microservices architecture using **Java Spring Boot**, **Dapr**, and **Azure Container Apps (ACA)**.

The system demonstrates a decoupled Pub/Sub pattern using a **Self-Hosted Redis** container as the message broker to bypass Azure managed resource policy restrictions.

---

## 🏗️ System Architecture

The architecture follows the **Loose Coupling** principle. Services communicate asynchronously via Dapr Pub/Sub.

### Core Components
| Component | Type | Description |
| :--- | :--- | :--- |
| **Order Service** | `Publisher` | Accepts HTTP requests and publishes events to `orders` topic. |
| **Notification Service** | `Subscriber` | Listens to `orders` topic and logs the event payload. |
| **Redis Broker** | `Infrastructure` | A containerized Redis instance (Self-Hosted) serving as the message bus. |
| **Dapr Sidecars** | `Middleware` | Manages connectivity, retries, and abstraction. |

---

##  Deployment & Run Instructions

This section details how to build, deploy, and run the complete system on Azure.

### 1. Prerequisites
* Azure Subscription
* Azure CLI installed and logged in (`az login`)
* Docker installed locally (optional, for local testing)

## Environment Setup
First, create the necessary resource group and Azure Container Registry (ACR).

```bash
# Set Variables
RG="order-rg"
LOC="eastus"
ACR_NAME="selinacr23"
ENV_NAME="selin-env"

# Create Resource Group & Registry
az group create --name $RG --location $LOC
az acr create --resource-group $RG --name $ACR_NAME --sku Basic --admin-enabled true
```

## Build & Push Images (Image Details)
Build the Docker images for both microservices and the Redis infrastructure.

```bash

# Build Order Service
cd order-service
az acr build --registry $ACR_NAME --image order-service:v1 .

# Build Notification Service
cd ../notification-service
az acr build --registry $ACR_NAME --image notification-service:v1 .

# Build Redis (Custom Image)
# (Ensure you have a Dockerfile with 'FROM redis:alpine' in infrastructure folder or root)
cd ../infrastructure
az acr build --registry $ACR_NAME --image my-redis:v1 .
```
## Deploy Infrastructure (Redis)
Deploy the self-hosted Redis container to serve as the message broker.

```bash
# Create Container App Environment
az containerapp env create --name $ENV_NAME --resource-group $RG --location $LOC

# Deploy Redis Container
az containerapp create \
  --name redis-app \
  --resource-group $RG \
  --environment $ENV_NAME \
  --image $ACR_NAME.azurecr.io/my-redis:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --ingress internal --target-port 6379 --transport tcp
```

##  Configure Dapr
Apply the Dapr component configuration to connect to the internal Redis service.

```bash
# Deploy Dapr Component
az containerapp env dapr-component set \
  --name $ENV_NAME --resource-group $RG \
  --dapr-component-name order-pubsub \
  --yaml ./components/order-pubsub.yaml
```

## Deploy Microservices
Deploy the publisher and subscriber services with Dapr enabled.

```bash
# Deploy Order Service (Public Endpoint)
az containerapp create \
  --name order-service \
  --resource-group $RG \
  --environment $ENV_NAME \
  --image $ACR_NAME.azurecr.io/order-service:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --ingress external --target-port 8080 \
  --enable-dapr --dapr-app-id order-service --dapr-app-port 8080

# Deploy Notification Service (Internal)
az containerapp create \
  --name notification-service \
  --resource-group $RG \
  --environment $ENV_NAME \
  --image $ACR_NAME.azurecr.io/notification-service:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --ingress internal --target-port 8080 \
  --enable-dapr --dapr-app-id notification-service --dapr-app-port 8080
```

## 🧪 Test

To verify the end-to-end flow, you need to send an HTTP request to the public **Order Service** endpoint and verify that the message is consumed by the internal **Notification Service**.

Send an Order Request
Use the following `curl` command to publish a new order event.
*(Replace `<ORDER_SERVICE_URL>` with the **Application Url** found in the Azure Portal for `order-service`)*.

```bash
curl -X POST https://<ORDER_SERVICE_URL>/create-order \
-H "Content-Type: application/json" \
-d '{"product": "La mer The Moisturizing Cream", "quantity": 1}'
```

## Configuration

Port: All Java services run on port 8080.

Java Version: Java 17 (Eclipse Temurin).

Dapr Protocol: HTTP.
