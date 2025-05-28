package com.osms.model;

import java.sql.Timestamp;

/**
 * Seller entity class
 */
public class Seller {
    private int sellerId;
    private String companyName;
    private String contactName;
    private String email;
    private String phone;
    private String address;
    private Timestamp joinedDate;
    private String password;
    private Timestamp registrationDate;

    // Default constructor
    public Seller() {
    }

    // Parameterized constructor
    public Seller(int sellerId, String companyName, String contactName, String email, String phone, String address, Timestamp joinedDate, Timestamp registrationDate) {
        this.sellerId = sellerId;
        this.companyName = companyName;
        this.contactName = contactName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.joinedDate = joinedDate;
        this.registrationDate = registrationDate;
    }

    // Getters and Setters
    public int getSellerId() {
        return sellerId;
    }

    public void setSellerId(int sellerId) {
        this.sellerId = sellerId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Timestamp getJoinedDate() {
        return joinedDate;
    }

    public void setJoinedDate(Timestamp joinedDate) {
        this.joinedDate = joinedDate;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Timestamp getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(Timestamp registrationDate) {
        this.registrationDate = registrationDate;
    }

    @Override
    public String toString() {
        return "Seller{" +
                "sellerId=" + sellerId +
                ", companyName='" + companyName + '\'' +
                ", contactName='" + contactName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", address='" + address + '\'' +
                ", joinedDate=" + joinedDate +
                ", registrationDate=" + registrationDate +
                '}';
    }
} 