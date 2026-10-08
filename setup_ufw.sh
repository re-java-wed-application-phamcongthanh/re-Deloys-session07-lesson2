#!/bin/bash
# ==============================================================================
# Script: setup_ufw.sh
# Mo ta: Cau hinh tuong lua UFW cho cum dich vu Multi-port
# Khoa hoc: DevOps Fundamentals - Session 07 - Bai 2
# ==============================================================================

set -e

echo "=== [1/5] Kiem tra quyen root ==="
if [ "$EUID" -ne 0 ]; then
  echo "Loi: Vui long chay script duoi quyen root hoac dung sudo!"
  exit 1
fi

echo "=== [2/5] Dat chinh sach mac dinh (Default Policies) ==="
# Chan tat ca luu luong den (Deny incoming)
ufw default deny incoming
# Cho phap luu luong di (Allow outgoing)
ufw default allow outgoing

echo "=== [3/5] Mo cac cong dich vu quy dinh ==="
# 1. Cong SSH (Port 22/tcp)
ufw allow 22/tcp comment 'Allow SSH Management'

# 2. Cong Nginx Web HTTP (Port 80/tcp)
ufw allow 80/tcp comment 'Allow Web HTTP Traffic'

# 3. Cong Spring Boot App (Port 8082/tcp)
ufw allow 8082/tcp comment 'Allow Spring Boot Backend'

# LUU Y: Cong MySQL (3306/tcp) KHONG duoc add rule allow de dam bao bi chan mac dinh!

echo "=== [4/5] Kich hoat tuong lua UFW ==="
ufw --force enable

echo "=== [5/5] Kiem tra trang thai UFW chi tiet ==="
ufw status verbose
echo "================================================="
echo "CAU HINH TUONG LUA UFW HOAN THANH THANH CONG!"
echo "================================================="
