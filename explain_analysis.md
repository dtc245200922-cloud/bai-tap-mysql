# Phân tích EXPLAIN

Chưa chạy trên MySQL có dữ liệu thực tế; các mô tả sau là dự kiến, không phải số đo.

Trước tối ưu, bảng chỉ có khóa chính. YEAR/MONTH bọc created_at khiến điều kiện không khai thác trực tiếp khoảng của B-tree thông thường. Dự kiến type = ALL, key = NULL; rows ước lượng gần số dòng toàn bảng.

Sau tối ưu, index (transaction_type, created_at) dùng điều kiện bằng rồi điều kiện khoảng. Dự kiến type = range, key = idx_type_date, rows giảm khi tháng được chọn chiếm tỷ lệ nhỏ. Optimizer vẫn có thể chọn ALL với bảng nhỏ hoặc điều kiện ít chọn lọc; không bảo đảm một kế hoạch cố định. possible_keys là index ứng viên, key là index thực sự chọn, rows là ước lượng.

Khoảng [01/06, 01/07) giữ đúng dữ liệu tháng 6. Index chưa chứa amount nên chưa phải covering index cho SUM(amount).

Cần chụp hai EXPLAIN và ghi type/key/rows thực tế. Chạy truy vấn đối chiếu: same_total phải bằng 1.

Nguồn: https://dev.mysql.com/doc/refman/8.0/en/range-optimization.html
