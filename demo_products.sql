-- MySQL 8.0. Chay toan bo file trong MySQL Workbench.
-- Dung database demo theo de; dung neu Products da ton tai de tranh ghi de du lieu.
CREATE DATABASE IF NOT EXISTS demo;
USE demo;

CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(30) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(12,2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (productPrice >= 0),
    CHECK (productAmount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO Products
    (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
    ('SP001', 'Laptop', 15000000, 10, 'Laptop hoc tap', TRUE),
    ('SP002', 'Laptop', 22000000, 5, 'Laptop lap trinh', TRUE),
    ('SP003', 'Chuot', 250000, 40, 'Chuot khong day', TRUE),
    ('SP004', 'Ban phim', 650000, 20, 'Ban phim co', TRUE),
    ('SP005', 'Man hinh', 3500000, 8, 'Man hinh 24 inch', TRUE),
    ('SP006', 'Tai nghe', 450000, 0, 'Tai nghe co day', FALSE);

-- Ke hoach truy van TRUOC khi tao index.
EXPLAIN SELECT * FROM Products WHERE productCode = 'SP003';
EXPLAIN SELECT * FROM Products
WHERE productName = 'Laptop' AND productPrice >= 16000000;

CREATE UNIQUE INDEX idx_product_code ON Products(productCode);
CREATE INDEX idx_product_name_price ON Products(productName, productPrice);
ANALYZE TABLE Products;

-- Ke hoach truy van SAU khi tao index: dung cung dieu kien de so sanh.
EXPLAIN SELECT * FROM Products WHERE productCode = 'SP003';
EXPLAIN SELECT * FROM Products
WHERE productName = 'Laptop' AND productPrice >= 16000000;
SHOW INDEX FROM Products;

-- Tao, su dung, sua va xoa view.
CREATE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus FROM Products;
SELECT * FROM view_products;

ALTER VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products WHERE productStatus = TRUE;
SELECT * FROM view_products;

DROP VIEW view_products;
SHOW FULL TABLES WHERE Table_type = 'VIEW';

DELIMITER //
CREATE PROCEDURE getAllProducts()
BEGIN
    SELECT * FROM Products ORDER BY Id;
END //

CREATE PROCEDURE addProduct(
    IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(12,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BOOLEAN
)
BEGIN
    INSERT INTO Products
        (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_description, p_status);
    SELECT LAST_INSERT_ID() AS new_product_id;
END //

CREATE PROCEDURE updateProduct(
    IN p_id INT, IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(12,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BOOLEAN
)
BEGIN
    UPDATE Products SET productCode = p_code, productName = p_name,
        productPrice = p_price, productAmount = p_amount,
        productDescription = p_description, productStatus = p_status
    WHERE Id = p_id;
END //

CREATE PROCEDURE deleteProduct(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;

-- Goi thu CRUD; chi sua/xoa san pham vua them.
CALL getAllProducts();
CALL addProduct('SP007', 'USB', 150000, 30, 'USB 32GB', TRUE);
SET @new_id = LAST_INSERT_ID();
SELECT * FROM Products WHERE Id = @new_id;
CALL updateProduct(@new_id, 'SP007', 'USB 64GB', 220000, 25, 'Da cap nhat dung luong', TRUE);
SELECT * FROM Products WHERE Id = @new_id;
CALL deleteProduct(@new_id);
SELECT COUNT(*) AS remaining_demo_product FROM Products WHERE Id = @new_id;
CALL getAllProducts();
