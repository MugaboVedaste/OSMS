package com.osms.servlet;

import com.osms.dao.ProductDAO;
import com.osms.model.Product;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getPathInfo();
        if (action == null) {
            action = "/list";
        }

        try {
            switch (action) {
                case "/new":
                    showNewForm(request, response);
                    break;
                case "/edit":
                    showEditForm(request, response);
                    break;
                case "/delete":
                    deleteProduct(request, response);
                    break;
                default:
                    listProducts(request, response);
                    break;
            }
        } catch (SQLException ex) {
            request.getSession().setAttribute("errorMessage", "Database error: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/products");
        } catch (Exception ex) {
            request.getSession().setAttribute("errorMessage", "Error: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getPathInfo();
        if (action == null) {
            action = "/list";
        }

        try {
            switch (action) {
                case "/insert":
                    insertProduct(request, response);
                    break;
                case "/update":
                    updateProduct(request, response);
                    break;
                default:
                    listProducts(request, response);
                    break;
            }
        } catch (SQLException ex) {
            request.getSession().setAttribute("errorMessage", "Database error: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/products");
        } catch (Exception ex) {
            request.getSession().setAttribute("errorMessage", "Error: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, ServletException, IOException {
        List<Product> products = productDAO.getAll();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/WEB-INF/views/product/list.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, ServletException, IOException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        Product product = productDAO.getById(productId);
        request.setAttribute("product", product);
        request.getRequestDispatcher("/WEB-INF/views/product/form.jsp").forward(request, response);
    }

    private void insertProduct(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException, ParseException {
        // Get parameters from the form
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        
        // Parse numeric parameters
        double price = 0.0;
        if (request.getParameter("price") != null && !request.getParameter("price").isEmpty()) {
            price = Double.parseDouble(request.getParameter("price"));
        }
        
        int stockQuantity = 0;
        if (request.getParameter("stockQuantity") != null && !request.getParameter("stockQuantity").isEmpty()) {
            stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
        }
        
        int supplierId = 0;
        if (request.getParameter("supplierId") != null && !request.getParameter("supplierId").isEmpty()) {
            supplierId = Integer.parseInt(request.getParameter("supplierId"));
        }
        
        // Parse expiration date if provided
        Date expirationDate = null;
        if (request.getParameter("expirationDate") != null && !request.getParameter("expirationDate").isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            expirationDate = sdf.parse(request.getParameter("expirationDate"));
        }
        
        // Create product
        Product product = new Product();
        product.setProductName(productName);
        product.setDescription(description);
        product.setPrice(price);
        product.setStockQuantity(stockQuantity);
        product.setCategory(category);
        product.setSupplierId(supplierId);
        product.setExpirationDate(expirationDate);

        int productId = productDAO.insert(product);
        
        if (productId > 0) {
            request.getSession().setAttribute("successMessage", "Product added successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to add product. Please try again.");
        }
        
        response.sendRedirect(request.getContextPath() + "/products");
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException, ParseException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        
        // Parse numeric parameters
        double price = 0.0;
        if (request.getParameter("price") != null && !request.getParameter("price").isEmpty()) {
            price = Double.parseDouble(request.getParameter("price"));
        }
        
        int stockQuantity = 0;
        if (request.getParameter("stockQuantity") != null && !request.getParameter("stockQuantity").isEmpty()) {
            stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
        }
        
        int supplierId = 0;
        if (request.getParameter("supplierId") != null && !request.getParameter("supplierId").isEmpty()) {
            supplierId = Integer.parseInt(request.getParameter("supplierId"));
        }
        
        // Parse expiration date if provided
        Date expirationDate = null;
        if (request.getParameter("expirationDate") != null && !request.getParameter("expirationDate").isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            expirationDate = sdf.parse(request.getParameter("expirationDate"));
        }
        
        // First get the existing product to preserve any data not in the form
        Product product = productDAO.getById(productId);
        
        if (product != null) {
            // Update the product with the form data
            product.setProductName(productName);
            product.setDescription(description);
            product.setPrice(price);
            product.setStockQuantity(stockQuantity);
            product.setCategory(category);
            product.setSupplierId(supplierId);
            product.setExpirationDate(expirationDate);
            
            boolean success = productDAO.update(product);
            
            if (success) {
                request.getSession().setAttribute("successMessage", "Product updated successfully!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update product. Please try again.");
            }
        } else {
            request.getSession().setAttribute("errorMessage", "Product not found. Cannot update.");
        }
        
        response.sendRedirect(request.getContextPath() + "/products");
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, IOException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        
        boolean success = productDAO.delete(productId);
        
        if (success) {
            request.getSession().setAttribute("successMessage", "Product deleted successfully!");
        } else {
            request.getSession().setAttribute("errorMessage", "Failed to delete product. Please try again.");
        }
        
        response.sendRedirect(request.getContextPath() + "/products");
    }
} 