USE QuanLySinhVien;

-- 1. Sinh viên có tên bắt đầu bằng ký tự h.
SELECT *
FROM Student
WHERE LOWER(StudentName) LIKE 'h%';

-- 2. Các lớp bắt đầu vào tháng 12 (không giới hạn năm).
SELECT *
FROM `Class`
WHERE MONTH(StartDate) = 12;

-- 3. Các môn có Credit từ 3 đến 5, bao gồm hai đầu mút.
SELECT *
FROM `Subject`
WHERE Credit BETWEEN 3 AND 5;

-- 4. Chuyển sinh viên tên Hung sang lớp có ClassID = 2.
-- Lớp 2 phải tồn tại trước khi cập nhật để thỏa mãn khóa ngoại.
UPDATE Student
SET ClassID = 2
WHERE StudentName = 'Hung';

-- 5. Điểm giảm dần; nếu bằng điểm thì tên sinh viên tăng dần.
SELECT S.StudentName, Sub.SubName, M.Mark
FROM Student AS S
JOIN `Mark` AS M ON S.StudentID = M.StudentID
JOIN `Subject` AS Sub ON M.SubID = Sub.SubID
ORDER BY M.Mark DESC, S.StudentName ASC;
