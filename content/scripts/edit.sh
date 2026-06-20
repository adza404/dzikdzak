#!/bin/bash
# ============================================
# AUTO-EDIT VIDEO TOKO BERAS DZIKDZAK
# ============================================
# Cara pakai:
#   ./scripts/edit.sh <preset> <raw_file1> [raw_file2 ...] -o <output_name>
#
# Contoh:
#   ./scripts/edit.sh giling video1.mp4 video2.mp4 -o giling_padi_1
#   ./scripts/edit.sh kualitas video1.mp4 -o premium_vs_biasa_1
#   ./scripts/edit.sh berita -t "Harga beras turun" -o berita_trending_1
#
# Preset: giling | kualitas | restock | berita | review
# ============================================

set -e

# Load config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ============================================
# FUNGSI UTILITY
# ============================================

usage() {
    echo "=========================================="
    echo " AUTO-EDIT VIDEO DZIKDZAK"
    echo "=========================================="
    echo "Cara pakai:"
    echo "  ./scripts/edit.sh <preset> <file>... -o <nama> [options]"
    echo ""
    echo "Preset:"
    echo "  giling   - Video proses giling padi (ASMR)"
    echo "  kualitas - Edukasi kualitas beras"
    echo "  restock  - Restocking gudang (timelapse)"
    echo "  berita   - Berita pangan trending"
    echo "  review   - Testimoni pelanggan"
    echo ""
    echo "Options:"
    echo "  -o NAMA   Nama file output (tanpa ekstensi)"
    echo "  -t TEXT   Teks judul/topik (khusus preset berita)"
    echo "  -m FILE   Background music (override config)"
    echo "  -s ANGKA  Slow motion factor (2.0 = 2x lebih lambat)"
    echo "  --no-music  Tanpa background music"
    echo ""
    echo "Contoh:"
    echo "  ./scripts/edit.sh giling raw/giling1.mp4 -o video_giling_1"
    echo "  ./scripts/edit.sh berita -t \"Stok beras 5 juta ton\" -o berita_1"
    echo "=========================================="
    exit 1
}

# Log dengan timestamp
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Generate thumbnail dari video
gen_thumbnail() {
    local video="$1"
    local output="$2"
    ffmpeg -i "$video" -ss 00:00:02 -vframes 1 -q:v 2 "$output" -y -loglevel error
    log "  ✓ Thumbnail: $output"
}

# Cek apakah file ada
check_files() {
    for f in "$@"; do
        if [ ! -f "$f" ]; then
            echo "ERROR: File tidak ditemukan: $f"
            exit 1
        fi
    done
}

# Dapatkan durasi video dalam detik
get_duration() {
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1"
}

# ============================================
# FUNGSI BUILD FFMPEG FILTER
# ============================================

# Build filter untuk teks overlay
build_text_filter() {
    local text="$1"
    local font_size="$2"
    local y_pos="$3"
    local color="${4:-$COLOR_WHITE}"
    local box="${5:-1}"
    
    local box_arg=""
    if [ "$box" = "1" ]; then
        box_arg=":box=1:boxcolor=black@0.5:boxborderw=10"
    fi
    
    echo "drawtext=text='$text':fontfile=$FONT_FILE:fontsize=$font_size:fontcolor=$color:x=(w-text_w)/2:y=$y_pos$box_arg"
}

# Build filter untuk logo overlay
build_logo_filter() {
    local logo="$1"
    local pos="${2:-bottom-right}"
    
    case "$pos" in
        bottom-right) echo "overlay=main_w-overlay_w-20:main_h-overlay_h-20" ;;
        top-left)     echo "overlay=20:20" ;;
        top-right)    echo "overlay=main_w-overlay_w-20:20" ;;
        bottom-left)  echo "overlay=20:main_h-overlay_h-20" ;;
        center)       echo "overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" ;;
    esac
}

# ============================================
# FUNGSI EDIT UTAMA
# ============================================

# Trim & resize single clip untuk TikTok (9:16)
process_clip() {
    local input="$1"
    local output="$2"
    local start="${3:-0}"
    local duration="${4:-}"  # kosong = sampai habis
    local slowmo="${5:-1}"
    
    local filter="crop=ih*9/16:ih,scale=$VIDEO_WIDTH:$VIDEO_HEIGHT"
    local speed_filter=""
    
    # Slow motion
    if [ "$slowmo" != "1" ]; then
        speed_filter=",setpts=${slowmo}*PTS"
    fi
    
    local trim_args=""
    [ -n "$start" ] && [ "$start" != "0" ] && trim_args="$trim_args -ss $start"
    [ -n "$duration" ] && trim_args="$trim_args -t $duration"
    
    log "  Memproses: $input -> $output"
    ffmpeg -i "$input" $trim_args \
        -vf "$filter$speed_filter" \
        -c:a aac -ar 44100 -ac 2 \
        -preset fast -crf 23 \
        "$output" -y -loglevel error
    
    log "  ✓ Selesai: $output ($(get_duration "$output") detik)"
}

# Gabung multiple video clips
concat_clips() {
    local filelist="$1"
    local output="$2"
    
    log "  Menggabungkan $(wc -l < "$filelist") clip..."
    ffmpeg -f concat -safe 0 -i "$filelist" \
        -c copy \
        "$output" -y -loglevel error
    
    log "  ✓ Gabungan: $output"
}

# Tambah teks overlay ke video yang sudah jadi
add_text_overlay() {
    local input="$1"
    local output="$2"
    local title="$3"
    local subtitle="$4"
    local whatsapp="$5"
    
    local filters=""
    local sep=""
    
    # Title (atas)
    if [ -n "$title" ]; then
        local tf=$(build_text_filter "$title" 42 "h-text_h-120" "$COLOR_PRIMARY" 1)
        filters="${filters}${sep}${tf}"
        sep=","
    fi
    
    # Subtitle (bawah, di atas WA)
    if [ -n "$subtitle" ]; then
        local sf=$(build_text_filter "$subtitle" 30 "h-text_h-200" "$COLOR_WHITE" 1)
        filters="${filters}${sep}${sf}"
        sep=","
    fi
    
    # WhatsApp number (paling bawah)
    if [ -n "$whatsapp" ]; then
        local wf=$(build_text_filter "📲 WA: $whatsapp" 28 "h-text_h-70" "#25D366" 1)
        filters="${filters}${sep}${wf}"
        sep=","
    fi
    
    # Brand name (atas kiri)
    local bf=$(build_text_filter "$BRAND_NAME" 24 "20" "$COLOR_PRIMARY" 0)
    filters="${filters}${sep}${bf}"
    
    if [ -n "$filters" ]; then
        ffmpeg -i "$input" -vf "$filters" \
            -c:a aac -ar 44100 -ac 2 \
            -preset fast -crf 23 \
            "$output" -y -loglevel error
    else
        cp "$input" "$output"
    fi
    log "  ✓ Teks overlay selesai"
}

# Tambah background music
add_music() {
    local input="$1"
    local output="$2"
    local music_file="$3"
    local music_vol="${4:-$MUSIC_VOLUME}"
    
    if [ -z "$music_file" ] || [ ! -f "$music_file" ]; then
        log "  - Tidak ada musik, copy langsung"
        cp "$input" "$output"
        return
    fi
    
    log "  Menambahkan musik: $music_file (vol: $music_vol)"
    
    # Durasi video
    local dur=$(get_duration "$input")
    
    ffmpeg -i "$input" -i "$music_file" \
        -filter_complex "[1:a]volume=${music_vol}[bg];[0:a][bg]amix=inputs=2:duration=first[audio]" \
        -map 0:v -map "[audio]" \
        -c:v copy \
        -shortest \
        "$output" -y -loglevel error
    
    log "  ✓ Musik ditambahkan"
}

# ============================================
# MAIN PIPELINE
# ============================================

main() {
    local preset=""
    local raw_files=()
    local output_name=""
    local title_text=""
    local music_file="$MUSIC_BG"
    local slowmo_factor="1"
    local no_music=false
    
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            giling|kualitas|restock|berita|review)
                preset="$1"
                shift
                ;;
            -o)
                output_name="$2"
                shift 2
                ;;
            -t)
                title_text="$2"
                shift 2
                ;;
            -m)
                music_file="$2"
                shift 2
                ;;
            -s)
                slowmo_factor="$2"
                shift 2
                ;;
            --no-music)
                no_music=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                raw_files+=("$1")
                shift
                ;;
        esac
    done
    
    # Validasi
    if [ -z "$preset" ]; then
        echo "ERROR: Harus pilih preset! (giling/kualitas/restock/berita/review)"
        usage
    fi
    
    if [ -z "$output_name" ]; then
        echo "ERROR: Harus pakai -o untuk nama output!"
        usage
    fi
    
    if [ "$no_music" = true ]; then
        music_file=""
    elif [ -n "$music_file" ] && [ ! -f "$music_file" ]; then
        # Coba cari di folder music
        if [ -f "$MUSIC_DIR/$music_file" ]; then
            music_file="$MUSIC_DIR/$music_file"
        else
            log "WARNING: File musik '$music_file' tidak ditemukan. Lanjut tanpa musik."
            music_file=""
        fi
    fi
    
    # Buat folder temp
    local TEMP_DIR="$BASE_DIR/tmp_$$"
    mkdir -p "$TEMP_DIR"
    
    echo ""
    echo "=========================================="
    echo " 🎬 AUTO-EDIT: $preset"
    echo " Output: $output_name"
    echo "=========================================="
    
    # Panggil preset
    case "$preset" in
        giling)     source "$SCRIPT_DIR/preset_giling.sh" ;;
        kualitas)   source "$SCRIPT_DIR/preset_kualitas.sh" ;;
        restock)    source "$SCRIPT_DIR/preset_restock.sh" ;;
        berita)     source "$SCRIPT_DIR/preset_berita.sh" ;;
        review)     source "$SCRIPT_DIR/preset_review.sh" ;;
    esac
    
    # Output akhir
    local final_output="$READY_DIR/${output_name}.mp4"
    
    # Jika hasil edit ada di TEMP_DIR/final.mp4, pindahkan
    if [ -f "$TEMP_DIR/final.mp4" ]; then
        cp "$TEMP_DIR/final.mp4" "$final_output"
    elif [ -f "$TEMP_DIR/with_text.mp4" ]; then
        cp "$TEMP_DIR/with_text.mp4" "$final_output"
    fi
    
    # Generate thumbnail
    if [ -f "$final_output" ]; then
        gen_thumbnail "$final_output" "$THUMB_DIR/${output_name}.jpg"
        
        local dur=$(get_duration "$final_output")
        local size=$(du -h "$final_output" | cut -f1)
        
        echo ""
        echo "=========================================="
        echo " ✅ SELESAI!"
        echo "    Video:   $final_output"
        echo "    Durasi:  ${dur} detik"
        echo "    Size:    $size"
        echo "    Thumb:   $THUMB_DIR/${output_name}.jpg"
        echo "=========================================="
        echo ""
        echo " 📱 Upload ke TikTok/IG sekarang!"
        echo "=========================================="
    else
        echo "ERROR: Gagal memproses video!"
        exit 1
    fi
    
    # Bersihkan temp
    rm -rf "$TEMP_DIR"
}

# Run
main "$@"
