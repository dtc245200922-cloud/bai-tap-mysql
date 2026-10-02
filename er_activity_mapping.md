# Đối chiếu nghiệp vụ và ERD

Thiết kế cũ thiếu tiền cọc, phí trễ và phí hư hỏng; không có biên bản kiểm tra; trạng thái chưa có ràng buộc miền giá trị. VARCHAR vẫn có thể dùng nếu kèm CHECK, nên vấn đề không nằm ở riêng kiểu VARCHAR.

Cột damage_fee bắt buộc trong thiết kế này vì nhánh “xe hư hỏng” phát sinh khoản khấu trừ tiền cọc. Chỉ lưu mô tả lỗi không đủ để tính hoàn tiền và đối soát kế toán. DECIMAL lưu giá trị tiền chính xác; NOT NULL và DEFAULT 0 tránh kết quả phép trừ trở thành NULL.

Inspections lưu bằng chứng kiểm tra với quan hệ 1-N, hỗ trợ nhiều lần kiểm tra. Khóa ngoại RESTRICT ngăn xóa hợp đồng có biên bản. Trigger chỉ cho thêm biên bản khi ACTIVE và yêu cầu biên bản, ngày trả trước khi COMPLETED.

Kịch bản cọc 10 triệu, phí hư hỏng 2 triệu, phí trễ 0 cho tiền hoàn dự kiến 8 triệu. Nếu tổng phí vượt cọc, hệ thống hiển thị khoản khách phải trả thêm, không hoàn tiền âm.

## Ghi chú triển khai

Script chạy một lần, yêu cầu MySQL 8.0.16+. Chưa chạy kiểm thử MySQL trong cuộc trao đổi này. Giá trị tài chính của dữ liệu legacy cần đối chiếu kế toán trước khi sử dụng.

expected_return_date hỗ trợ xác định trả trễ; mức phí phải do chính sách nghiệp vụ cung cấp, script không tự đặt mức phạt. Mô hình chưa lưu lịch sử trạng thái hoặc giao dịch hoàn tiền thực tế; truy vấn chỉ tính khoản dự kiến.
