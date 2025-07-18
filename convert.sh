#!/bin/bash
#
# MP4 zu WebM Konverter
#
# Autor: Wolfgang Wagner, wwagner@wwagner.net
# Version: 1.0.0
#
# Beschreibung: Konvertiert MP4-Videos in verschiedene WebM-Formate
# mit unterschiedlichen Auflösungen und Qualitätseinstellungen
#

for file in *.mp4; do
    name="${file%.*}"

    # Original (CRF 30)
    ffmpeg -i "$file" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_original.webm"

    # 1400px (CRF 30)
    ffmpeg -i "$file" -vf "scale=1400:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_1400px.webm"

    # 1000px (CRF 30)
    ffmpeg -i "$file" -vf "scale=1000:-1" -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus "${name}_1000px.webm"

    # 500px (CRF 28 für bessere Qualität bei kleiner Größe)
    ffmpeg -i "$file" -vf "scale=500:-1" -c:v libvpx-vp9 -b:v 0 -crf 33 -c:a libopus "${name}_500px.webm"
done

