#!/bin/bash
# ============================================
# NEWS SCRAPER — Cari Berita Pangan Trending
# ============================================
# Mencari berita terbaru tentang pangan/beras
# dari sumber berita Indonesia terpercaya.
# Hasilnya bisa langsung dipakai sebagai hook video.
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo ""
echo "=========================================="
echo " 📰 BERITA PANGAN TRENDING"
echo "    $(date '+%d %B %Y %H:%M WIB')"
echo "=========================================="
echo ""

# Coba ambil berita dari beberapa sumber
sources=(
    "https://kemenkopangan.go.id/detail-berita/"
    "https://www.antaranews.com/tag/beras"
    "https://www.kompas.com/tag/beras"
)

for source in "${sources[@]}"; do
    echo "📍 Mengambil berita dari: $source"
    echo ""
    
    # Coba ambil dengan curl
    if curl -s --connect-timeout 5 --max-time 8 "$source" -o /tmp/berita_$$.html 2>/dev/null; then
        # Ambil judul-judul berita (grep untuk tag <h2>, <h3>, <title>)
        echo "  📌 Headlines:"
        grep -oP '<h[23][^>]*>.*?</h[23]>' /tmp/berita_$$.html 2>/dev/null | \
            sed 's/<[^>]*>//g' | \
            head -5 | \
            while read -r line; do
                echo "     • $line"
            done
        
        grep -oP '<a[^>]*class="[^"]*title[^"]*"[^>]*>.*?</a>' /tmp/berita_$$.html 2>/dev/null | \
            sed 's/<[^>]*>//g' | \
            head -3 | \
            while read -r line; do
                echo "     • $line"
            done
    else
        echo "  ⚠ Gagal mengakses $source"
    fi
    echo ""
done

# Bersihkan
rm -f /tmp/berita_$$.html

echo "=========================================="
echo ""
echo "💡 IDE KONTEN DARI BERITA INI:"
echo "  1. Bahas berita + kasih solusi (stok DzikDzak aman)"
echo "  2. Tanya followers: 'Harga beras di daerah kamu berapa?'"
echo "  3. Video respon: 'Viral soal [berita], ini faktanya...'"
echo ""
echo "📦 Untuk bikin video berita, jalankan:"
echo "  ./scripts/edit.sh berita raw/video_anda.mp4 -t \"Judul Berita\" -o berita_1"
echo ""
