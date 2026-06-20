#!/bin/bash
# ============================================
# PRESET: RESTOCKING GUDANG (TIMELAPSE)
# ============================================
# Mempercepat video bongkar muat/stok beras
# dengan timelapse effect + teks stok
# ============================================

log "=== PRESET: RESTOCK GUDANG ==="

# Validasi
if [ ${#raw_files[@]} -eq 0 ]; then
    echo "ERROR: Preset restock butuh minimal 1 file video!"
    echo "Contoh: ./scripts/edit.sh restock raw/restock1.mp4 -o restock_1"
    exit 1
fi

# Step 1: Proses clip dengan timelapse (setpts=0.3 = 3x lebih cepat)
log "Step 1/4: Membuat timelapse..."
processed=()
for i in "${!raw_files[@]}"; do
    input="${raw_files[$i]}"
    if [ ! -f "$input" ]; then
        input="$RAW_DIR/$(basename "${raw_files[$i]}")"
    fi
    
    # Timelapse: percepat 5x
    local tl_filter="crop=ih*9/16:ih,scale=$VIDEO_WIDTH:$VIDEO_HEIGHT,setpts=0.2*PTS"
    
    log "  Timelapse: $input"
    ffmpeg -i "$input" -vf "$tl_filter" \
        -c:a aac -ar 44100 -ac 2 \
        -preset fast -crf 23 \
        "$TEMP_DIR/clip_${i}.mp4" -y -loglevel error
    
    processed+=("$TEMP_DIR/clip_${i}.mp4")
done

# Step 2: Gabung
log "Step 2/4: Menggabungkan clip..."
concat_file="$TEMP_DIR/concat_list.txt"
rm -f "$concat_file"
for clip in "${processed[@]}"; do
    echo "file '$clip'" >> "$concat_file"
done
concat_clips "$concat_file" "$TEMP_DIR/concatenated.mp4"

# Step 3: Teks
log "Step 3/4: Menambah teks overlay..."
add_text_overlay "$TEMP_DIR/concatenated.mp4" "$TEMP_DIR/with_text.mp4" \
    "🔄 STOK DATANG!" \
    "5 ton beras premium siap dikirim! Stok aman." \
    "$WA_NUMBER"

# Step 4: Musik
log "Step 4/4: Menambah background music..."
if [ -n "$music_file" ]; then
    add_music "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4" "$music_file" "$MUSIC_VOLUME"
else
    cp "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4"
fi

log "✓ PRESET RESTOCK SELESAI"
