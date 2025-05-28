CREATE TABLE IF NOT EXISTS product_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    admin_id INT NOT NULL,
    action_type ENUM('UPDATE', 'DELETE') NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    changes TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(ProductId) ON DELETE CASCADE
); 