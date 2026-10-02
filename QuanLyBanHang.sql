CREATE DATABASE QuanLyBanHang
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE QuanLyBanHang;

CREATE TABLE Customer (
    cID INT PRIMARY KEY,
    cName VARCHAR(100) NOT NULL,
    cAge INT,
    CONSTRAINT CK_Customer_Age CHECK (cAge >= 0)
) ENGINE=InnoDB;

CREATE TABLE `Order` (
    oID INT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice DECIMAL(15,2) NOT NULL DEFAULT 0,
    CONSTRAINT CK_Order_Total CHECK (oTotalPrice >= 0),
    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (cID) REFERENCES Customer(cID)
) ENGINE=InnoDB;

CREATE TABLE Product (
    pID INT PRIMARY KEY,
    pName VARCHAR(100) NOT NULL,
    pPrice DECIMAL(15,2) NOT NULL,
    CONSTRAINT CK_Product_Price CHECK (pPrice >= 0)
) ENGINE=InnoDB;

CREATE TABLE OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    CONSTRAINT CK_OrderDetail_Quantity CHECK (odQTY > 0),
    CONSTRAINT FK_OrderDetail_Order
        FOREIGN KEY (oID) REFERENCES `Order`(oID),
    CONSTRAINT FK_OrderDetail_Product
        FOREIGN KEY (pID) REFERENCES Product(pID)
) ENGINE=InnoDB;

-- Kiểm tra cấu trúc các bảng.
SHOW TABLES;
SHOW CREATE TABLE Customer;
SHOW CREATE TABLE `Order`;
SHOW CREATE TABLE Product;
SHOW CREATE TABLE OrderDetail;
