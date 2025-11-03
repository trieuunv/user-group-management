#!/bin/bash

# Tạo group mới
create_group() {
    local groupname=$1
    if getent group "$groupname" &>/dev/null; then
        echo "[WARN] Group $groupname đã tồn tại." >> logs/group.log
    else
        sudo groupadd "$groupname"
        echo "[INFO] Group $groupname đã được tạo." >> logs/group.log
    fi
}

# Xóa group
delete_group() {
    local groupname=$1
    if getent group "$groupname" &>/dev/null; then
        sudo groupdel "$groupname"
        echo "[INFO] Group $groupname đã bị xóa." >> logs/group.log
    else
        echo "[ERROR] Group $groupname không tồn tại." >> logs/group.log
    fi
}

# Thêm user vào group
add_user_to_group() {
    local username=$1
    local groupname=$2
    if id "$username" &>/dev/null && getent group "$groupname" &>/dev/null; then
        sudo usermod -aG "$groupname" "$username"
        echo "[INFO] Đã thêm $username vào nhóm $groupname." >> logs/group.log
    else
        echo "[ERROR] User hoặc Group không tồn tại." >> logs/group.log
    fi
}

