#!/bin/bash
#
# MP4 zu WebM Konverter
#
# Autor: Wolfgang Wagner, wwagner@wwagner.net
# Version: 1.2.0
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

for file in "$INPUT_DIR"/*.mp4; do
    # Dateiname ohne Pfad und Erweiterung extrahieren
    basename_file=$(basename "$file")
    name="${basename_file%.*}"
    echo "Verarbeite: $basename_file"

    # Original (CRF 32)
    echo "  → Erstelle Original-Version..."
    ffmpeg -i "$file" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "$OUTPUT_DIR/${name}_original.webm"

    # 1400px (CRF 32)
    echo "  → Erstelle 1400px-Version..."
    ffmpeg -i "$file" -vf "scale=1400:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "$OUTPUT_DIR/${name}_1400px.webm"

    # 1000px (CRF 32)
    echo "  → Erstelle 1000px-Version..."
    ffmpeg -i "$file" -vf "scale=1000:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "$OUTPUT_DIR/${name}_1000px.webm"

    # 500px (CRF 33 für bessere Qualität bei kleiner Größe)
    echo "  → Erstelle 500px-Version..."
    ffmpeg -i "$file" -vf "scale=500:-1" -c:v libvpx-vp9 -b:v 0 -crf 33 -c:a libopus "$OUTPUT_DIR/${name}_500px.webm"

    # Optionale quadratische 1:1 Version der 500px Variante
    if [[ "$CREATE_SQUARE" == true ]]; then
        echo "  → Erstelle 500px quadratische Version (1:1)..."
        ffmpeg -i "$file" -vf "scale=500:500:force_original_aspect_ratio=increase,crop=500:500" -c:v libvpx-vp9 -b:v 0 -crf 33 -c:a libopus "$OUTPUT_DIR/${name}_500px_square.webm"
    fi

    echo "  ✓ $basename_file abgeschlossen"
done

echo "Alle Konvertierungen abgeschlossen!"
