package com.example.notificationservice.model;

import lombok.Data;

@Data
public class OrderRequest {
    private String id;
    private String product;
    private int quantity;
}
