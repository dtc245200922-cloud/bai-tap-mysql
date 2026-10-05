-- Chuyển sang cơ sở dữ liệu classicmodels
USE classicmodels;

---------------------------------------------------
-- 1. Tham số loại IN
---------------------------------------------------
DROP PROCEDURE IF EXISTS getCusById;

DELIMITER //

CREATE PROCEDURE getCusById(
    IN cusNum INT
)
BEGIN
    SELECT * 
    FROM customers 
    WHERE customerNumber = cusNum;
END //

DELIMITER ;

-- Gọi và kiểm tra Procedure với tham số IN
CALL getCusById(175);


---------------------------------------------------
-- 2. Tham số loại OUT
---------------------------------------------------
DROP PROCEDURE IF EXISTS GetCustomersCountByCity;

DELIMITER //

CREATE PROCEDURE GetCustomersCountByCity(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    SELECT COUNT(customerNumber)
    INTO total
    FROM customers
    WHERE city = in_city;
END //

DELIMITER ;

-- Gọi và kiểm tra Procedure với tham số OUT
CALL GetCustomersCountByCity('Lyon', @total);
SELECT @total AS total_customers_in_lyon;


---------------------------------------------------
-- 3. Tham số loại INOUT
---------------------------------------------------
DROP PROCEDURE IF EXISTS SetCounter;

DELIMITER //

CREATE PROCEDURE SetCounter(
    INOUT counter INT,
    IN inc INT
)
BEGIN
    SET counter = counter + inc;
END //

DELIMITER ;

-- Gọi và kiểm tra Procedure với tham số INOUT
SET @counter = 1;
CALL SetCounter(@counter, 1); -- @counter = 2
CALL SetCounter(@counter, 1); -- @counter = 3
CALL SetCounter(@counter, 5); -- @counter = 8

SELECT @counter AS final_counter_value;
