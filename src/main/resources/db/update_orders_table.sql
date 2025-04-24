-- Drop the existing Orders table if it exists
DROP TABLE IF EXISTS Orders;

-- Create the updated Orders table with fields matching the model
CREATE TABLE IF NOT EXISTS Orders (
    OrderId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

-- Create OrderItem table to replace the product details that were in the original Orders table
CREATE TABLE IF NOT EXISTS OrderItem (
    OrderItemId INT AUTO_INCREMENT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES Product(ProductId)
);

-- Index for performance
CREATE INDEX idx_order_customer ON Orders(CustomerId);
CREATE INDEX idx_order_status ON Orders(Status);
CREATE INDEX idx_orderitem_order ON OrderItem(OrderId);
CREATE INDEX idx_orderitem_product ON OrderItem(ProductId); 