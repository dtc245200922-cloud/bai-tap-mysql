-- Chạy một lần trên MySQL 8.0.16+ với CSDL mới hoặc cấu trúc legacy của đề.
-- Không DROP bảng hay xóa dữ liệu cũ. Sao lưu trước khi chạy trên CSDL thực tế.
CREATE DATABASE IF NOT EXISTS healthsync_db CHARACTER SET utf8mb4;
USE healthsync_db;

CREATE TABLE IF NOT EXISTS Patients (
 patient_id INT AUTO_INCREMENT PRIMARY KEY,
 full_name VARCHAR(100) NOT NULL,
 phone VARCHAR(15) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS Doctors (
 doctor_id INT AUTO_INCREMENT PRIMARY KEY,
 full_name VARCHAR(100) NOT NULL,
 specialty VARCHAR(50)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS Appointments (
 appointment_id INT AUTO_INCREMENT PRIMARY KEY,
 patient_id INT,
 doctor_id INT,
 appointment_date DATETIME NOT NULL,
 is_active BOOLEAN DEFAULT TRUE,
 FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
 FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
) ENGINE=InnoDB;

ALTER TABLE Appointments
 ADD COLUMN status ENUM('PENDING','CONFIRMED','CHECKED_IN','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
 ADD COLUMN deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
 ADD COLUMN penalty_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
 ADD COLUMN cancel_reason VARCHAR(500),
 ADD CONSTRAINT CK_Appointment_Money CHECK (
  deposit_amount >= 0 AND penalty_fee >= 0 AND penalty_fee <= deposit_amount
 ),
 ADD CONSTRAINT CK_Appointment_Cancellation CHECK (
  (status = 'CANCELLED' AND cancel_reason IS NOT NULL AND CHAR_LENGTH(TRIM(cancel_reason)) > 0)
  OR (status <> 'CANCELLED' AND cancel_reason IS NULL AND penalty_fee = 0)
 );

-- Không thể suy ra 5 trạng thái từ Boolean cũ.
-- Giữ trạng thái mặc định PENDING cho dữ liệu cũ để BA rà soát.
-- Lưu Boolean cũ vào bảng riêng trước khi bỏ cột.
CREATE TABLE AppointmentLegacyReview (
 appointment_id INT PRIMARY KEY,
 legacy_is_active BOOLEAN,
 reviewed BOOLEAN NOT NULL DEFAULT FALSE,
 FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
) ENGINE=InnoDB;
INSERT INTO AppointmentLegacyReview (appointment_id, legacy_is_active)
 SELECT appointment_id, is_active FROM Appointments;
ALTER TABLE Appointments DROP COLUMN is_active;

CREATE TABLE Prescriptions (
 prescription_id INT AUTO_INCREMENT PRIMARY KEY,
 appointment_id INT NOT NULL,
 medication_details TEXT NOT NULL,
 issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT UQ_Prescription_Appointment UNIQUE (appointment_id),
 CONSTRAINT FK_Prescription_Appointment FOREIGN KEY (appointment_id)
  REFERENCES Appointments(appointment_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

DELIMITER $$
CREATE TRIGGER BI_Prescriptions
BEFORE INSERT ON Prescriptions FOR EACH ROW
BEGIN
 DECLARE current_status VARCHAR(20) DEFAULT NULL;
 SELECT status INTO current_status FROM Appointments
  WHERE appointment_id = NEW.appointment_id FOR UPDATE;
 IF current_status IS NULL OR current_status <> 'COMPLETED' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi duoc ke don cho lich hen COMPLETED';
 END IF;
 IF CHAR_LENGTH(TRIM(NEW.medication_details)) = 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Don thuoc khong duoc rong';
 END IF;
END$$
CREATE TRIGGER BU_Prescriptions
BEFORE UPDATE ON Prescriptions FOR EACH ROW
BEGIN
 DECLARE current_status VARCHAR(20) DEFAULT NULL;
 SELECT status INTO current_status FROM Appointments
  WHERE appointment_id = NEW.appointment_id FOR UPDATE;
 IF current_status IS NULL OR current_status <> 'COMPLETED' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi duoc ke don cho lich hen COMPLETED';
 END IF;
 IF CHAR_LENGTH(TRIM(NEW.medication_details)) = 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Don thuoc khong duoc rong';
 END IF;
END$$
CREATE TRIGGER BU_Appointments_Lifecycle
BEFORE UPDATE ON Appointments FOR EACH ROW
BEGIN
 IF OLD.status <> NEW.status AND NOT (
  (OLD.status = 'PENDING' AND NEW.status IN ('CONFIRMED','CANCELLED')) OR
  (OLD.status = 'CONFIRMED' AND NEW.status IN ('CHECKED_IN','CANCELLED')) OR
  (OLD.status = 'CHECKED_IN' AND NEW.status = 'COMPLETED')
 ) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chuyen trang thai khong hop le';
 END IF;
 IF NEW.status IN ('CONFIRMED','CHECKED_IN','COMPLETED') AND NEW.deposit_amount <= 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Can ghi nhan tien coc truoc khi xac nhan';
 END IF;
END$$
DELIMITER ;

-- Dữ liệu mô phỏng, không phải thông tin bệnh nhân thật.
INSERT INTO Patients(full_name,phone) VALUES ('Benh nhan A','0900000001');
SET @patient_a = LAST_INSERT_ID();
INSERT INTO Patients(full_name,phone) VALUES ('Benh nhan B','0900000002');
SET @patient_b = LAST_INSERT_ID();
INSERT INTO Doctors(full_name,specialty) VALUES ('Bac si Demo','Noi tong quat');
SET @doctor = LAST_INSERT_ID();

-- Kịch bản 1: đầy đủ bước CONFIRMED theo vòng đời nghiệp vụ.
START TRANSACTION;
INSERT INTO Appointments(patient_id,doctor_id,appointment_date,status,deposit_amount)
 VALUES (@patient_a,@doctor,'2026-10-03 08:00:00','PENDING',500000);
SET @success_id = LAST_INSERT_ID();
UPDATE Appointments SET status = 'CONFIRMED' WHERE appointment_id = @success_id;
UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = @success_id;
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = @success_id;
INSERT INTO Prescriptions(appointment_id,medication_details)
 VALUES (@success_id,'Du lieu don thuoc mo phong cho bai thuc han.');
COMMIT;

-- Kịch bản 2: tiền cọc 300.000, phí phạt 150.000.
INSERT INTO Appointments(patient_id,doctor_id,appointment_date,status,deposit_amount)
 VALUES (@patient_b,@doctor,'2026-10-03 09:00:00','CONFIRMED',300000);
SET @cancel_id = LAST_INSERT_ID();
UPDATE Appointments
 SET status = 'CANCELLED', cancel_reason = 'Bận việc đột xuất', penalty_fee = 150000
 WHERE appointment_id = @cancel_id;

SELECT a.appointment_id,p.full_name,a.status,a.deposit_amount,a.penalty_fee,
 CASE WHEN a.status = 'CANCELLED' THEN a.deposit_amount-a.penalty_fee ELSE NULL END AS refund_amount,
 a.cancel_reason
FROM Appointments a JOIN Patients p ON p.patient_id=a.patient_id
WHERE a.appointment_id IN (@success_id,@cancel_id);

SELECT p.full_name,a.appointment_id,a.status,r.medication_details,r.issued_date
FROM Appointments a
JOIN Patients p ON p.patient_id=a.patient_id
JOIN Prescriptions r ON r.appointment_id=a.appointment_id
WHERE a.status='COMPLETED';

-- Kiểm thử âm: chạy riêng từng lệnh dưới đây, phải nhận lỗi.
-- UPDATE Appointments SET status='PENDING' WHERE appointment_id=@success_id;
-- UPDATE Appointments SET penalty_fee=400000 WHERE appointment_id=@cancel_id;
-- INSERT INTO Prescriptions(appointment_id,medication_details) VALUES (@cancel_id,'Test');
