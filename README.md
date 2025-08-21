# WebM Converter

Ein Bash-Skript zur automatischen Konvertierung von MP4-Videos in WebM-Format mit verschiedenen Auflösungen.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)  
Version: 1.2.0

## Was ist WebM?

WebM ist ein offenes, lizenzfreies Videoformat, das von Google entwickelt wurde und speziell für das Web optimiert ist. Es basiert auf dem VP8/VP9-Videocodec und dem Opus-Audiocodec, was zu einer ausgezeichneten Komprimierung bei hoher Qualität führt.

### Vorteile von WebM

- **Bessere Komprimierung**: Bis zu 30-50% kleinere Dateigrößen als MP4 bei vergleichbarer Qualität
- **Lizenzfrei**: Keine Lizenzgebühren oder Patentbeschränkungen
- **Web-optimiert**: Entwickelt speziell für Streaming und schnelles Laden im Browser
- **Hohe Qualität**: VP9-Codec bietet bessere Qualität bei geringerer Bandbreite
- **Progressive Downloads**: Ermöglicht sofortiges Abspielen während des Ladens

### Browser-Unterstützung (Stand 2025)

WebM wird von nahezu allen modernen Browsern unterstützt mit einer Browser-Kompatibilitätsbewertung von 92/100:

- **Chrome**: Vollständige Unterstützung (alle Versionen seit 25)
- **Firefox**: Vollständige Unterstützung (alle Versionen seit 28)  
- **Edge**: Vollständige Unterstützung (alle Versionen seit 79)
- **Safari**: Vollständige Unterstützung seit Version 16.5, teilweise seit 12.1
- **Opera**: Vollständige Unterstützung (alle Versionen seit 16)
- **Mobile Browser**: Vollständige Unterstützung auf Android Chrome/Firefox und Safari iOS 17.5+

**Marktabdeckung**: Etwa 92-95% aller Webnutzer können WebM abspielen (Stand 2025)

## Beschreibung

Das Skript konvertiert alle MP4-Dateien aus dem `input/` Ordner in WebM-Format mit vier verschiedenen Auflösungen und speichert sie im `output/` Ordner:
- **Original**: Behält die ursprüngliche Auflösung bei
- **1400px**: Skaliert auf 1400px Breite
- **1000px**: Skaliert auf 1000px Breite  
- **500px**: Skaliert auf 500px Breite  
- **500px Square** (optional): Skaliert auf 500x500 Pixel im 1:1-Format


Alle Versionen verwenden den VP9-Codec für Video und Opus für Audio.

## Voraussetzungen

- **FFmpeg** muss installiert sein
- **Bash** (Linux/macOS/WSL)

### FFmpeg Installation

#### macOS (empfohlen via Homebrew):
```bash
# Homebrew installieren (falls noch nicht vorhanden)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# FFmpeg installieren
brew install ffmpeg
```

#### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install ffmpeg
```

#### Windows (WSL):
```bash
sudo apt update
sudo apt install ffmpeg
```

## Verwendung

1. Lege alle MP4-Dateien, die konvertiert werden sollen, in den `input/` Ordner
2. Führe das Skript aus (die Ordner `input/` und `output/` werden automatisch erstellt):

### Standard-Modus:

`bash ./convert.sh`

### Mit quadratischer 500px-Version:

`bash ./convert.sh --square`

oder 

`bash ./convert.sh -s`

## Parameter

- `--square` oder `-s`: Erstellt zusätzlich eine quadratische 1:1 Version der 500px Variante

## Ordnerstruktur

```
webmconverter/
├── convert.sh
├── input/          # Hier MP4-Dateien ablegen
│   └── video.mp4
└── output/         # Hier werden WebM-Dateien erstellt
    ├── video_original.webm
    ├── video_1400px.webm
    ├── video_1000px.webm
    ├── video_500px.webm
    └── video_500px_square.webm  # (nur mit --square)
```

## Ausgabe

### Standard-Ausgabe
Für jede `input.mp4` Datei im `input/` Ordner werden folgende WebM-Dateien im `output/` Ordner erstellt:
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

## Nutzung im HTML (Beispiel)

```html
<video autoplay muted playsinline loop preload="metadata" class="video-bg" poster="thumbnail.jpg">
    <source media="(min-width: 1500px)" src="output/input_original.webm" type="video/webm">
    <source media="(min-width: 1100px)" src="output/input_1400px.webm" type="video/webm">
    <source media="(min-width: 700px)" src="output/input_1000px.webm" type="video/webm">
    <source src="output/input_500px.webm" type="video/webm">
    <!-- MP4 Video als Fallback für Uralt-Browser wie IE11 -->
    <source src="input/input.mp4" type="video/mp4">
</video>
```
