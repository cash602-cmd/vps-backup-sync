#!/usr/bin/env bash
# ==============================================================================
# VPS Backup Sync - Lightweight VPS Backup & Server-to-Server Migration Tool
# Author: cash602-cmd (VPS Rankings)
# Website: https://vpsrankings.com
# GitHub: https://github.com/cash602-cmd/vps-backup-sync
# License: MIT
# ==============================================================================

set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

DEFAULT_BACKUP_DIR="/root/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Print Header Banner
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "================================================================================"
    echo "  📦 VPS Backup Sync v1.0.0 — Fast, Secure Backup & Server Migration Utility"
    echo "  🌐 Project Home: https://github.com/cash602-cmd/vps-backup-sync"
    echo "  📊 Benchmarks & Storage VPS Picks: https://vpsrankings.com"
    echo "================================================================================"
    echo -e "${NC}"
}

# Check and install essential dependencies
check_dependencies() {
    echo -e "${BLUE}🔍 Checking required dependencies...${NC}"
    local missing=()
    for cmd in tar gzip rsync ssh sha256sum; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing missing packages: ${missing[*]}...${NC}"
        if command -v apt-get &>/dev/null; then
            apt-get update -qq && apt-get install -y -qq "${missing[@]}"
        elif command -v dnf &>/dev/null; then
            dnf install -y -q "${missing[@]}"
        elif command -v yum &>/dev/null; then
            yum install -y -q "${missing[@]}"
        else
            echo -e "${RED}❌ Please manually install required packages: ${missing[*]}${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✔ All core dependencies are installed.${NC}\n"
}

# 1. Local Full Backup (Files + Databases)
backup_local() {
    echo -e "${CYAN}${BOLD}--- [1] One-Click Local Backup ---${NC}"
    read -rp "Enter target directory to backup [default: /var/www/html]: " WEB_DIR
    WEB_DIR=${WEB_DIR:-/var/www/html}

    if [ ! -d "$WEB_DIR" ]; then
        echo -e "${YELLOW}Warning: Directory '$WEB_DIR' does not exist. Backing up only databases if found.${NC}"
    fi

    mkdir -p "$DEFAULT_BACKUP_DIR"
    local ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
    local TARGET_ARCHIVE="${DEFAULT_BACKUP_DIR}/${ARCHIVE_NAME}"
    local TEMP_DIR="/tmp/vps_backup_${TIMESTAMP}"
    mkdir -p "$TEMP_DIR"

    # Backup Web Files
    if [ -d "$WEB_DIR" ]; then
        echo -e "${BLUE}📦 Packing web files from $WEB_DIR...${NC}"
        tar -czf "${TEMP_DIR}/web_files.tar.gz" -C "$(dirname "$WEB_DIR")" "$(basename "$WEB_DIR")"
    fi

    # Detect and Dump MySQL / MariaDB
    if command -v mysqldump &>/dev/null; then
        echo -e "${BLUE}🐬 Detected MySQL/MariaDB. Attempting all-databases dump...${NC}"
        read -rp "MySQL Username [default: root]: " DB_USER
        DB_USER=${DB_USER:-root}
        read -rsp "MySQL Password (leave empty if using unix_socket/auth_socket): " DB_PASS
        echo ""
        if [ -n "$DB_PASS" ]; then
            mysqldump -u"$DB_USER" -p"$DB_PASS" --all-databases --single-transaction --quick 2>/dev/null > "${TEMP_DIR}/all_databases.sql" || true
        else
            mysqldump -u"$DB_USER" --all-databases --single-transaction --quick 2>/dev/null > "${TEMP_DIR}/all_databases.sql" || true
        fi
        if [ -s "${TEMP_DIR}/all_databases.sql" ]; then
            gzip "${TEMP_DIR}/all_databases.sql"
            echo -e "${GREEN}✔ Database successfully dumped and compressed.${NC}"
        else
            echo -e "${YELLOW}ℹ Skipping database dump (credentials empty or socket auth disabled).${NC}"
            rm -f "${TEMP_DIR}/all_databases.sql"
        fi
    fi

    # Detect and Dump PostgreSQL
    if command -v pg_dumpall &>/dev/null; then
        echo -e "${BLUE}🐘 Detected PostgreSQL. Dumping all clusters...${NC}"
        sudo -u postgres pg_dumpall 2>/dev/null | gzip > "${TEMP_DIR}/pg_databases.sql.gz" || true
    fi

    # Create Final Consolidated Archive
    echo -e "${BLUE}🗜 Compressing final archive: $TARGET_ARCHIVE...${NC}"
    tar -czf "$TARGET_ARCHIVE" -C "$TEMP_DIR" .
    rm -rf "$TEMP_DIR"

    # Generate SHA256 Checksum
    local CHECKSUM
    CHECKSUM=$(sha256sum "$TARGET_ARCHIVE" | awk '{print $1}')
    echo "$CHECKSUM  $ARCHIVE_NAME" > "${TARGET_ARCHIVE}.sha256"

    local SIZE
    SIZE=$(du -h "$TARGET_ARCHIVE" | awk '{print $1}')

    echo -e "\n${GREEN}${BOLD}🎉 Backup completed successfully!${NC}"
    echo -e "📁 Archive Path : ${YELLOW}${TARGET_ARCHIVE}${NC}"
    echo -e "⚖ Archive Size : ${YELLOW}${SIZE}${NC}"
    echo -e "🔑 SHA256 Hash  : ${PURPLE}${CHECKSUM}${NC}"
}

# 2. Server-to-Server Live Migration
migrate_to_server() {
    echo -e "${CYAN}${BOLD}--- [2] Server-to-Server Live Migration ---${NC}"
    echo "This feature uses rsync over SSH to mirror files and backups to another VPS."
    echo ""
    read -rp "Target VPS IP or Hostname: " REMOTE_HOST
    read -rp "Target SSH Port [default: 22]: " REMOTE_PORT
    REMOTE_PORT=${REMOTE_PORT:-22}
    read -rp "Target SSH User [default: root]: " REMOTE_USER
    REMOTE_USER=${REMOTE_USER:-root}
    read -rp "Source Directory/File to transfer [default: /var/www/html]: " LOCAL_PATH
    LOCAL_PATH=${LOCAL_PATH:-/var/www/html}
    read -rp "Destination Path on Remote Server [default: /var/www/html]: " REMOTE_PATH
    REMOTE_PATH=${REMOTE_PATH:-/var/www/html}

    if [ ! -e "$LOCAL_PATH" ]; then
        echo -e "${RED}❌ Error: Source path '$LOCAL_PATH' does not exist.${NC}"
        return
    fi

    echo -e "\n${BLUE}🚀 Starting high-speed rsync migration with resume support...${NC}"
    rsync -avzP --partial --inplace -e "ssh -p $REMOTE_PORT -o StrictHostKeyChecking=no" "$LOCAL_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

    echo -e "\n${GREEN}${BOLD}✔ Migration transfer completed successfully!${NC}"
}

# 3. Remote Download / Pull from Another VPS
download_from_server() {
    echo -e "${CYAN}${BOLD}--- [3] Download Backup from Remote VPS ---${NC}"
    read -rp "Remote VPS IP or Hostname: " REMOTE_HOST
    read -rp "Remote SSH Port [default: 22]: " REMOTE_PORT
    REMOTE_PORT=${REMOTE_PORT:-22}
    read -rp "Remote SSH User [default: root]: " REMOTE_USER
    REMOTE_USER=${REMOTE_USER:-root}
    read -rp "Remote File/Directory Path: " REMOTE_PATH
    read -rp "Local Destination Path [default: $DEFAULT_BACKUP_DIR]: " LOCAL_DEST
    LOCAL_DEST=${LOCAL_DEST:-$DEFAULT_BACKUP_DIR}

    mkdir -p "$LOCAL_DEST"
    echo -e "\n${BLUE}📥 Pulling remote archive with rsync resume...${NC}"
    rsync -avzP --partial -e "ssh -p $REMOTE_PORT -o StrictHostKeyChecking=no" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" "$LOCAL_DEST"

    echo -e "\n${GREEN}${BOLD}✔ Download finished. Saved to: ${LOCAL_DEST}${NC}"
}

# 4. Automated Daily Cron Setup
setup_cron() {
    echo -e "${CYAN}${BOLD}--- [4] Setup Automated Daily Backup & 7-Day Auto-Prune ---${NC}"
    local CRON_SCRIPT="/usr/local/bin/vps_daily_backup.sh"

    cat << 'EOF' > "$CRON_SCRIPT"
#!/usr/bin/env bash
BACKUP_DIR="/root/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p "$BACKUP_DIR"

# 1. Dump database if exists
if command -v mysqldump &>/dev/null; then
    mysqldump --all-databases --single-transaction --quick 2>/dev/null | gzip > "${BACKUP_DIR}/db_${TIMESTAMP}.sql.gz" || true
fi

# 2. Backup web directory if exists
if [ -d "/var/www/html" ]; then
    tar -czf "${BACKUP_DIR}/web_${TIMESTAMP}.tar.gz" -C /var/www html
fi

# 3. Remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +7 -delete
EOF

    chmod +x "$CRON_SCRIPT"

    # Add to crontab (Run daily at 3:30 AM)
    (crontab -l 2>/dev/null | grep -v "vps_daily_backup.sh" ; echo "30 3 * * * $CRON_SCRIPT >/dev/null 2>&1") | crontab -

    echo -e "${GREEN}✔ Automated daily backup task created at: 03:30 AM every night.${NC}"
    echo -e "${GREEN}✔ Backups older than 7 days will be automatically purged to save disk space.${NC}"
}

# Footer Recommendations
print_footer() {
    echo -e "\n${CYAN}================================================================================"
    echo -e " 💡 ${BOLD}Helpful Resources from VPS Rankings:${NC}"
    echo -e "  • 🏆 Top Storage & Cheap Backup VPS 2026: ${YELLOW}https://vpsrankings.com/vps/best-cheap-vps${NC}"
    echo -e "  • ⚡ Free Global Network Latency & Speed Test: ${YELLOW}https://vpsrankings.com/tools/speed-test${NC}"
    echo -e "  • 📊 Compare Real Hardware Benchmarks: ${YELLOW}https://vpsrankings.com/benchmarks${NC}"
    echo -e "${CYAN}================================================================================${NC}\n"
}

# Main Interactive Menu
main_menu() {
    print_banner
    check_dependencies

    echo -e "${BOLD}Please select an operation:${NC}"
    echo -e "  ${GREEN}1)${NC} 📦 Local Full Backup (Files + Databases + SHA256)"
    echo -e "  ${GREEN}2)${NC} 🚀 Live Server-to-Server Migration (Rsync over SSH)"
    echo -e "  ${GREEN}3)${NC} 📥 Download Remote Backup to Local Machine"
    echo -e "  ${GREEN}4)${NC} ⏰ Configure Automated Daily Backup (Cron + 7-Day Auto-Purge)"
    echo -e "  ${GREEN}0)${NC} 🚪 Exit"
    echo ""
    read -rp "Enter choice [0-4]: " CHOICE

    case "$CHOICE" in
        1) backup_local ;;
        2) migrate_to_server ;;
        3) download_from_server ;;
        4) setup_cron ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac

    print_footer
}

main_menu
