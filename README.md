# Bài tập View, Index, Stored Procedure

## Chạy bài

1. Giải nén và mở kết nối QuickFeed trong MySQL Workbench (127.0.0.1, cổng 3307).
2. Chọn File → Open SQL Script, mở `demo_products.sql`.
3. Nhấn Ctrl + Shift + Enter để chạy toàn bộ một lần.

Script tạo database `demo`, bảng Products, sáu sản phẩm mẫu, hai index, view và bốn procedure. Không chứa mật khẩu. Nếu đã có bảng Products trong demo, không chạy lại toàn bộ: MySQL sẽ báo bảng đã tồn tại. Các procedure có thể được gọi lại riêng bằng CALL với tham số phù hợp.

## So sánh EXPLAIN

Hai truy vấn được chạy EXPLAIN với cùng điều kiện trước và sau khi tạo index. So sánh các cột `type`, `possible_keys`, `key`, `rows`, `Extra` trong Result Grid.

Trước index, truy vấn lọc productCode và truy vấn lọc tên/giá thường cần quét bảng (type ALL). Sau index, điều kiện bằng productCode có thể dùng idx_product_code (type const); tên bằng và giá theo khoảng có thể dùng idx_product_name_price (type range). Bảng mẫu nhỏ nên optimizer vẫn có thể chọn quét bảng; không coi đó là lỗi và không khẳng định tốc độ tăng khi chưa đo. Giá trị rows là ước lượng.

Unique index ngăn mã sản phẩm trùng. Composite index có thứ tự (productName, productPrice), phù hợp lọc tên trước rồi lọc giá; không mặc định hiệu quả cho truy vấn chỉ lọc giá.

## View và procedure

View ban đầu lấy bốn cột yêu cầu; ALTER VIEW bổ sung điều kiện chỉ lấy sản phẩm đang hoạt động; DROP VIEW xóa view mà không xóa dữ liệu Products.

Các procedure: getAllProducts, addProduct, updateProduct, deleteProduct. Cuối script có ví dụ gọi: thêm SP007, sửa đúng ID vừa thêm và xóa sản phẩm đó. Kết quả remaining_demo_product phải bằng 0; sáu sản phẩm ban đầu còn nguyên.

## Nộp GitHub

Tải hai file `demo_products.sql` và `README.md` lên thư mục riêng `view-index-stored-procedure` trong repository. Nộp link đến thư mục đó để người chấm đọc trực tiếp mã nguồn.

## Kiểm tra

Đã rà soát cấu trúc SQL và đóng gói. Chưa thực thi trên MySQL trong môi trường tạo file; kết quả EXPLAIN thực tế cần xem khi chạy trên máy người học.
