#!/bin/bash

# Tự động chuyển sang quyền root nếu chưa có
if [ "$EUID" -ne 0 ]; then
    echo "Chuyển sang quyền root..."
    exec sudo -s "$0"
    exit
fi

# Cài đặt Squid
echo "Bắt đầu cài đặt Squid..."
wget -q https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/squid3-install.sh -O squid3-install.sh
if [ -f "squid3-install.sh" ]; then
    bash squid3-install.sh
else
    echo "Không thể tải squid3-install.sh. Kiểm tra URL tải xuống."
    exit 1
fi

# Thêm người dùng Proxy
echo "Cấu hình người dùng Proxy..."
read -p "Nhập tên người dùng Proxy: " proxy_user
read -sp "Nhập mật khẩu Proxy: " proxy_pass
echo
sudo squid-add-user <<EOF
$proxy_user
$proxy_pass
$proxy_pass
EOF

# Cài đặt Net tools
echo "Cài đặt Net-tools..."
apt update && apt install -y net-tools

# Lấy IP máy chủ
server_ip=$(hostname -I | awk '{print $1}')
if [ -z "$server_ip" ]; then
    echo "Không thể lấy địa chỉ IP máy chủ."
    exit 1
fi

# Xuất thông tin Proxy
proxy_port=3128
echo "Proxy đã được tạo thành công!"
echo "Định dạng: IP:Port:User:Passwd"
echo "Proxy: $server_ip:$proxy_port:$proxy_user:$proxy_pass"

# Lưu thông tin Proxy vào file
output_file="proxy_info.txt"
echo "$server_ip:$proxy_port:$proxy_user:$proxy_pass" > "$output_file"
echo "Thông tin Proxy đã được lưu vào $output_file."
