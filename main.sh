#!/bin/bash
# ==========================================================
#  USER & GROUP MANAGEMENT TOOL
# ==========================================================

# ----- MÀU SẮC -----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ----- THƯ MỤC LOG -----
LOG_DIR="logs"
USER_LOG="$LOG_DIR/user.log"
GROUP_LOG="$LOG_DIR/group.log"
ERROR_LOG="$LOG_DIR/error.log"
mkdir -p "$LOG_DIR"

# ----- GHI LOG -----
log_user()   { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$USER_LOG"; }
log_group()  { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$GROUP_LOG"; }
log_error()  { echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$ERROR_LOG"; }

# ----- HIỆU ỨNG LOADING -----
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ----- HIỂN THỊ MENU -----
show_menu() {
    clear
    echo -e "${CYAN}=================================================${NC}"
    echo -e "${YELLOW}         🧑‍💻 USER & GROUP MANAGEMENT TOOL 🧑‍💻${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo -e "${GREEN}1.${NC}  Tạo user mới"
    echo -e "${GREEN}2.${NC}  Xóa user"
    echo -e "${GREEN}3.${NC}  Hiển thị danh sách user"
    echo -e "${GREEN}4.${NC}  Tạo group mới"
    echo -e "${GREEN}5.${NC}  Xóa group"
    echo -e "${GREEN}6.${NC}  Hiển thị danh sách group"
    echo -e "${GREEN}7.${NC}  Thêm user vào group"
    echo -e "${GREEN}8.${NC}  Xóa user khỏi group"
    echo -e "${GREEN}9.${NC}  Xem thông tin chi tiết user"
    echo -e "${GREEN}10.${NC} Xem thông tin chi tiết group"
    echo -e "${GREEN}11.${NC} Chạy script từ file tasks.txt"
    echo -e "${GREEN}12.${NC} Xem file log"
    echo -e "${GREEN}0.${NC}  Thoát"
    echo -e "${CYAN}-------------------------------------------------${NC}"
}

# ----- CÁC CHỨC NĂNG -----

create_user() {
    read -p "Nhập tên user muốn tạo: " username
    if id "$username" &>/dev/null; then
        echo -e "${RED}⚠️ User '$username' đã tồn tại.${NC}"
        log_error "Tạo user '$username' thất bại: đã tồn tại."
    else
        sudo useradd -m "$username" && sudo passwd "$username" &
        spinner
        echo -e "${GREEN}✅ User '$username' đã được tạo thành công.${NC}"
        log_user "Tạo user '$username' thành công."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

delete_user() {
    read -p "Nhập tên user muốn xóa: " username
    if id "$username" &>/dev/null; then
        sudo userdel -r "$username" &
        spinner
        echo -e "${GREEN}🗑️ User '$username' đã bị xóa.${NC}"
        log_user "Xóa user '$username' thành công."
    else
        echo -e "${RED}⚠️ User '$username' không tồn tại.${NC}"
        log_error "Xóa user '$username' thất bại: không tồn tại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

list_users() {
    echo -e "${YELLOW}📋 Danh sách user:${NC}"
    echo -e "${CYAN}--------------------------------------------${NC}"
    awk -F: '$3 >= 1000 {printf "👤 %-15s | UID: %s | Home: %s\n", $1, $3, $6}' /etc/passwd | sort
    echo -e "${CYAN}--------------------------------------------${NC}"
    log_user "Xem danh sách user."
    read -p "Nhấn Enter để quay lại menu..."
}

create_group() {
    read -p "Nhập tên group muốn tạo: " groupname
    if getent group "$groupname" &>/dev/null; then
        echo -e "${RED}⚠️ Group '$groupname' đã tồn tại.${NC}"
        log_error "Tạo group '$groupname' thất bại: đã tồn tại."
    else
        sudo groupadd "$groupname" &
        spinner
        echo -e "${GREEN}✅ Group '$groupname' đã được tạo thành công.${NC}"
        log_group "Tạo group '$groupname' thành công."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

delete_group() {
    read -p "Nhập tên group muốn xóa: " groupname
    if getent group "$groupname" &>/dev/null; then
        sudo groupdel "$groupname" &
        spinner
        echo -e "${GREEN}🗑️ Group '$groupname' đã bị xóa.${NC}"
        log_group "Xóa group '$groupname' thành công."
    else
        echo -e "${RED}⚠️ Group '$groupname' không tồn tại.${NC}"
        log_error "Xóa group '$groupname' thất bại: không tồn tại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

list_groups() {
    echo -e "${YELLOW}📂 Danh sách group người dùng:${NC}"
    echo -e "${CYAN}--------------------------------------------${NC}"
    awk -F: '$3 >= 1000 {
        printf "📁 %-15s | Thành viên: %s\n", $1, ($4 == "" ? "(Không có)" : $4)
    }' /etc/group | sort
    echo -e "${CYAN}--------------------------------------------${NC}"
    log_group "Xem danh sách group."
    read -p "Nhấn Enter để quay lại menu..."
}

add_user_to_group() {
    read -p "Nhập tên user: " username
    read -p "Nhập tên group: " groupname
    if id "$username" &>/dev/null && getent group "$groupname" &>/dev/null; then
        sudo usermod -aG "$groupname" "$username" &
        spinner
        echo -e "${GREEN}✅ User '$username' đã được thêm vào group '$groupname'.${NC}"
        log_group "Thêm user '$username' vào group '$groupname'."
    else
        echo -e "${RED}⚠️ User hoặc group không tồn tại.${NC}"
        log_error "Thêm user '$username' vào group '$groupname' thất bại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

remove_user_from_group() {
    read -p "Nhập tên user: " username
    read -p "Nhập tên group: " groupname
    if id "$username" &>/dev/null && getent group "$groupname" &>/dev/null; then
        sudo gpasswd -d "$username" "$groupname" &
        spinner
        echo -e "${GREEN}✅ Đã xóa user '$username' khỏi group '$groupname'.${NC}"
        log_group "Xóa user '$username' khỏi group '$groupname'."
    else
        echo -e "${RED}⚠️ User hoặc group không tồn tại.${NC}"
        log_error "Xóa user '$username' khỏi group '$groupname' thất bại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

show_user_info() {
    read -p "Nhập tên user cần xem: " username
    if id "$username" &>/dev/null; then
        echo -e "${YELLOW}🔍 Thông tin chi tiết user '$username':${NC}"
        id "$username"
        echo -e "${CYAN}Home directory:${NC} $(eval echo ~$username)"
        echo -e "${CYAN}Shell:${NC} $(getent passwd "$username" | cut -d: -f7)"
        log_user "Xem thông tin user '$username'."
    else
        echo -e "${RED}⚠️ User '$username' không tồn tại.${NC}"
        log_error "Xem thông tin user '$username' thất bại: không tồn tại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

show_group_info() {
    read -p "Nhập tên group cần xem: " groupname
    if getent group "$groupname" &>/dev/null; then
        echo -e "${YELLOW}🔍 Thông tin chi tiết group '$groupname':${NC}"
        getent group "$groupname"
        log_group "Xem thông tin group '$groupname'."
    else
        echo -e "${RED}⚠️ Group '$groupname' không tồn tại.${NC}"
        log_error "Xem thông tin group '$groupname' thất bại: không tồn tại."
    fi
    read -p "Nhấn Enter để tiếp tục..."
}

# ----- CHẠY LỆNH TỪ FILE tasks.txt -----
run_from_file() {
    if [ ! -f "tasks.txt" ]; then
        echo -e "${RED}⚠️ File tasks.txt không tồn tại.${NC}"
        log_error "Không tìm thấy file tasks.txt."
        read -p "Nhấn Enter để tiếp tục..."
        return
    fi

    echo -e "${YELLOW}🚀 Đang chạy các lệnh trong tasks.txt...${NC}"
    echo -e "${CYAN}--------------------------------------------${NC}"

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        echo -e "${MAGENTA}Thực hiện: ${NC}$line"
        eval "$line"
        log_user "Chạy lệnh từ tasks.txt: $line"
        sleep 0.3
    done < "tasks.txt"

    echo -e "${CYAN}--------------------------------------------${NC}"
    echo -e "${GREEN}✅ Hoàn thành chạy file tasks.txt${NC}"
    read -p "Nhấn Enter để tiếp tục..."
}

# ----- XEM LOG -----
view_logs() {
    clear
    echo -e "${YELLOW}📄 USER LOG:${NC}"
    cat "$USER_LOG" 2>/dev/null || echo "(Trống)"
    echo
    echo -e "${YELLOW}📄 GROUP LOG:${NC}"
    cat "$GROUP_LOG" 2>/dev/null || echo "(Trống)"
    echo
    echo -e "${YELLOW}⚠️ ERROR LOG:${NC}"
    cat "$ERROR_LOG" 2>/dev/null || echo "(Trống)"
    echo
    read -p "Nhấn Enter để quay lại menu..."
}

# ----- MAIN -----
while true; do
    show_menu
    read -p "👉 Nhập lựa chọn của bạn: " choice
    case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) create_group ;;
        5) delete_group ;;
        6) list_groups ;;
        7) add_user_to_group ;;
        8) remove_user_from_group ;;
        9) show_user_info ;;
        10) show_group_info ;;
        11) run_from_file ;;
        12) view_logs ;;
        0) echo -e "${GREEN}👋 Thoát chương trình. Tạm biệt!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Lựa chọn không hợp lệ. Vui lòng thử lại.${NC}"; sleep 1 ;;
    esac
done

