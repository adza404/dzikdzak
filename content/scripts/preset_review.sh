#!/bin/bash
# ============================================
# PRESET: REVIEW PELANGGAN
# ============================================
# Membuat video testimoni pelanggan dengan
# overlay teks review + link WA
# ============================================

log "=== PRESET: REVIEW PELANGGAN ==="

# Validasi
if [ ${#raw_files[@]} -eq 0 ]; then
    echo "ERROR: Preset review butuh minimal 1 file video/foto!"
    echo "Contoh: ./scripts/edit.sh review raw/testimoni1.mp4 -o review_1"
    exit 1
fi

# Step 1: Proses clip
log "Step 1/4: Meresize clip..."
processed=()
for i in "${!raw_files[@]}"; do
    input="${raw_files[$i]}"
    if [ ! -f "$input" ]; then
        input="$RAW_DIR/$(basename "${raw_files[$i]}")"
    fi
    
    # Cek apakah file gambar (jpg/png) atau video
    ext="${input##*.}"
    if [[ "$ext" =~ ^(jpg|jpeg|png|webp)$ ]]; then
        # Foto: buat slideshow 5 detik
        log "  Foto: $input -> slideshow 5 detik"
        ffmpeg -loop 1 -i "$input" -t 5 \
            -vf "scale=$VIDEO_WIDTH:$VIDEO_HEIGHT:force_original_aspect_ratio=decrease,pad=$VIDEO_WIDTH:$VIDEO_HEIGHT:(ow-iw)/2:(oh-ih)/2" \
            -c:a aac -ar 44100 -ac 2 \
            -preset fast -crf 23 \
            "$TEMP_DIR/clip_${i}.mp4" -y -loglevel error
    else
        process_clip "$input" "$TEMP_DIR/clip_${i}.mp4" 0 8 1.0
    fi
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

# Step 3: Teks testimoni
log "Step 3/4: Menambah teks overlay..."
add_text_overlay "$TEMP_DIR/concatenated.mp4" "$TEMP_DIR/with_text.mp4" \
    "⭐ PELANGGAN PUAS!" \
    "\"Berasnya pulen, wangi, gak pernah kecewa!\" 😍" \
    "$WA_NUMBER"

# Step 4: Musik
log "Step 4/4: Menambah background music..."
if [ -n "$music_file" ]; then
    add_music "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4" "$music_file" "$MUSIC_VOLUME"
else
    cp "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4"
fi

log "✓ PRESET REVIEW SELESAI"
