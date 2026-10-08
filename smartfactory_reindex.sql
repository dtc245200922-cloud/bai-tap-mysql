-- MySQL 8.0+, InnoDB. Chay Legacy Script va nap du lieu truoc.
-- Chay tung khoi, luu ket qua truoc/sau. Khong chay lai DROP khi da doi index.
USE smartfactory_db;

-- 1. Do truoc khi doi index
ANALYZE TABLE SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';
SELECT INDEX_LENGTH INTO @index_before
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'SensorLogs';
EXPLAIN SELECT temperature, humidity, status
FROM SensorLogs WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

-- 2. Chuyen sang index tinh gon (khong xoa du lieu)
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

-- 3. Do sau khi doi index
ANALYZE TABLE SensorLogs;
SHOW INDEX FROM SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';
SELECT INDEX_LENGTH INTO @index_after
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'SensorLogs';
SELECT @index_before AS before_bytes, @index_after AS after_bytes,
       ROUND((@index_before - @index_after) * 100.0 /
             NULLIF(@index_before, 0), 2) AS reduction_percent;
EXPLAIN SELECT temperature, humidity, status
FROM SensorLogs WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
-- Mong doi key=idx_lean_search; type thuong range.
-- Using index condition KHAC Using index; khong khang dinh plan khi chua chay.
