-- Drop the existing Seller table if it exists
DROP TABLE IF EXISTS Seller;

-- Create the Seller table with the correct column names
CREATE TABLE Seller (
    SellerId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactName VARCHAR(100),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    Password VARCHAR(100) NOT NULL,
    JoinedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add some sample data
INSERT INTO Seller (CompanyName, ContactName, Email, Phone, Address, Password, JoinedDate)
VALUES 
('Tech Solutions Ltd', 'John Smith', 'tech@example.com', '123-456-7890', '123 Tech St, Tech City', 'password123', CURRENT_TIMESTAMP),
('Hardware Plus', 'Jane Doe', 'hardware@example.com', '234-567-8901', '456 Hardware Ave, Gadget Town', 'password123', CURRENT_TIMESTAMP); 