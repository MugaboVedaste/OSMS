UPDATE Customer SET City = 'Anytown' WHERE CustomerId = 1;
UPDATE Customer SET City = 'Somecity' WHERE CustomerId = 2;
UPDATE Customer SET City = 'Otherville' WHERE CustomerId = 3;

INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, Password, RegistrationDate)
VALUES 
('Alice', 'Brown', 'alice@example.com', '456-789-0123', '101 Main St', 'Anytown', 'password123', '2023-01-20'),
('Bob', 'Green', 'bob@example.com', '567-890-1234', '202 Oak Ave', 'Somecity', 'password123', '2023-02-15'),
('Carol', 'Davis', 'carol@example.com', '678-901-2345', '303 Pine St', 'Otherville', 'password123', '2023-03-05'); 

INSERT INTO Product (ProductName, SupplierId, ExpirationDate)
VALUES 
('Fresh Apples', 1, '2023-12-31'),
('Organic Tomatoes', 2, '2023-11-30'),
('Laptop Computer', 3, NULL),
('Organic Carrots', 2, '2023-12-15'),
('Smartphone', 3, NULL),
('Fresh Oranges', 1, '2023-12-20'); 

INSERT INTO Orders (CustomerId, OrderDate, TotalAmount, Status)
VALUES 
(1, '2023-06-10', 150.50, 'Delivered'),
(2, '2023-06-15', 75.25, 'Shipped'),
(3, '2023-06-20', 999.99, 'Processing'),
(1, '2023-06-25', 45.75, 'Pending'); 

INSERT INTO OrderItem (OrderId, ProductId, Quantity, Price)
VALUES 
(1, 1, 5, 2.50),
(1, 4, 3, 3.00),
(1, 6, 4, 2.25),
(2, 2, 10, 1.75),
(2, 4, 5, 3.00),
(3, 3, 1, 899.99),
(3, 5, 1, 100.00),
(4, 1, 10, 2.50),
(4, 6, 8, 2.25); 