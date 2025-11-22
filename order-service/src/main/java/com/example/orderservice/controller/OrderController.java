package com.example.orderservice.controller;

import com.example.orderservice.model.OrderRequest;
import io.dapr.client.DaprClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping
@RequiredArgsConstructor
public class OrderController {

    private static final String PUBSUB_NAME = "order-pubsub";
    private static final String TOPIC_NAME = "orders";

    private final DaprClient daprClient;

    @PostMapping("/create-order")
    public ResponseEntity<String> createOrder(@RequestBody OrderRequest orderRequest) {
        daprClient.publishEvent(PUBSUB_NAME, TOPIC_NAME, orderRequest).block();
        log.info("Published order {} for product {} (quantity: {})", orderRequest.getId(), orderRequest.getProduct(), orderRequest.getQuantity());
        return ResponseEntity.accepted().body("Order published");
    }
}
