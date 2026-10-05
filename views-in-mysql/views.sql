-- Sử dụng cơ sở dữ liệu classicmodels
USE classicmodels;

---------------------------------------------------
-- 1. Tạo View ban đầu: customer_views
---------------------------------------------------
DROP VIEW IF EXISTS customer_views;

CREATE VIEW customer_views AS
SELECT customerNumber, customerName, phone
FROM customers;

-- Truy vấn dữ liệu từ View vừa tạo
SELECT * FROM customer_views;


---------------------------------------------------
-- 2. Cập nhật View (Thay đổi cấu trúc View)
---------------------------------------------------
CREATE OR REPLACE VIEW customer_views AS
SELECT customerNumber, customerName, contactFirstName, contactLastName, phone
FROM customers
WHERE city = 'Nantes';

-- Truy vấn kiểm tra lại dữ liệu sau khi cập nhật View
SELECT * FROM customer_views;


---------------------------------------------------
-- 3. Xóa View
---------------------------------------------------
DROP VIEW customer_views;
