#!/bin/bash
# ============================================
# KONFIGURASI TOKO BERAS DZIKDZAK
# ============================================
# GANTI nilai di bawah dengan data asli kamu!

# Informasi Toko
BRAND_NAME="DZIK & DZAK"
TOKO_NAME="Toko Beras DzikDzak"
WA_NUMBER="6281234567890"          # GANTI dengan nomor WA asli
WA_LINK="https://wa.me/6281234567890"  # GANTI dengan link WA asli
LOCATION="Kecamatan [nama]"        # GANTI dengan lokasi asli

# Path Folder
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$BASE_DIR/raw"
READY_DIR="$BASE_DIR/ready"
MUSIC_DIR="$BASE_DIR/music"
SCRIPT_DIR="$BASE_DIR/scripts"
THUMB_DIR="$BASE_DIR/thumbnails"

# Font untuk teks (gunakan font default system)
FONT_FILE="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# Ukuran Video TikTok (9:16 portrait)
VIDEO_WIDTH=1080
VIDEO_HEIGHT=1920

# Warna Brand
COLOR_PRIMARY="#D4A017"       # Emas
COLOR_SECONDARY="#8B4513"     # Coklat
COLOR_WHITE="#FFFFFF"
COLOR_BLACK="#1A1A1A"

# File Musik Background (taruh file .mp3 di folder music/)
# Format: MUSIC_BG="nama_file.mp3"
# Biarkan kosong jika tidak pakai musik
MUSIC_BG=""

# Volume musik background (0.0 - 1.0), lebih rendah dari suara asli
MUSIC_VOLUME=0.15
