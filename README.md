# WebM Converter

Ein Bash-Skript zur automatischen Konvertierung von MP4-Videos in WebM-Format mit verschiedenen Auflösungen.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)  
Version: 1.3.0

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

Das Skript konvertiert alle MP4-Dateien aus dem `input/` Ordner in WebM-Format mit intelligenter Größenoptimierung:
- **Original**: Behält die ursprüngliche Auflösung bei
- **1400px**: Skaliert auf 1400px Breite (nur wenn Original > 1400px)
- **1000px**: Skaliert auf 1000px Breite (nur wenn Original > 1000px)
- **500px**: Skaliert auf 500px Breite (nur wenn Original > 500px)
- **500px Square** (optional): Skaliert auf 500x500 Pixel im 1:1-Format

### 🆕 Neue Features in Version 1.3.0

- **Automatische Dateigröße-Kontrolle**: Garantiert kleinere WebM-Dateien als das Original MP4
- **Intelligente Upscaling-Vermeidung**: Erstellt nur Versionen kleiner als das Original
- **Adaptive CRF-Anpassung**: Erhöht automatisch die Kompression bis WebM < MP4
- **Optimierte VP9-Einstellungen**: Bessere Performance und Qualität für alle Videoformate

Alle Versionen verwenden den VP9-Codec für Video und Opus für Audio mit modernsten Optimierungen.

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

### Adaptive CRF-Werte (automatisch angepasst)
- **Original**: CRF 30 (wird automatisch erhöht falls WebM > MP4)
- **1400px**: CRF 32 (wird automatisch erhöht falls WebM > MP4)
- **1000px**: CRF 33 (wird automatisch erhöht falls WebM > MP4)
- **500px**: CRF 35 (wird automatisch erhöht falls WebM > MP4)

### Technische Optimierungen
- **VP9-Codec** mit modernsten Einstellungen:
  - `threads 8`: Bessere Multi-Core-Performance
  - `speed 2`: Optimal für Qualität/Geschwindigkeit-Balance
  - `tile-columns 1`: Ideal für Hochformat-Videos
  - `row-mt 1`: Verbessertes Multi-Threading
- **Opus-Audio** mit 128kbps für beste Audioqualität

### Intelligente Dateigröße-Kontrolle
Das Skript garantiert, dass WebM-Dateien kleiner als das Original MP4 sind:
1. Erste Kodierung mit Standard-CRF
2. Automatische CRF-Erhöhung um +3 wenn WebM > MP4 
3. Wiederholung bis WebM ≤ MP4 oder max. CRF 50 erreicht
4. Überspringt Konvertierung falls nicht effizienter als MP4

## Quadratische Version Details

Die quadratische 500px-Version verwendet intelligentes Zuschneiden:
- Das Video wird zunächst so skaliert, dass es mindestens 500px in beide Richtungen hat
- Anschließend wird es zentriert auf exakt 500x500 Pixel zugeschnitten
- Das Ergebnis ist ein perfektes 1:1-Quadrat, ideal für Social Media Plattformen

## Hinweise

- Die Konvertierung kann je nach Dateigröße und Systemleistung einige Zeit dauern
- WebM-Dateien sind **garantiert** kleiner oder gleich dem Original MP4
- Das Seitenverhältnis wird automatisch beibehalten
- Upscaling wird intelligent vermieden (z.B. keine 1400px Version für 800px breite Videos)
- Das Skript zeigt detaillierte Informationen über Dateigröße und verwendete CRF-Werte

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
