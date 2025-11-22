package com.example.notificationservice.controller;

import com.example.notificationservice.model.OrderRequest;
import io.dapr.Topic;
import io.dapr.client.domain.CloudEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class NotificationController {

    private static final String PUBSUB_NAME = "order-pubsub";
    private static final String TOPIC_NAME = "orders";

    @Topic(name = TOPIC_NAME, pubsubName = PUBSUB_NAME)
    @PostMapping(path = "/notifications")
    public ResponseEntity<Void> handleOrder(@RequestBody CloudEvent<OrderRequest> cloudEvent) {
        OrderRequest order = cloudEvent.getData();
        log.info("Received order {} for product {} (quantity: {})", order.getId(), order.getProduct(), order.getQuantity());
        return ResponseEntity.ok().build();
    }
}
