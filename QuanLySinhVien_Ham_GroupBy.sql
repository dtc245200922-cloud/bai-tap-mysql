USE QuanLySinhVien;

-- 1. Số lượng sinh viên ở từng nơi.
SELECT Address, COUNT(StudentID) AS SoLuongHocVien
FROM Student
GROUP BY Address;

-- 2. Điểm trung bình của mỗi học viên có dữ liệu điểm.
SELECT S.StudentID, S.StudentName, AVG(M.Mark) AS DiemTrungBinh
FROM Student AS S
JOIN `Mark` AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName;

-- 3. Các học viên có điểm trung bình lớn hơn 15.
SELECT S.StudentID, S.StudentName, AVG(M.Mark) AS DiemTrungBinh
FROM Student AS S
JOIN `Mark` AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName
HAVING AVG(M.Mark) > 15;

-- 4. Thông tin học viên có điểm trung bình cao nhất, gồm mọi người đồng hạng.
-- Loại nhóm toàn điểm NULL khỏi phép so sánh ALL.
SELECT S.StudentID, S.StudentName, S.Address, S.Phone,
       S.Status, S.ClassID, AVG(M.Mark) AS DiemTrungBinh
FROM Student AS S
JOIN `Mark` AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName, S.Address, S.Phone,
         S.Status, S.ClassID
HAVING AVG(M.Mark) >= ALL (
    SELECT AVG(M2.Mark)
    FROM `Mark` AS M2
    GROUP BY M2.StudentID
    HAVING COUNT(M2.Mark) > 0
);
