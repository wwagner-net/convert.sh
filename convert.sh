#!/bin/bash
#
# MP4 zu WebM Konverter
#
# Autor: Wolfgang Wagner, wwagner@wwagner.net
# Version: 1.1.0
#
# Beschreibung: Konvertiert MP4-Videos in verschiedene WebM-Formate
# mit unterschiedlichen Auflösungen und Qualitätseinstellungen
#
# Parameter:
#   --square oder -s: Erstellt zusätzlich eine quadratische 1:1 Version der 500px Variante
#

# Parameter prüfen
CREATE_SQUARE=false
if [[ "$1" == "--square" || "$1" == "-s" ]]; then
    CREATE_SQUARE=true
    echo "Quadratische 1:1 Version wird erstellt..."
fi

for file in *.mp4; do
    name="${file%.*}"
    echo "Verarbeite: $file"

    # Original (CRF 32)
    echo "  → Erstelle Original-Version..."
    ffmpeg -i "$file" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_original.webm"

    # 1400px (CRF 32)
    echo "  → Erstelle 1400px-Version..."
    ffmpeg -i "$file" -vf "scale=1400:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_1400px.webm"

    # 1000px (CRF 32)
    echo "  → Erstelle 1000px-Version..."
    ffmpeg -i "$file" -vf "scale=1000:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_1000px.webm"

    # 500px (CRF 33 für bessere Qualität bei kleiner Größe)
    echo "  → Erstelle 500px-Version..."
    ffmpeg -i "$file" -vf "scale=500:-1" -c:v libvpx-vp9 -b:v 0 -crf 33 -c:a libopus "${name}_500px.webm"

    # Optionale quadratische 1:1 Version der 500px Variante
    if [[ "$CREATE_SQUARE" == true ]]; then
        echo "  → Erstelle 500px quadratische Version (1:1)..."
        ffmpeg -i "$file" -vf "scale=500:500:force_original_aspect_ratio=increase,crop=500:500" -c:v libvpx-vp9 -b:v 0 -crf 33 -c:a libopus "${name}_500px_square.webm"
    fi

    echo "  ✓ $file abgeschlossen"
done

echo "Alle Konvertierungen abgeschlossen!"
