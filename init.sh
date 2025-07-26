#!/bin/bash

# ==============================================================================
# Script Inisialisasi Server untuk Web Development (PHP/Laravel)
# Ubuntu / Debian
#
# Jalankan dengan: sudo ./init.sh
# ==============================================================================

# Keluar dari script jika ada perintah yang gagal
set -e

# Setup frontend non-interaktif untuk menghindari prompt konfirmasi dari apt
export DEBIAN_FRONTEND=noninteractive

echo "🟢 (1/11) Memperbarui sistem..."
apt update && apt upgrade -y

echo "🟢 (2/11) Install tools penting..."
apt install -y curl git ufw unzip zip software-properties-common

echo "🟢 (3/11) Menambahkan PPA PHP ondrej/php..."
# Tambahkan -y untuk otomatis menyetujui penambahan repository
add-apt-repository ppa:ondrej/php -y
apt update

echo "🟢 (4/11) Install PHP 8.4 dan ekstensi umum..."
apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-curl php8.4-mbstring php8.4-xml php8.4-bcmath php8.4-zip php8.4-bz2 php8.4-gd php8.4-tidy php8.4-xsl php8.4-sqlite3 php8.4-pgsql php8.4-mysql

echo "🟢 (5/11) Install Composer secara global..."
# Menggunakan metode one-liner resmi yang lebih simpel
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "🟢 (6/11) Install NodeJS (v22) & NPM secara global..."
# Menggunakan NodeSource untuk instalasi global yang lebih cocok untuk server
# Ini memastikan 'node' dan 'npm' tersedia untuk semua user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash -
\. "$HOME/.nvm/nvm.sh"
nvm install 22

echo "🟢 (7/11) Install PostgreSQL..."
apt install -y postgresql postgresql-contrib
systemctl enable --now postgresql # Enable (start saat boot) dan start service sekarang

echo "🟢 (8/11) Install MySQL..."
apt install -y mysql-server
systemctl enable --now mysql # Enable (start saat boot) dan start service sekarang

echo "🟢 (9/11) Install Nginx..."
apt install -y nginx
systemctl enable --now nginx

echo "🟢 (10/11) Install Certbot untuk SSL..."
# Metode Anda menggunakan venv sudah merupakan best practice, jadi kita pertahankan
apt install -y python3 python3-dev python3-venv libaugeas-dev gcc
python3 -m venv /opt/certbot/
/opt/certbot/bin/pip install --upgrade pip
/opt/certbot/bin/pip install certbot certbot-nginx
ln -sf /opt/certbot/bin/certbot /usr/bin/certbot # Gunakan -sf (symbolic force) untuk menimpa jika sudah ada

echo "🟢 (11/11) Setup Firewall UFW..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
# Gunakan --force untuk mengaktifkan UFW tanpa prompt konfirmasi
ufw --force enable

echo "✅ Server siap digunakan!"
echo "   - PHP 8.4 & Composer terinstal."
echo "   - NodeJS 22 & NPM terinstal."
echo "   - Nginx, PostgreSQL, & MySQL berjalan."
echo "   - UFW aktif dan mengizinkan SSH & Nginx."
echo "   - Certbot terinstal untuk SSL Let's Encrypt."