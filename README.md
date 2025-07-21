# WebM Converter

Ein Bash-Skript zur automatischen Konvertierung von MP4-Videos in WebM-Format mit verschiedenen Auflösungen.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)  
Version: 1.1.0

## Beschreibung

Das Skript konvertiert alle MP4-Dateien im aktuellen Verzeichnis in WebM-Format mit vier verschiedenen Auflösungen:
- **Original**: Behält die ursprüngliche Auflösung bei
- **1400px**: Skaliert auf 1400px Breite
- **1000px**: Skaliert auf 1000px Breite  
- **500px**: Skaliert auf 500px Breite  
- **500px Square** (optional): Skaliert auf 500x500 Pixel im 1:1-Format


Alle Versionen verwenden den VP9-Codec für Video und Opus für Audio.

## Voraussetzungen

- **FFmpeg** muss installiert sein
- **Bash** (Linux/macOS/WSL)

## Verwendung

1. Lege alle MP4-Dateien, die konvertiert werden sollen, in ein Verzeichnis
2. Kopiere das `convert.sh` Skript in dasselbe Verzeichnis
3. Führe das Skript aus:

### Standard-Modus:

`bash ./convert.sh`

### Mit quadratischer 500px-Version:

`bash ./convert.sh --square`

oder 

`bash ./convert.sh -s`

## Parameter

- `--square` oder `-s`: Erstellt zusätzlich eine quadratische 1:1 Version der 500px Variante

## Ausgabe

### Standard-Ausgabe
Für jede `input.mp4` Datei werden folgende WebM-Dateien erstellt:
- `input_original.webm` - Originalauflösung
- `input_1400px.webm` - 1400px Breite
- `input_1000px.webm` - 1000px Breite
- `input_500px.webm` - 500px Breite

### Mit --square Parameter zusätzlich:
- `input_500px_square.webm` - 500x500 Pixel im 1:1-Format (zentriert zugeschnitten)

## Qualitätseinstellungen

- **CRF 32**: Für Original, 1400px und 1000px Versionen
- **CRF 33**: Für 500px Version (etwas höhere Kompression)
- **VP9-Codec**: Für optimale Kompression
- **Opus-Audio**: Für beste Audioqualität bei geringer Dateigröße

## Quadratische Version Details

Die quadratische 500px-Version verwendet intelligentes Zuschneiden:
- Das Video wird zunächst so skaliert, dass es mindestens 500px in beide Richtungen hat
- Anschließend wird es zentriert auf exakt 500x500 Pixel zugeschnitten
- Das Ergebnis ist ein perfektes 1:1-Quadrat, ideal für Social Media Plattformen

## Hinweise

- Die Konvertierung kann je nach Dateigröße und Systemleistung einige Zeit dauern
- WebM-Dateien sind in der Regel deutlich kleiner als MP4-Dateien
- Das Seitenverhältnis wird automatisch beibehalten
