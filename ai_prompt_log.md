# Nhật ký sử dụng AI

## Trao đổi thực tế
Người học gửi toàn bộ đề PayFlow. AI tạo bản nháp ba file này và tra cứu tài liệu MySQL về Range Optimization. Không có các lượt hỏi đáp lý thuyết riêng trước đó; không ghi prompt gợi ý của đề thành trao đổi thật.

## Kiến thức trong bản nháp
- SARGable: điều kiện cho phép index tìm các khóa phù hợp trực tiếp; dùng khoảng trên created_at thay vì bọc YEAR/MONTH.
- Index kết hợp: đặt transaction_type trước để lọc bằng, created_at sau để lọc khoảng; không chỉ dựa vào cột nào có cardinality cao hơn.
- ALL là quét bảng, range là truy cập khoảng index; rows trong EXPLAIN là ước lượng, không phải số đo thực tế.
- Hai cột index chưa bao phủ amount. Không được coi mọi truy vấn SELECT chậm trên InnoDB là gây table lock; cần phân biệt tranh chấp tài nguyên và khóa.

## Tình trạng kiểm chứng
Chưa chạy MySQL, chưa đo tốc độ, chưa có ảnh Result Grid/EXPLAIN. Không tuyên bố đã giảm từ 45 giây xuống một thời gian cụ thể.

## Quy định của bài
Đề giới hạn AI hỗ trợ lý thuyết, không viết toàn bộ đáp án. Đây là bản nháp AI soạn; người học cần tự hiểu, chỉnh sửa và thực hiện theo quy định giảng viên.

Nguồn tham khảo: https://dev.mysql.com/doc/refman/8.0/en/range-optimization.html
