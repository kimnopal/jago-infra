#!/bin/bash

# ==============================================================================
# Script Inisialisasi Server v3 (Tampilan Modern)
# Didesain untuk Web Development (PHP/Laravel) di Ubuntu/Debian
#
# Jalankan dengan: sudo ./init.sh
# ==============================================================================

# Keluar dari script jika ada perintah yang gagal
set -e

# --- Konfigurasi ---
LOG_FILE="/tmp/server_init.log"

# --- Definisi Warna ---
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"
BOLD="\e[1m"

# Hapus file log lama jika ada
rm -f $LOG_FILE

# --- Fungsi Bantuan untuk Menjalankan Tugas ---
# Argumen 1: Pesan/Deskripsi tugas
# Argumen 2: Perintah yang akan dijalankan
run_task() {
    echo -n -e "${YELLOW}❯ ${RESET}$1..."
    # Jalankan perintah, alihkan semua output ke file log
    if eval "$2" >> $LOG_FILE 2>&1; then
        echo -e "\r${GREEN}✔ ${RESET}$1... ${BOLD}SELESAI${RESET}"
    else
        echo -e "\r${RED}✖ ${RESET}$1... ${BOLD}GAGAL${RESET}"
        echo "  Lihat detail error di: $LOG_FILE"
        exit 1
    fi
}

# ==============================================================================
# MULAI EKSEKUSI SKRIP
# ==============================================================================

clear
echo -e "${BOLD}${GREEN}🚀 Memulai Inisialisasi Server...${RESET}"
echo "--------------------------------------------------"

# Setup frontend non-interaktif untuk menghindari prompt konfirmasi dari apt
export DEBIAN_FRONTEND=noninteractive

run_task "Memperbarui repositori paket" "apt-get update"
run_task "Meng-upgrade sistem" "apt-get upgrade -y"
run_task "Menginstal tools penting" "apt-get install -y curl git ufw unzip zip software-properties-common"
run_task "Menambahkan PPA PHP dari Ondřej Surý" "add-apt-repository ppa:ondrej/php -y"
run_task "Memperbarui daftar paket setelah PPA" "apt-get update"
run_task "Menginstal PHP 8.4 dan ekstensi umum" "apt-get install -y php8.4 php8.4-cli php8.4-fpm php8.4-curl php8.4-mbstring php8.4-xml php8.4-bcmath php8.4-zip php8.4-bz2 php8.4-gd php8.4-tidy php8.4-xsl php8.4-sqlite3 php8.4-pgsql php8.4-mysql"
run_task "Menginstal Composer secara global" "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"

# Instalasi NodeJS menggunakan NVM
# Kita perlu menjalankan ini dalam sub-shell agar nvm bisa digunakan langsung
run_task "Menginstal NVM (Node Version Manager)" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
run_task "Menginstal NodeJS v22 via NVM" 'bash -c ". ~/.nvm/nvm.sh && nvm install 22"'

run_task "Menginstal PostgreSQL" "apt-get install -y postgresql postgresql-contrib"
run_task "Menjalankan & mengaktifkan PostgreSQL" "systemctl enable --now postgresql"
run_task "Menginstal MySQL Server" "apt-get install -y mysql-server"
run_task "Menjalankan & mengaktifkan MySQL" "systemctl enable --now mysql"
run_task "Menginstal Nginx" "apt-get install -y nginx"
run_task "Menjalankan & mengaktifkan Nginx" "systemctl enable --now nginx"
run_task "Menginstal dependensi untuk Certbot" "apt-get install -y python3-dev python3-venv libaugeas-dev gcc"
run_task "Membuat virtual environment untuk Certbot" "python3 -m venv /opt/certbot/"
run_task "Menginstal Certbot & plugin Nginx" "/opt/certbot/bin/pip install --upgrade pip certbot certbot-nginx"
run_task "Membuat symlink untuk Certbot" "ln -sf /opt/certbot/bin/certbot /usr/bin/certbot"
run_task "Konfigurasi UFW Firewall" "ufw allow OpenSSH && ufw allow 'Nginx Full'"
run_task "Mengaktifkan UFW Firewall" "ufw --force enable"
run_task "Menginstal Fail2ban" "apt install fail2ban"
run_task "Mengaktifkan Fail2ban" "systemctl enable --now fail2ban"

# ==============================================================================
# SELESAI
# ==============================================================================

echo "--------------------------------------------------"
echo -e "${BOLD}${GREEN}✅ Semua proses telah selesai! Server Anda siap digunakan.${RESET}"
echo
echo "   RINGKASAN:"
echo -e "   - ${GREEN}✔${RESET} PHP 8.4 & Composer"
echo -e "   - ${GREEN}✔${RESET} NodeJS v22 (via NVM)"
echo -e "   - ${GREEN}✔${RESET} Nginx, PostgreSQL, MySQL"
echo -e "   - ${GREEN}✔${RESET} Certbot (Let's Encrypt)"
echo -e "   - ${GREEN}✔${RESET} UFW Firewall aktif"
echo -e "   - ${GREEN}✔${RESET} Fail2ban aktif"
echo
echo -e "   ${YELLOW}Catatan:${RESET} Jika terjadi error, detail lengkap tersimpan di ${BOLD}${LOG_FILE}${RESET}"
echo "--------------------------------------------------"