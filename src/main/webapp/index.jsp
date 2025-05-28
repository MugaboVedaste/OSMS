<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Shop Management System</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="css/style.css" rel="stylesheet">
    <style>
        .hero-section {
            background-color: #f8f9fa;
            padding: 80px 0;
            margin-bottom: 50px;
        }
        
        .feature-card {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin-bottom: 20px;
            border-radius: 10px;
            overflow: hidden;
            border: none;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }
        
        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.1);
        }
        
        .feature-icon {
            font-size: 3rem;
            margin-bottom: 20px;
            color: #0d6efd;
        }
        
        .cta-section {
            background-color: #0d6efd;
            color: white;
            padding: 50px 0;
            margin: 50px 0;
            border-radius: 10px;
        }
        
        footer {
            background-color: #212529;
            color: #f8f9fa;
            padding: 30px 0;
            margin-top: 50px;
        }
        
        .hero-image {
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            max-height: 400px;
            object-fit: cover;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">OSMS</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="#">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="login.jsp">Login</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-4 fw-bold mb-4">Welcome to Online Shop Management System</h1>
                    <p class="lead mb-4">A comprehensive solution for managing your online shop operations efficiently and effectively.</p>
                    <a href="login.jsp" class="btn btn-primary btn-lg">Get Started</a>
                </div>
                <div class="col-lg-6 d-none d-lg-block">
                    <img src="homepage image.jpg" alt="Online Shop Management" class="img-fluid rounded hero-image">
                </div>
            </div>
        </div>
    </section>

    <section class="features-section">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-md-12">
                    <h2 class="fw-bold">Key Features</h2>
                    <p class="lead">Discover what makes our system the perfect choice for your business</p>
            </div>
        </div>
        
            <div class="row">
            <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                    <div class="card-body">
                            <i class="fas fa-boxes feature-icon"></i>
                            <h5 class="card-title fw-bold">Inventory Management</h5>
                            <p class="card-text">Efficiently manage your product inventory with real-time tracking. Keep track of stock levels, receive alerts, and automate reordering.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                        <div class="card-body">
                            <i class="fas fa-shopping-cart feature-icon"></i>
                            <h5 class="card-title fw-bold">Order Processing</h5>
                            <p class="card-text">Streamline your order processing and fulfillment workflows. Track orders from placement to delivery with a comprehensive dashboard.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                    <div class="card-body">
                            <i class="fas fa-users feature-icon"></i>
                            <h5 class="card-title fw-bold">Customer Management</h5>
                            <p class="card-text">Maintain detailed customer profiles and purchase history. Build stronger relationships with your customers through targeted marketing.</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row mt-4">
                <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                        <div class="card-body">
                            <i class="fas fa-chart-line feature-icon"></i>
                            <h5 class="card-title fw-bold">Reports & Analytics</h5>
                            <p class="card-text">Get insights into your business performance with detailed reports and analytics. Make data-driven decisions to grow your business.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                        <div class="card-body">
                            <i class="fas fa-truck feature-icon"></i>
                            <h5 class="card-title fw-bold">Supplier Management</h5>
                            <p class="card-text">Maintain good relationships with your suppliers. Track supplier performance, manage orders, and streamline communication.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                    <div class="card feature-card h-100 p-4 text-center">
                    <div class="card-body">
                            <i class="fas fa-mobile-alt feature-icon"></i>
                            <h5 class="card-title fw-bold">Mobile Responsive</h5>
                            <p class="card-text">Access your shop management system from anywhere, on any device. Stay connected with your business on the go.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="cta-section">
        <div class="container text-center">
            <h2 class="mb-4">Ready to streamline your online shop operations?</h2>
            <p class="lead mb-4">Join thousands of businesses who are already using our platform to grow their online presence.</p>
            <a href="login.jsp" class="btn btn-light btn-lg">Get Started Now</a>
        </div>
    </section>

    <footer>
        <div class="container">
            <div class="row">
                <div class="col-md-6 text-center text-md-start">
                    <h5>Online Shop Management System</h5>
                    <p>Streamlining e-commerce operations since 2025</p>
                </div>
                <div class="col-md-6 text-center text-md-end">
                    <p>&copy; 2025 Online Shop Management System. All rights reserved.</p>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 