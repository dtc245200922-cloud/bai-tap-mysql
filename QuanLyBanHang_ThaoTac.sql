USE QuanLyBanHang;

-- Bài trước đặt tên khách hàng là cName.
-- Cho phép tổng tiền NULL để nhập đúng dữ liệu mẫu của đề.
ALTER TABLE `Order` MODIFY COLUMN oTotalPrice DECIMAL(15,2) NULL DEFAULT NULL;

-- Chạy phần thêm dữ liệu một lần khi các bảng chưa có dữ liệu mẫu.
START TRANSACTION;
INSERT INTO Customer (cID, cName, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50);

INSERT INTO Product (pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2);

INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL);

INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);
COMMIT;

-- 1. Đề gọi oPrice; cột thực tế là oTotalPrice.
SELECT oID, oDate, oTotalPrice AS oPrice
FROM `Order`
ORDER BY oID;

-- 2. Khách hàng đã mua hàng và các sản phẩm họ mua.
-- DISTINCT tránh lặp cùng sản phẩm khi khách mua nhiều lần.
SELECT DISTINCT C.cID, C.cName, P.pID, P.pName
FROM Customer AS C
JOIN `Order` AS O ON C.cID = O.cID
JOIN OrderDetail AS OD ON O.oID = OD.oID
JOIN Product AS P ON OD.pID = P.pID
ORDER BY C.cID, P.pID;

-- 3. Khách hàng chưa mua bất kỳ sản phẩm nào.
SELECT C.cName
FROM Customer AS C
WHERE NOT EXISTS (
    SELECT 1
    FROM `Order` AS O
    JOIN OrderDetail AS OD ON O.oID = OD.oID
    WHERE O.cID = C.cID
);

-- 4. Tổng tiền hóa đơn = tổng (số lượng * đơn giá).
SELECT O.oID, O.oDate,
       COALESCE(SUM(OD.odQTY * P.pPrice), 0) AS oPrice
FROM `Order` AS O
LEFT JOIN OrderDetail AS OD ON O.oID = OD.oID
LEFT JOIN Product AS P ON OD.pID = P.pID
GROUP BY O.oID, O.oDate
ORDER BY O.oID;
