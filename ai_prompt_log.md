# Nhật ký AI — 02/10/2026

## Trao đổi thực tế

Người học gửi toàn bộ đề AutoRide trong cuộc trao đổi chuẩn bị bài tập SQL. AI chuẩn bị ba file, không có các câu hỏi kỹ thuật tách riêng trước đó. Nhật ký không tạo thêm prompt hay kết quả kiểm thử chưa xảy ra.

## Nội dung được AI hỗ trợ

1. Dùng DECIMAL(15,2), NOT NULL DEFAULT 0 cho các khoản tiền.
2. Chọn quan hệ Rentals 1-N Inspections để hỗ trợ nhiều biên bản; ON DELETE RESTRICT bảo vệ liên kết.
3. Dùng ENUM giới hạn giá trị trạng thái và trigger kiểm soát chuyển trạng thái.
4. Chặn INSERT biên bản khi hợp đồng chưa ACTIVE; yêu cầu kiểm tra trước COMPLETED.
5. Tách tiền hoàn dự kiến và khoản phải trả thêm khi phí vượt tiền cọc.

## Giới hạn và quy tắc bài

Đề giới hạn AI hỗ trợ các câu hỏi kỹ thuật từng phần. Bộ file này do AI soạn toàn bộ nên chưa đáp ứng quy tắc đó; người học cần tự triển khai, rà soát và điều chỉnh theo quy định của giảng viên. Không khẳng định người học đã tự viết hoặc chạy thành công script.
