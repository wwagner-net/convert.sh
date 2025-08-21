#!/bin/bash
#
# MP4 zu WebM Konverter
#
# Autor: Wolfgang Wagner, wwagner@wwagner.net
# Version: 1.3.0
#
# Beschreibung: Konvertiert MP4-Videos aus dem input/ Ordner in verschiedene WebM-Formate
# mit unterschiedlichen Auflösungen und Qualitätseinstellungen.
# Konvertierte Videos werden im output/ Ordner gespeichert.
#
# Parameter:
#   --square oder -s: Erstellt zusätzlich eine quadratische 1:1 Version der 500px Variante
#

# Verzeichnisse definieren
INPUT_DIR="input"
OUTPUT_DIR="output"

# Verzeichnisse erstellen falls sie nicht existieren
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# Parameter prüfen
CREATE_SQUARE=false
if [[ "$1" == "--square" || "$1" == "-s" ]]; then
    CREATE_SQUARE=true
    echo "Quadratische 1:1 Version wird erstellt..."
fi

# Prüfen ob MP4-Dateien im input-Ordner vorhanden sind
if ! ls "$INPUT_DIR"/*.mp4 1> /dev/null 2>&1; then
    echo "Keine MP4-Dateien im $INPUT_DIR Ordner gefunden!"
    exit 1
fi

# Funktion für optimierte VP9-Kodierung mit Dateigröße-Kontrolle
convert_with_size_check() {
    local input_file="$1"
    local output_file="$2"
    local scale_filter="$3"
    local target_crf="$4"
    local variant_name="$5"
    
    # Erste Kodierung mit Standard-CRF
    local temp_output="${output_file}.tmp"
    local ffmpeg_success=false
    
    if [[ -n "$scale_filter" ]]; then
        ffmpeg -y -i "$input_file" -vf "$scale_filter" \
            -c:v libvpx-vp9 -b:v 0 -crf "$target_crf" \
            -threads 8 -speed 2 -tile-columns 1 -row-mt 1 \
            -c:a libopus -b:a 128k \
            -f webm "$temp_output" > /dev/null 2>&1
        if [[ $? -eq 0 && -f "$temp_output" ]]; then
            ffmpeg_success=true
        fi
    else
        ffmpeg -y -i "$input_file" \
            -c:v libvpx-vp9 -b:v 0 -crf "$target_crf" \
            -threads 8 -speed 2 -tile-columns 1 -row-mt 1 \
            -c:a libopus -b:a 128k \
            -f webm "$temp_output" > /dev/null 2>&1
        if [[ $? -eq 0 && -f "$temp_output" ]]; then
            ffmpeg_success=true
        fi
    fi
    
    # Prüfen ob FFmpeg erfolgreich war
    if [[ "$ffmpeg_success" == false || ! -f "$temp_output" ]]; then
        echo "    ✗ Fehler bei der Kodierung!"
        [[ -f "$temp_output" ]] && rm "$temp_output"
        return 1
    fi
    
    # Dateigröße vergleichen
    local input_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    local output_size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
    
    # Iterativ CRF erhöhen bis WebM kleiner als MP4 ist
    local current_crf=$target_crf
    local max_crf=50
    local attempt=1
    
    while [[ $output_size -gt $input_size && $current_crf -le $max_crf ]]; do
        if [[ $attempt -gt 1 ]]; then
            rm "$temp_output"
        fi
        
        current_crf=$((current_crf + 3))
        echo "    ⚠ WebM größer als Original ($output_size > $input_size Bytes), Versuch $attempt mit CRF $current_crf"
        
        local ffmpeg_retry_success=false
        if [[ -n "$scale_filter" ]]; then
            ffmpeg -y -i "$input_file" -vf "$scale_filter" \
                -c:v libvpx-vp9 -b:v 0 -crf $current_crf \
                -threads 8 -speed 2 -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a 128k \
                -f webm "$temp_output" > /dev/null 2>&1
            if [[ $? -eq 0 && -f "$temp_output" ]]; then
                ffmpeg_retry_success=true
            fi
        else
            ffmpeg -y -i "$input_file" \
                -c:v libvpx-vp9 -b:v 0 -crf $current_crf \
                -threads 8 -speed 2 -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a 128k \
                -f webm "$temp_output" > /dev/null 2>&1
            if [[ $? -eq 0 && -f "$temp_output" ]]; then
                ffmpeg_retry_success=true
            fi
        fi
        
        if [[ "$ffmpeg_retry_success" == false || ! -f "$temp_output" ]]; then
            echo "    ✗ Fehler bei der Kodierung mit CRF $current_crf!"
            return 1
        fi
        
        output_size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
        attempt=$((attempt + 1))
    done
    
    # Prüfen ob WebM jetzt kleiner ist
    if [[ $output_size -le $input_size ]]; then
        if ! mv "$temp_output" "$output_file"; then
            echo "    ✗ Fehler beim Verschieben der Datei!"
            rm -f "$temp_output"
            return 1
        fi
        echo "    ✓ Optimale Größe erreicht: $output_size Bytes ($(( (output_size * 100) / input_size ))% des Originals, CRF $current_crf)"
    else
        # WebM konnte nicht kleiner gemacht werden
        rm "$temp_output"
        echo "    ⚠ WebM-Konvertierung übersprungen (auch mit CRF $current_crf noch $output_size > $input_size Bytes)"
        echo "    → Original MP4 bleibt die beste Option für diese Datei"
        return 1
    fi
}

for file in "$INPUT_DIR"/*.mp4; do
    # Dateiname ohne Pfad und Erweiterung extrahieren
    basename_file=$(basename "$file")
    name="${basename_file%.*}"
    echo "Verarbeite: $basename_file"
    
    # Video-Breite ermitteln
    video_width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$file")
    echo "  → Original-Breite: ${video_width}px"

    # Original (CRF 30, optimiert für Hochformat)
    echo "  → Erstelle Original-Version..."
    convert_with_size_check "$file" "$OUTPUT_DIR/${name}_original.webm" "" "30" "original"

    # 1400px nur wenn Original breiter als 1400px ist
    if [[ $video_width -gt 1400 ]]; then
        echo "  → Erstelle 1400px-Version..."
        convert_with_size_check "$file" "$OUTPUT_DIR/${name}_1400px.webm" "scale=1400:-1" "32" "1400px"
    else
        echo "  → Überspringe 1400px-Version (Original ist nur ${video_width}px breit)"
    fi

    # 1000px nur wenn Original breiter als 1000px ist
    if [[ $video_width -gt 1000 ]]; then
        echo "  → Erstelle 1000px-Version..."
        convert_with_size_check "$file" "$OUTPUT_DIR/${name}_1000px.webm" "scale=1000:-1" "33" "1000px"
    else
        echo "  → Überspringe 1000px-Version (Original ist nur ${video_width}px breit)"
    fi

    # 500px nur wenn Original breiter als 500px ist
    if [[ $video_width -gt 500 ]]; then
        echo "  → Erstelle 500px-Version..."
        convert_with_size_check "$file" "$OUTPUT_DIR/${name}_500px.webm" "scale=500:-1" "35" "500px"
    else
        echo "  → Überspringe 500px-Version (Original ist nur ${video_width}px breit)"
    fi

    # Optionale quadratische 1:1 Version der 500px Variante
    if [[ "$CREATE_SQUARE" == true ]]; then
        echo "  → Erstelle 500px quadratische Version (1:1)..."
        convert_with_size_check "$file" "$OUTPUT_DIR/${name}_500px_square.webm" "scale=500:500:force_original_aspect_ratio=increase,crop=500:500" "35" "500px_square"
    fi

    echo "  ✓ $basename_file abgeschlossen"
done

echo "Alle Konvertierungen abgeschlossen!"
