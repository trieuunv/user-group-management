#!/bin/bash

# Gọi các file khác
source user.sh
source group.sh

process_file() {
    local file=$1
    while IFS=',' read -r action user group; do
        case $action in
            create_user) create_user "$user" ;;
            delete_user) delete_user "$user" ;;
            create_group) create_group "$group" ;;
            delete_group) delete_group "$group" ;;
            add_to_group) add_user_to_group "$user" "$group" ;;
            *)
                echo "[ERROR] Lệnh không hợp lệ: $action" >> logs/error.log
                ;;
        esac
    done < "$file"
}

