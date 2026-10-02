# Nhật ký sử dụng AI

## Cuộc trao đổi thực tế ngày 02/10/2026

Người học gửi toàn bộ đề HealthSync trong chuỗi trao đổi chuẩn bị bài tập SQL. AI chuẩn bị script SQL, báo cáo phân tích và nhật ký này. Không có các lượt hỏi riêng về ENUM, DECIMAL hoặc ALTER TABLE trước khi tạo bộ file; không ghi các prompt chưa thực sự được gửi.

## Nội dung AI hỗ trợ

- Thay Boolean bằng ENUM và thêm trigger kiểm soát vòng đời.
- Dùng DECIMAL cho tiền cọc, phí phạt; dùng CHECK cho số tiền và lý do hủy.
- Tạo Prescriptions với khóa ngoại RESTRICT, UNIQUE và trigger chặn kê đơn trước COMPLETED.
- Giữ Boolean cũ trong bảng rà soát trước khi bỏ cột.
- Thêm bước CONFIRMED vào kịch bản thành công để đúng vòng đời trong mô tả.

## Giới hạn

Đề chỉ cho dùng AI để hỗ trợ từng phần, không yêu cầu AI viết trọn bộ SQL. Bộ file này được AI soạn toàn bộ nên chưa đáp ứng quy tắc sử dụng AI của bài. Người học cần tự rà soát, triển khai và điều chỉnh theo quy định của giảng viên. Nhật ký không khẳng định đã chạy kiểm thử hoặc người học đã tự viết mã.
