#!/bin/bash
# ============================================
# DOWNLOAD MUSIC — Background Music Gratis
# ============================================
# Download musik bebas royalti dari Pixabay
# Cocok untuk background video TikTok/IG
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=========================================="
echo " 🎵 DOWNLOAD BACKGROUND MUSIC"
echo "=========================================="
echo ""
echo "Beberapa sumber musik bebas royalti:"
echo ""
echo "1. Pixabay Music (gratis, no attribution)"
echo "   https://pixabay.com/music/search/mood/relaxing/"
echo ""
echo "2. Uppbeat (gratis untuk social media)"
echo "   https://uppbeat.io/"
echo ""
echo "3. YouTube Audio Library"
echo "   https://www.youtube.com/audiolibrary"
echo ""

# Cek apakah sudah ada musik
if [ -f "$MUSIC_DIR/background.mp3" ]; then
    echo "✅ Musik sudah ada di folder music/"
    ls -lh "$MUSIC_DIR/"
else
    echo "⚠ Belum ada file musik di folder music/"
    echo ""
    echo "📌 CARA DOWNLOAD:"
    echo "  1. Buka https://pixabay.com/music/"
    echo "  2. Cari 'relaxing', 'upbeat', atau 'traditional'"
    echo "  3. Download MP3, simpan ke folder:"
    echo "     $MUSIC_DIR/"
    echo "  4. Setelah itu, edit file config.sh"
    echo "     ganti MUSIC_BG=\"nama_file.mp3\""
    echo ""
    echo "📌 Atau download otomatis (via curl):"
    echo "   (coming soon)"
fi

echo "=========================================="
