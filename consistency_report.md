# Phân tích tính nhất quán HealthSync

Thiết kế cũ có ba điểm không khớp với quy trình nghiệp vụ. Thứ nhất, cột is_active chỉ biểu diễn hai giá trị, trong khi lịch hẹn có năm trạng thái. Vì vậy, hệ thống không phân biệt được chờ duyệt, đã xác nhận cọc, đã đến và khám xong. Cột status dùng ENUM thay thế Boolean; trigger kiểm soát thứ tự chuyển trạng thái.

Thứ hai, bảng Appointments thiếu tiền cọc, phí phạt và lý do hủy. Việc hủy lịch không có dữ liệu để tính hoàn tiền hoặc đối soát kế toán. Thiết kế mới dùng DECIMAL(12,2), tránh sai số biểu diễn của FLOAT. CHECK yêu cầu số tiền không âm, phí phạt không vượt tiền cọc và lịch hủy phải có lý do. Tiền dự kiến hoàn bằng tiền cọc trừ phí phạt; đây chưa phải bằng chứng đã hoàn tiền thực tế.

Thứ ba, không có bảng đơn thuốc. Prescriptions bổ sung khóa ngoại và UNIQUE trên appointment_id, tạo quan hệ một lịch hẹn có tối đa một đơn thuốc. Trigger INSERT và UPDATE chỉ cho kê đơn khi lịch đã COMPLETED. RESTRICT bảo vệ hồ sơ có đơn thuốc khỏi việc xóa lịch hẹn.

Boolean cũ không đủ để khôi phục trạng thái chính xác. Script lưu giá trị cũ vào AppointmentLegacyReview, chờ rà soát; không giả định dữ liệu lịch sử đã chính xác.

## Phạm vi và kiểm tra

Script dành cho MySQL 8.0.16 trở lên, chạy một lần trên cấu trúc legacy hoặc CSDL mới. Hai kịch bản mô phỏng có truy vấn kiểm tra và ba lệnh kiểm thử âm. Script chưa được chạy trên MySQL trong phiên này; cần chạy trên Workbench để xác nhận kết quả.

Mô hình lưu trạng thái hiện tại; chưa có lịch sử chuyển trạng thái hay sổ giao dịch cọc/hoàn tiền. Nếu triển khai thực tế, cần bổ sung hai cấu trúc này. UNIQUE chỉ bảo đảm tối đa một đơn thuốc, không tự bảo đảm mọi lịch COMPLETED đều đã có đơn.
