USE QuanLySinhVien;

-- 1. Danh sách tất cả học viên.
SELECT *
FROM Student;

-- 2. Danh sách học viên đang theo học.
SELECT *
FROM Student
WHERE Status = TRUE;

-- 3. Các môn học có thời gian học nhỏ hơn 10 (theo cột Credit trong đề).
SELECT *
FROM `Subject`
WHERE Credit < 10;

-- 4. Danh sách học viên lớp A1.
SELECT S.StudentID, S.StudentName, C.ClassName
FROM Student AS S
JOIN `Class` AS C ON S.ClassID = C.ClassID
WHERE C.ClassName = 'A1';

-- 5. Điểm môn CF của các học viên.
SELECT S.StudentID, S.StudentName, Sub.SubName, M.Mark
FROM Student AS S
JOIN `Mark` AS M ON S.StudentID = M.StudentID
JOIN `Subject` AS Sub ON M.SubID = Sub.SubID
WHERE Sub.SubName = 'CF';
