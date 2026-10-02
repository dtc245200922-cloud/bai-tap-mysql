# Giải trình lựa chọn JOIN và COUNT

INNER JOIN chỉ giữ các dòng khớp nên loại Charlie khỏi báo cáo. LEFT JOIN giữ toàn bộ Customers và tạo dòng có các cột Orders bằng NULL khi khách hàng chưa mua. COUNT(o.order_id) bỏ qua NULL nên Charlie có 0 đơn. COUNT(*) đếm cả dòng được giữ lại, khiến Charlie bị tính thành 1 đơn. GROUP BY gom các dòng theo từng khách hàng.

Báo cáo kho vận lấy Products làm bảng gốc, dùng LEFT JOIN và lọc o.order_id IS NULL để tìm sản phẩm chưa có đơn hàng. Với INNER JOIN, các dòng không khớp đã bị loại; order_id là khóa chính không NULL nên điều kiện này không thể tìm thấy Keyboard.
