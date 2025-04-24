package com.osms.model;

import java.util.Date;

/**
 * Order entity class
 */
public class Order {
    private int orderId;
    private int customerId;
    private Date orderDate;
    private double totalAmount;
    private String status; // Pending, Processing, Shipped, Delivered, Cancelled

    // Default constructor
    public Order() {
    }

    // Parameterized constructor
    public Order(int customerId, double totalAmount) {
        this.customerId = customerId;
        this.orderDate = new Date();
        this.totalAmount = totalAmount;
        this.status = "Pending";
    }

    // Getters and Setters
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Order [orderId=" + orderId + ", customerId=" + customerId + ", orderDate=" + orderDate
                + ", totalAmount=" + totalAmount + ", status=" + status + "]";
    }
} 