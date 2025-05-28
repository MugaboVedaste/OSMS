package com.osms.model;

import java.util.Date;

/**
 * Represents a product in the system
 */
public class Product {
    private int productId;
    private String productName;
    private String description;
    private double price;
    private int stockQuantity;
    private String category;
    private Integer supplierId;
    private int sellerId;
    private String imagePath;
    private Date expirationDate;
    
    public Product() {
    }
    
    public Product(int productId, String productName, String description, double price, 
            int stockQuantity, String category, Integer supplierId, int sellerId,
            String imagePath, Date expirationDate) {
        this.productId = productId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.category = category;
        this.supplierId = supplierId;
        this.sellerId = sellerId;
        this.imagePath = imagePath;
        this.expirationDate = expirationDate;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public int getSellerId() {
        return sellerId;
    }

    public void setSellerId(int sellerId) {
        this.sellerId = sellerId;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    @Override
    public String toString() {
        return "Product [productId=" + productId + ", productName=" + productName + 
               ", description=" + description + ", price=" + price + 
               ", stockQuantity=" + stockQuantity + ", category=" + category + 
                ", supplierId=" + supplierId + ", sellerId=" + sellerId +
                ", imagePath=" + imagePath + ", expirationDate=" + expirationDate + "]";
    }
} 