# WebM Converter

Ein Bash-Skript zur automatischen Konvertierung von MP4-Videos in WebM-Format mit verschiedenen Auflösungen.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)  
Version: 1.0.0

## Beschreibung

Das Skript konvertiert alle MP4-Dateien im aktuellen Verzeichnis in WebM-Format mit vier verschiedenen Auflösungen:
- **Original**: Behält die ursprüngliche Auflösung bei
- **1400px**: Skaliert auf 1400px Breite
- **1000px**: Skaliert auf 1000px Breite  
- **500px**: Skaliert auf 500px Breite

Alle Versionen verwenden den VP9-Codec für Video und Opus für Audio.

## Voraussetzungen

- **FFmpeg** muss installiert sein
- **Bash** (Linux/macOS/WSL)

## Verwendung

1. Lege alle MP4-Dateien, die konvertiert werden sollen, in ein Verzeichnis
2. Kopiere das `convert.sh` Skript in dasselbe Verzeichnis
3. Führe das Skript aus:


## Ausgabe

Für jede `input.mp4` Datei werden folgende WebM-Dateien erstellt:
- `input_original.webm` - Originalauflösung
- `input_1400px.webm` - 1400px Breite
- `input_1000px.webm` - 1000px Breite
- `input_500px.webm` - 500px Breite

## Qualitätseinstellungen

- **CRF 32**: Für Original, 1400px und 1000px Versionen
- **CRF 33**: Für 500px Version (etwas höhere Kompression)
- **VP9-Codec**: Für optimale Kompression
- **Opus-Audio**: Für beste Audioqualität bei geringer Dateigröße

## Hinweise

- Die Konvertierung kann je nach Dateigröße und Systemleistung einige Zeit dauern
- WebM-Dateien sind in der Regel deutlich kleiner als MP4-Dateien
- Das Seitenverhältnis wird automatisch beibehalten
