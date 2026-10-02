CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

-- Nếu đã chạy legacy script, giữ nguyên bảng và dữ liệu hiện có.
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    transaction_type VARCHAR(20),
    created_at DATETIME
) ENGINE=InnoDB;

-- 1. Chụp kế hoạch trước khi tạo index (trên dữ liệu thực tế).
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND YEAR(created_at) = 2026
  AND MONTH(created_at) = 6;

-- 2. Chạy CREATE INDEX một lần; không tạo lại nếu đã có idx_type_date.
CREATE INDEX idx_type_date
ON Transactions (transaction_type, created_at);

ANALYZE TABLE Transactions;

-- So sánh truy vấn cũ sau khi đã có cùng index.
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND YEAR(created_at) = 2026
  AND MONTH(created_at) = 6;

-- 3. Kế hoạch sau tối ưu: bằng trên cột đầu, khoảng trên cột sau.
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- 4. Báo cáo tài chính. Giữ SUM để bảo toàn cách xử lý NULL của truy vấn cũ.
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- 5. Đối chiếu: same_total = 1 nghĩa là hai tổng giống nhau, kể cả NULL.
SELECT old_total, new_total, old_total <=> new_total AS same_total
FROM (
    SELECT
        SUM(CASE WHEN transaction_type = 'DEPOSIT'
                  AND YEAR(created_at) = 2026 AND MONTH(created_at) = 6
                 THEN amount END) AS old_total,
        SUM(CASE WHEN transaction_type = 'DEPOSIT'
                  AND created_at >= '2026-06-01 00:00:00'
                  AND created_at < '2026-07-01 00:00:00'
                 THEN amount END) AS new_total
    FROM Transactions
) AS totals;

-- Tùy chọn MySQL 8.0.18+: EXPLAIN ANALYZE thực thi thật, đo thời gian.
-- EXPLAIN ANALYZE
-- SELECT SUM(amount) FROM Transactions
-- WHERE transaction_type = 'DEPOSIT'
--   AND created_at >= '2026-06-01 00:00:00'
--   AND created_at < '2026-07-01 00:00:00';
