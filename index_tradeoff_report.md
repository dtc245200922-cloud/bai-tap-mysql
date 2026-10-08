# Đánh đổi index trong SmartFactory

Index cũ gồm sensor_id, recorded_at, temperature, humidity và status, bao phủ truy vấn Dashboard. Nó giúp lấy dữ liệu trực tiếp từ index, giảm việc đọc bản ghi trong bảng. Tuy nhiên, mỗi INSERT phải cập nhật cả clustered index và secondary index rộng, tăng lượng dữ liệu ghi, chi phí bộ nhớ đệm và nguy cơ tách trang B-tree.

Giải pháp thay thế dùng idx_lean_search(sensor_id, recorded_at). Cột sensor_id đứng trước để lọc bằng; recorded_at đứng sau để lọc khoảng thời gian. Ba cột kết quả được bỏ khỏi index. MySQL phải dùng khóa chính log_id trong secondary index để truy cập bản ghi gốc, nên SELECT có thể chậm hơn, đặc biệt khi trả về nhiều dòng.

Đổi lại, index nhỏ hơn giúp giảm chi phí duy trì và lưu trữ. INSERT không phải sắp xếp lại toàn bộ cây, nhưng vẫn phải cập nhật các trang liên quan. Mức cải thiện phụ thuộc dữ liệu, bộ nhớ và tải thực tế.

Script đo Index_length và EXPLAIN trước/sau. Chưa thực thi trên cơ sở dữ liệu nên chưa có số liệu xác nhận. Không coi mức tăng tốc 5 lần hoặc giảm dung lượng 70% là kết quả đo. Cần bổ sung bằng chứng chạy trước khi kết luận.

## Kết quả cần bổ sung sau khi chạy

| Chỉ tiêu | Trước | Sau |
|---|---|---|
| Index_length (byte) | Chưa đo | Chưa đo |
| EXPLAIN: key | Chưa đo | Chưa đo |
| EXPLAIN: type | Chưa đo | Chưa đo |
| EXPLAIN: Extra | Chưa đo | Chưa đo |

Index_length là dung lượng cấp phát ước lượng cho các secondary index của InnoDB, không phải lượng RAM thực dùng. Giảm dung lượng index không bảo đảm file .ibd hoặc hóa đơn cloud giảm tương ứng ngay.
