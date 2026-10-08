# Báo Cáo Bài 2: Quản trị Tường lửa UFW cho Cụm Dịch vụ Multi-port

## 🎯 1. Mục Tiêu
- Thiết lập tường lửa UFW (Uncomplicated Firewall) để bảo vệ máy chủ chạy nhiều dịch vụ cùng lúc.
- Cấu hình nguyên tắc bảo mật phòng thủ chiều sâu (Defense-in-Depth): Chặn mặc định tất cả truy cập đầu vào (`deny incoming`), chỉ mở chính xác các cổng dịch vụ cần thiết.
- Tách biệt vùng dịch vụ: Cho phép truy cập cổng Web (80), Spring Boot (8082), SSH (22) và cô lập hoàn toàn cổng cơ sở dữ liệu MySQL (3306) khỏi mạng Internet.

---

## 📋 2. Quy Trình Thực Hiện (Step-by-Step Guide)

### Bước 1: Khai báo chính sách mặc định (Default Policies)
Thiết lập quy tắc an toàn nhất: Chặn toàn bộ kết nối đi vào và mở toàn bộ kết nối đi ra:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Bước 2: Khai báo các quy tắc mở cổng dịch vụ
Mở các cổng dịch vụ công khai được phép truy cập từ xa:
```bash
# 1. Cho phép SSH (Port 22/tcp) để quản trị từ xa
sudo ufw allow 22/tcp

# 2. Cho phép HTTP (Port 80/tcp) cho dịch vụ Nginx Web
sudo ufw allow 80/tcp

# 3. Cho phép Spring Boot App (Port 8082/tcp) cho kiểm thử ứng dụng
sudo ufw allow 8082/tcp
```

> ⚠️ **Lưu ý quan trọng**: Không thực hiện bất kỳ lệnh `ufw allow 3306` nào. Cổng MySQL 3306/tcp tự động bị chặn nhờ chính sách `default deny incoming`.

### Bước 3: Kích hoạt tường lửa UFW
```bash
sudo ufw enable
```
*(Nhấn `y` khi hệ thống hỏi xác nhận)*

---

## ✅ 3. Kết Quả Kiểm Tra & Xác Minh (Verification)

Chạy lệnh kiểm tra trạng thái tường lửa chi tiết:
```bash
sudo ufw status verbose
```

### Output mẫu hiển thị trên VPS:
```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  # Allow SSH Management
80/tcp                     ALLOW IN    Anywhere                  # Allow Web HTTP Traffic
8082/tcp                   ALLOW IN    Anywhere                  # Allow Spring Boot Backend
22/tcp (v6)                ALLOW IN    Anywhere (v6)             # Allow SSH Management
80/tcp (v6)                ALLOW IN    Anywhere (v6)             # Allow Web HTTP Traffic
8082/tcp (v6)              ALLOW IN    Anywhere (v6)             # Allow Spring Boot Backend
```

---

## 📊 4. Đối Chiếu Bảng Quy Tắc Tường Lửa

| Dịch vụ | Cổng (Port / Protocol) | Trạng thái UFW | Ý nghĩa Bảo mật |
|---|---|---|---|
| SSH | `22/tcp` | **ALLOW IN** | Cho phép quản trị viên kết nối Terminal quản trị hệ thống. |
| Nginx Web | `80/tcp` | **ALLOW IN** | Phục vụ người dùng truy cập trang chủ giao diện tĩnh. |
| Spring Boot | `8082/tcp` | **ALLOW IN** | Phục vụ kết nối API backend từ xa. |
| MySQL Database | `3306/tcp` | **BLOCKED (Implicit)** | Cô lập cơ sở dữ liệu. Chỉ cho phép kết nối nội bộ từ local (`127.0.0.1`). |

---

## 🛡️ 5. Đánh Giá & Nguyên Tắc Bảo Mật
1. **Bảo vệ Cơ sở dữ liệu**: MySQL chứa dữ liệu nhạy cảm. Việc chặn cổng `3306` từ Internet giúp ngăn ngừa 100% các cuộc tấn công dò mật khẩu (Brute-force) và khai thác lỗ hổng trực tiếp từ bên ngoài.
2. **Triết lý Least Privilege Firewall**: Tất cả các cổng chưa được khai báo `allow` sẽ mặc định bị từ chối truy cập.
3. **An toàn SSH**: Luôn mở quy tắc `22/tcp` trước khi kích hoạt `ufw enable` để tránh bị mốt kết nối SSH điều khiển VPS.
