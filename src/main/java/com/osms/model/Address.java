package com.osms.model;

import java.io.Serializable;

/**
 * Represents a customer shipping address
 */
public class Address implements Serializable {
    private static final long serialVersionUID = 1L;

    private int addressId;
    private int customerId;
    private String addressName;
    private String fullName;
    private String streetAddress;
    private String apartment;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    private String phone;
    private boolean defaultAddress;

    public Address() {
    }

    public int getAddressId() {
        return addressId;
    }

    public void setAddressId(int addressId) {
        this.addressId = addressId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getAddressName() {
        return addressName;
    }

    public void setAddressName(String addressName) {
        this.addressName = addressName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getStreetAddress() {
        return streetAddress;
    }

    public void setStreetAddress(String streetAddress) {
        this.streetAddress = streetAddress;
    }

    public String getApartment() {
        return apartment;
    }

    public void setApartment(String apartment) {
        this.apartment = apartment;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public boolean isDefaultAddress() {
        return defaultAddress;
    }

    public void setDefaultAddress(boolean defaultAddress) {
        this.defaultAddress = defaultAddress;
    }

    @Override
    public String toString() {
        return "Address [addressId=" + addressId + ", customerId=" + customerId +
                ", addressName=" + addressName + ", fullName=" + fullName +
                ", streetAddress=" + streetAddress + ", apartment=" + apartment +
                ", city=" + city + ", state=" + state + ", zipCode=" + zipCode +
                ", country=" + country + ", phone=" + phone +
                ", defaultAddress=" + defaultAddress + "]";
    }
}