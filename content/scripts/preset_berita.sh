#!/bin/bash
# ============================================
# PRESET: BERITA PANGAN TRENDING
# ============================================
# Membuat video respon terhadap berita pangan
# yang sedang viral. Butuh teks judul berita.
# ============================================

log "=== PRESET: BERITA TRENDING ==="

# Validasi butuh judul berita
if [ -z "$title_text" ]; then
    echo "ERROR: Preset berita butuh judul! Gunakan -t \"Judul Berita\""
    echo "Contoh: ./scripts/edit.sh berita raw/berita1.mp4 -t \"Stok beras 5 juta ton\" -o berita_1"
    exit 1
fi

if [ ${#raw_files[@]} -eq 0 ]; then
    echo "ERROR: Preset berita butuh minimal 1 file video!"
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
    process_clip "$input" "$TEMP_DIR/clip_${i}.mp4" 0 15 1.0
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

# Step 3: Tambah teks dengan judul berita
log "Step 3/4: Menambah teks overlay..."
add_text_overlay "$TEMP_DIR/concatenated.mp4" "$TEMP_DIR/with_text.mp4" \
    "🔥 TRENDING: $title_text" \
    "Tenang, stok beras DzikDzak aman! Order sekarang." \
    "$WA_NUMBER"

# Step 4: Musik
log "Step 4/4: Menambah background music..."
if [ -n "$music_file" ]; then
    add_music "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4" "$music_file" "$MUSIC_VOLUME"
else
    cp "$TEMP_DIR/with_text.mp4" "$TEMP_DIR/final.mp4"
fi

log "✓ PRESET BERITA SELESAI"
