package com.osms.model;

/**
 * Model class to represent a category report item
 */
public class CategoryReport {
    private String categoryName;
    private int productCount;
    
    // Default constructor
    public CategoryReport() {
    }
    
    // Parameterized constructor
    public CategoryReport(String categoryName, int productCount) {
        this.categoryName = categoryName;
        this.productCount = productCount;
    }
    
    // Getters and Setters
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    public int getProductCount() {
        return productCount;
    }
    
    public void setProductCount(int productCount) {
        this.productCount = productCount;
    }
} 