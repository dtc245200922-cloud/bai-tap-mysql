# So sánh kế hoạch thực thi

YEAR/MONTH trên created_at không tạo được khoảng tìm kiếm trực tiếp bằng index B-tree thông thường. Trước index, dự kiến type=ALL, key=NULL, rows gần tổng số dòng.

Index (transaction_type, created_at) phục vụ điều kiện bằng rồi khoảng thời gian. Truy vấn mới dùng [2026-06-01, 2026-07-01), không bỏ sót ngày cuối tháng. Dự kiến type=range, key=idx_type_date và rows giảm khi điều kiện chọn lọc. possible_keys là ứng viên; key là lựa chọn thực tế; rows là ước lượng. ALL vẫn có thể hợp lý khi bảng nhỏ hoặc phần dữ liệu phù hợp quá lớn.

## Số đo thực tế (điền sau khi chạy MySQL)

| Kế hoạch | type | possible_keys | key | rows | Extra |
|---|---|---|---|---|---|
| Cũ, chưa index | Chưa đo | Chưa đo | Chưa đo | Chưa đo | Chưa đo |
| Cũ, có index | Chưa đo | Chưa đo | Chưa đo | Chưa đo | Chưa đo |
| Mới, có index | Chưa đo | Chưa đo | Chưa đo | Chưa đo | Chưa đo |

Đối chiếu old_total/new_total: same_total phải bằng 1. Chưa có kết quả EXPLAIN thực tế.

Nguồn: https://dev.mysql.com/doc/refman/8.0/en/range-optimization.html
