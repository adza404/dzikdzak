#!/bin/bash
# ============================================
# PRESET: KUALITAS BERAS (PREMIUM VS BIASA)
# ============================================
# Membandingkan beras premium dan biasa
# dengan side-by-side atau bergantian
# ============================================

log "=== PRESET: KUALITAS BERAS ==="

# Validasi
if [ ${#raw_files[@]} -lt 1 ]; then
    echo "ERROR: Preset kualitas butuh minimal 1 file video!"
    echo "Contoh: ./scripts/edit.sh kualitas raw/premium1.mp4 raw/biasa1.mp4 -o kualitas_1"
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
    process_clip "$input" "$TEMP_DIR/clip_${i}.mp4" 0 10 1.0
    processed+=("$TEMP_DIR/clip_${i}.mp4")
done

# Step 2: Gabung clip
log "Step 2/4: Menggabungkan clip..."
concat_file="$TEMP_DIR/concat_list.txt"
rm -f "$concat_file"
for clip in "${processed[@]}"; do
    echo "file '$clip'" >> "$concat_file"
done
concat_clips "$concat_file" "$TEMP_DIR/concatenated.mp4"

# Step 3: Tambah teks
log "Step 3/4: Menambah teks overlay..."
add_text_overlay "$TEMP_DIR/concatenated.mp4" "$TEMP_DIR/with_text.mp4" \
    "PREMIUM VS BIASA? 🤔" \
    "Kualitas beras itu penting! Yuk kenali bedanya." \
    "$WA_NUMBER"

# Step 4: Musik
log "Step 4/4: Menambah background music..."
if [ -n "$music_file" ]; then
    add_music "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4" "$music_file" "$MUSIC_VOLUME"
else
    cp "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4"
fi

log "✓ PRESET KUALITAS SELESAI"
