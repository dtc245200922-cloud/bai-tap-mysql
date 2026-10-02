-- MySQL 8.0.16+. Chạy một lần trên CSDL mới hoặc cấu trúc legacy trong đề.
-- Sao lưu CSDL thực tế trước khi nâng cấp; không xóa bảng/dữ liệu cũ.
CREATE DATABASE IF NOT EXISTS autoride_db CHARACTER SET utf8mb4;
USE autoride_db;
CREATE TABLE IF NOT EXISTS Cars (
 car_id INT AUTO_INCREMENT PRIMARY KEY,
 model_name VARCHAR(100) NOT NULL,
 license_plate VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS Rentals (
 rental_id INT AUTO_INCREMENT PRIMARY KEY,
 car_id INT,
 customer_name VARCHAR(100) NOT NULL,
 rent_date DATETIME NOT NULL,
 return_date DATETIME,
 status VARCHAR(50) DEFAULT 'BOOKED',
 FOREIGN KEY (car_id) REFERENCES Cars(car_id)
) ENGINE=InnoDB;

-- Kiểm tra dữ liệu cũ trước khi đổi ENUM. Nếu có dòng, dừng và rà soát.
SELECT rental_id,status FROM Rentals
 WHERE status IS NULL OR BINARY status NOT IN ('BOOKED','ACTIVE','COMPLETED','CANCELLED');
-- Bật strict mode để giá trị cũ không hợp lệ gây lỗi thay vì bị đổi âm thầm.
SET @original_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = CONCAT_WS(',',NULLIF(@original_sql_mode,''),'STRICT_ALL_TABLES');
ALTER TABLE Rentals
 MODIFY COLUMN status ENUM('BOOKED','ACTIVE','COMPLETED','CANCELLED') NOT NULL DEFAULT 'BOOKED',
 ADD COLUMN security_deposit DECIMAL(15,2) NOT NULL DEFAULT 0,
 ADD COLUMN late_fee DECIMAL(15,2) NOT NULL DEFAULT 0,
 ADD COLUMN damage_fee DECIMAL(15,2) NOT NULL DEFAULT 0,
 ADD COLUMN expected_return_date DATETIME,
 ADD CONSTRAINT CK_Rental_Money CHECK (
  security_deposit >= 0 AND late_fee >= 0 AND damage_fee >= 0
 );
-- Không chặn tổng phí vượt cọc: trường hợp này khách còn phải trả thêm.
-- Số tiền tài chính cũ phải đối chiếu sổ kế toán; mặc định 0 không phải bằng chứng đã đối soát.
SET SESSION sql_mode = @original_sql_mode;

CREATE TABLE Inspections (
 inspection_id INT AUTO_INCREMENT PRIMARY KEY,
 rental_id INT NOT NULL,
 inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 damage_description TEXT NOT NULL,
 inspector_name VARCHAR(100) NOT NULL,
 CONSTRAINT FK_Inspection_Rental FOREIGN KEY (rental_id)
  REFERENCES Rentals(rental_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
-- Quan hệ 1-N: một hợp đồng có thể có nhiều lần kiểm tra.
DELIMITER $$
CREATE TRIGGER BI_Inspections
BEFORE INSERT ON Inspections FOR EACH ROW
BEGIN
 DECLARE rental_status VARCHAR(20) DEFAULT NULL;
 SELECT status INTO rental_status FROM Rentals WHERE rental_id=NEW.rental_id FOR UPDATE;
 IF rental_status IS NULL OR rental_status <> 'ACTIVE' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chi duoc lap bien ban khi hop dong ACTIVE';
 END IF;
END$$
CREATE TRIGGER BU_Inspections
BEFORE UPDATE ON Inspections FOR EACH ROW
BEGIN
 IF NEW.rental_id <> OLD.rental_id THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Khong duoc chuyen bien ban sang hop dong khac';
 END IF;
END$$
CREATE TRIGGER BU_Rentals_Lifecycle
BEFORE UPDATE ON Rentals FOR EACH ROW
BEGIN
 IF OLD.status <> NEW.status AND NOT (
  (OLD.status='BOOKED' AND NEW.status IN ('ACTIVE','CANCELLED')) OR
  (OLD.status='ACTIVE' AND NEW.status='COMPLETED')
 ) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Chuyen trang thai khong hop le';
 END IF;
 IF NEW.status='COMPLETED' AND OLD.status<>'COMPLETED' THEN
  IF NEW.return_date IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Can ghi nhan ngay tra xe';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM Inspections WHERE rental_id=OLD.rental_id) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Can kiem tra xe truoc khi hoan tat';
  END IF;
 END IF;
END$$
DELIMITER ;

-- Dữ liệu mô phỏng. Biển số demo cần chưa tồn tại trước khi chạy.
INSERT INTO Cars(model_name,license_plate) VALUES ('Toyota Vios','DEMO-AUTORIDE-01');
SET @car_id=LAST_INSERT_ID();
INSERT INTO Rentals(car_id,customer_name,rent_date,expected_return_date,status,security_deposit)
 VALUES (@car_id,'Nguyen Van A','2026-10-01 08:00:00','2026-10-03 08:00:00','BOOKED',10000000);
SET @rental_id=LAST_INSERT_ID();
UPDATE Rentals SET status='ACTIVE' WHERE rental_id=@rental_id;
START TRANSACTION;
INSERT INTO Inspections(rental_id,inspection_date,damage_description,inspector_name)
 VALUES (@rental_id,'2026-10-03 08:00:00','Vỡ đèn pha trái','Nhan vien Demo');
UPDATE Rentals SET status='COMPLETED',return_date='2026-10-03 08:00:00',
 late_fee=0,damage_fee=2000000 WHERE rental_id=@rental_id;
COMMIT;

SELECT rental_id,customer_name,status,security_deposit,late_fee,damage_fee,
 security_deposit-late_fee-damage_fee AS net_deposit_balance,
 GREATEST(security_deposit-late_fee-damage_fee,0) AS refund_amount,
 GREATEST(late_fee+damage_fee-security_deposit,0) AS additional_amount_due
FROM Rentals WHERE rental_id=@rental_id;
-- Kết quả dự kiến: refund_amount=8000000.00; additional_amount_due=0.00.
SELECT r.rental_id,r.customer_name,i.damage_description,i.inspector_name,i.inspection_date
FROM Rentals r JOIN Inspections i ON i.rental_id=r.rental_id
WHERE r.rental_id=@rental_id;

-- Kiểm thử âm: chạy riêng, phải nhận lỗi chuyển trạng thái.
-- UPDATE Rentals SET status='BOOKED' WHERE rental_id=@rental_id;
-- Kiểm thử BOOKED: tạo một hợp đồng BOOKED, rồi INSERT Inspections với ID đó;
-- trigger phải từ chối. DELETE hợp đồng có biên bản phải bị FK RESTRICT chặn.
