package com.osms.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.List;

import com.osms.dao.AddressDAO;
import com.osms.model.Address;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

public class AddressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AddressDAO addressDAO = new AddressDAO();
    private final Gson gson = new Gson();

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            // Get all addresses for customer
            List<Address> addresses = addressDAO.getByCustomerId(customerId);
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(addresses));
        } else {
            // Extract address ID from path
            try {
                int addressId = Integer.parseInt(pathInfo.substring(1));
                Address address = addressDAO.getById(addressId);

                if (address == null || address.getCustomerId() != customerId) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Address not found");
                    return;
                }

                response.setContentType("application/json");
                response.getWriter().write(gson.toJson(address));
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid address ID");
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        // Get form data
        String addressName = request.getParameter("addressName");
        String fullName = request.getParameter("fullName");
        String streetAddress = request.getParameter("streetAddress");
        String apartment = request.getParameter("apartment");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String zipCode = request.getParameter("zipCode");
        String country = request.getParameter("country");
        String phone = request.getParameter("phone");
        boolean defaultAddress = "on".equals(request.getParameter("defaultAddress"));

        // Create new address
        Address address = new Address();
        address.setCustomerId(customerId);
        address.setAddressName(addressName);
        address.setFullName(fullName);
        address.setStreetAddress(streetAddress);
        address.setApartment(apartment);
        address.setCity(city);
        address.setState(state);
        address.setZipCode(zipCode);
        address.setCountry(country);
        address.setPhone(phone);
        address.setDefaultAddress(defaultAddress);

        // If this is set as default, update any other default addresses
        if (defaultAddress) {
            addressDAO.clearDefaultAddresses(customerId);
        }

        // Save address
        int addressId = addressDAO.insert(address);

        if (addressId == -1) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Failed to save address");
            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Set the ID of the newly created address
        address.setAddressId(addressId);

        // Return success response
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.addProperty("message", "Address saved successfully");
        jsonResponse.addProperty("addressId", addressId);

        response.setContentType("application/json");
        response.getWriter().write(jsonResponse.toString());
    }

    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Address ID required");
            return;
        }

        try {
            int addressId = Integer.parseInt(pathInfo.substring(1));
            Address existingAddress = addressDAO.getById(addressId);

            if (existingAddress == null || existingAddress.getCustomerId() != customerId) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Address not found");
                return;
            }

            // Get form data
            String addressName = request.getParameter("addressName");
            String fullName = request.getParameter("fullName");
            String streetAddress = request.getParameter("streetAddress");
            String apartment = request.getParameter("apartment");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zipCode = request.getParameter("zipCode");
            String country = request.getParameter("country");
            String phone = request.getParameter("phone");
            boolean defaultAddress = "on".equals(request.getParameter("defaultAddress"));

            // Update address
            existingAddress.setAddressName(addressName);
            existingAddress.setFullName(fullName);
            existingAddress.setStreetAddress(streetAddress);
            existingAddress.setApartment(apartment);
            existingAddress.setCity(city);
            existingAddress.setState(state);
            existingAddress.setZipCode(zipCode);
            existingAddress.setCountry(country);
            existingAddress.setPhone(phone);
            existingAddress.setDefaultAddress(defaultAddress);

            // If this is set as default, update any other default addresses
            if (defaultAddress) {
                addressDAO.clearDefaultAddresses(customerId);
            }

            // Save address
            boolean updated = addressDAO.update(existingAddress);

            if (!updated) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Failed to update address");
                response.setContentType("application/json");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Return success response
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Address updated successfully");

            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid address ID");
        }
    }

    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("userId");

        if (customerId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Address ID required");
            return;
        }

        try {
            int addressId = Integer.parseInt(pathInfo.substring(1));
            Address existingAddress = addressDAO.getById(addressId);

            if (existingAddress == null || existingAddress.getCustomerId() != customerId) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Address not found");
                return;
            }

            // Delete address
            boolean deleted = addressDAO.delete(addressId);

            if (!deleted) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Failed to delete address");
                response.setContentType("application/json");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Return success response
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Address deleted successfully");

            response.setContentType("application/json");
            response.getWriter().write(jsonResponse.toString());
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid address ID");
        }
    }
}