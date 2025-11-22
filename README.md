# E-Commerce Order System with Dapr Pub/Sub

## Prerequisites
- Java 17 and Maven 3.9+
- Docker (for running Redis)
- Dapr CLI initialized locally (`dapr init`)

## Build
```bash
mvn -f order-service/pom.xml clean package -DskipTests
mvn -f notification-service/pom.xml clean package -DskipTests
```

## Build container images (example with Azure Container Registry)
Run the build from inside each service directory so the local Dockerfile and `target/*.jar` are picked up:
```bash
# From the order-service folder
cd order-service
az acr build --registry <your-acr-name> --image order-service:v1 .

# From the notification-service folder
cd ../notification-service
az acr build --registry <your-acr-name> --image notification-service:v1 .
```

If you prefer building locally with Docker, run the same commands using `docker build` from each service directory.

## Start dependencies
Run Redis locally for the `order-pubsub` component:
```bash
docker run -d --name redis -p 6379:6379 redis:7-alpine
```

## Run with Dapr sidecars
Use the provided `components/order-pubsub.yaml` for the pub/sub component.

### NotificationService (subscriber)
```bash
dapr run \
  --app-id notification-service \
  --app-port 8082 \
  --dapr-http-port 3501 \
  --resources-path ./components \
  -- java -jar notification-service/target/notification-service-0.0.1-SNAPSHOT.jar
```

### OrderService (publisher)
```bash
dapr run \
  --app-id order-service \
  --app-port 8081 \
  --dapr-http-port 3500 \
  --resources-path ./components \
  -- java -jar order-service/target/order-service-0.0.1-SNAPSHOT.jar
```

## Create an order
Send a request through the OrderService Dapr sidecar (publishes to `orders` topic):
```bash
curl -X POST http://localhost:3500/v1.0/invoke/order-service/method/create-order \
  -H "Content-Type: application/json" \
  -d '{"id":"1","product":"Widget","quantity":2}'
```

Check the NotificationService logs to see the simulated email notification for the published order.
