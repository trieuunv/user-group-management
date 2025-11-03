#!/bin/bash

# Tạo user mới
create_user() {
    local username=$1
    if id "$username" &>/dev/null; then
        echo "[WARN] User $username đã tồn tại." >> logs/user.log
    else
        sudo useradd "$username"
        echo "[INFO] User $username đã được tạo." >> logs/user.log
    fi
}

# Xóa user
delete_user() {
    local username=$1
    if id "$username" &>/dev/null; then
        sudo userdel -r "$username"
        echo "[INFO] User $username đã bị xóa." >> logs/user.log
    else
        echo "[ERROR] User $username không tồn tại." >> logs/user.log
    fi
}

