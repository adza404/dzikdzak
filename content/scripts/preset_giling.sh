#!/bin/bash
# ============================================
# PRESET: PROSES GILING PADI (ASMR INDUSTRIAL)
# ============================================
# Memproses video proses giling padi dengan:
# - Slow motion pada saat beras jatuh
# - Teks overlay "DARI GABAH JADI BERAS"
# - Logo DzikDzak
# - Background music
# ============================================

log "=== PRESET: GILING PADI ==="

# Validasi minimal 1 file
if [ ${#raw_files[@]} -eq 0 ]; then
    echo "ERROR: Preset giling butuh minimal 1 file video!"
    echo "Contoh: ./scripts/edit.sh giling raw/giling1.mp4 -o giling_1"
    exit 1
fi

# Step 1: Proses setiap clip — resize untuk TikTok
log "Step 1/4: Meresize clip ke format TikTok..."
processed=()
for i in "${!raw_files[@]}"; do
    input="${raw_files[$i]}"
    if [ ! -f "$input" ]; then
        input="$RAW_DIR/$(basename "${raw_files[$i]}")"
    fi
    
    # Clip 1: slowmo untuk efek satisfying
    if [ $i -eq 0 ]; then
        process_clip "$input" "$TEMP_DIR/clip_${i}.mp4" 0 10 2.0
    else
        process_clip "$input" "$TEMP_DIR/clip_${i}.mp4" 0 8 1.0
    fi
    processed+=("$TEMP_DIR/clip_${i}.mp4")
done

# Step 2: Gabung semua clip
log "Step 2/4: Menggabungkan clip..."
concat_file="$TEMP_DIR/concat_list.txt"
rm -f "$concat_file"
for clip in "${processed[@]}"; do
    echo "file '$clip'" >> "$concat_file"
done
concat_clips "$concat_file" "$TEMP_DIR/concatenated.mp4"

# Step 3: Tambah teks overlay
log "Step 3/4: Menambah teks overlay..."
add_text_overlay "$TEMP_DIR/concatenated.mp4" "$TEMP_DIR/with_text.mp4" \
    "DARI GABAH JADI BERAS" \
    "Fresh dari penggilingan, langsung ke dapurmu! 🍚" \
    "$WA_NUMBER"

# Step 4: Tambah background music
log "Step 4/4: Menambah background music..."
if [ -n "$music_file" ]; then
    add_music "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4" "$music_file" "$MUSIC_VOLUME"
else
    cp "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4"
fi

log "✓ PRESET GILING SELESAI"
