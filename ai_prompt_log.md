# Nhật ký sử dụng AI

## Trao đổi thực tế
Người học gửi toàn bộ đề thực hành FlashMart. AI tạo bản nháp script, phần giải trình và nhật ký này. Không có lượt hỏi đáp lý thuyết riêng trước đó; không ghi các prompt gợi ý của đề thành trao đổi đã diễn ra.

## Nội dung AI giải thích trong bản nháp
- INNER JOIN chỉ giữ dòng khớp; LEFT JOIN giữ mọi dòng của bảng bên trái.
- COUNT(cột) bỏ qua NULL, còn COUNT(*) đếm tất cả dòng.
- LEFT JOIN kết hợp IS NULL tìm các dòng không có giao dịch tương ứng.

## Kiểm chứng
Hai truy vấn được kiểm tra bằng SQLite trên cùng dữ liệu mẫu: Alice 2 đơn, Bob 1 đơn, Charlie 0 đơn; sản phẩm chưa bán là 103, Keyboard. Script chưa được chạy trên MySQL Workbench; cần chạy và chụp Result Grid thực tế.

## Giới hạn sử dụng
Đề yêu cầu AI chỉ hỗ trợ lý thuyết, không viết sẵn toàn bộ đáp án. Bản nháp này được AI soạn nên người học cần tự hiểu, chỉnh sửa và tuân thủ quy định của giảng viên. Nhật ký không giả định đây là bài tự làm.
