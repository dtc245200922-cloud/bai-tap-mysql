USE QuanLySinhVien;

-- 1. Tất cả thông tin các môn học có Credit lớn nhất.
SELECT *
FROM `Subject`
WHERE Credit = (SELECT MAX(Credit) FROM `Subject`);

-- 2. Các môn học có điểm thi cao nhất trong toàn bộ bảng Mark.
-- DISTINCT tránh lặp môn khi nhiều sinh viên cùng đạt điểm cao nhất.
SELECT DISTINCT Sub.*
FROM `Subject` AS Sub
JOIN `Mark` AS M ON Sub.SubID = M.SubID
WHERE M.Mark = (SELECT MAX(Mark) FROM `Mark`);

-- 3. Thông tin và điểm trung bình của mỗi sinh viên, giảm dần theo điểm.
-- LEFT JOIN giữ cả sinh viên chưa có điểm; điểm trung bình của họ là NULL.
SELECT S.StudentID, S.StudentName, S.Address, S.Phone,
       S.Status, S.ClassID, AVG(M.Mark) AS DiemTrungBinh
FROM Student AS S
LEFT JOIN `Mark` AS M ON S.StudentID = M.StudentID
GROUP BY S.StudentID, S.StudentName, S.Address, S.Phone,
         S.Status, S.ClassID
ORDER BY DiemTrungBinh DESC, S.StudentID ASC;
