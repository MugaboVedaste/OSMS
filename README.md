# Online Store Management System (OSMS)

A Java web application for managing an online store with customer, seller, and product management.

## Features

- User authentication and authorization (Customer, Seller, Admin)
- Product management
- Order processing
- Customer management
- Seller management

## Technologies Used

- Java Servlets and JSP
- MySQL Database
- JDBC for database connectivity
- HTML, CSS, and JavaScript for frontend
- Apache Tomcat as the application server

## Prerequisites

- Java JDK 8 or higher
- Apache Tomcat 9.x
- MySQL 8.0 or higher
- Maven (optional, for building)

## Setup Instructions

### Database Setup

1. Install MySQL if you haven't already
2. Create a database by running the schema script:
   ```
   mysql -u root -p < src/main/resources/db/schema.sql
   ```
3. Populate with sample data (optional):
   ```
   mysql -u root -p < src/main/resources/db/sample-data.sql
   ```

### Configuration

1. Update the database connection settings in `src/main/java/com/osms/util/DatabaseUtil.java` with your MySQL credentials if needed.

### Build and Deploy

1. Package the application as a WAR file:
   ```
   mvn clean package
   ```
   or use your IDE's built-in tools to export a WAR file.

2. Deploy the WAR file to Tomcat:
   - Copy the WAR file to Tomcat's `webapps` directory
   - Start Tomcat if it's not already running

### Access the Application

Open your browser and navigate to:
```
http://localhost:8080/osms
```

## Default Login Credentials

### Customers
- Email: alice@example.com | Password: password123
- Email: bob@example.com | Password: password123
- Email: carol@example.com | Password: password123

### Sellers
- Email: john@freshfarms.com | Password: password123
- Email: mary@organicsupplies.com | Password: password123
- Email: robert@techgadgets.com | Password: password123

## Project Structure

```
src/main/
├── java/
│   └── com/
│       └── osms/
│           ├── dao/         # Data Access Objects
│           ├── model/       # Entity classes
│           ├── servlet/     # Servlet controllers
│           ├── test/        # Test classes
│           └── util/        # Utility classes
├── resources/
│   └── db/                  # Database scripts
└── webapp/
    ├── admin/              # Admin pages
    ├── customer/           # Customer pages
    ├── seller/             # Seller pages
    ├── css/                # CSS files
    ├── js/                 # JavaScript files
    ├── WEB-INF/            # Configuration files
    ├── index.jsp           # Home page
    └── login.jsp           # Login page
```

