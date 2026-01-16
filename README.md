# WebM Converter

Ein intelligentes Bash-Skript zur automatischen Konvertierung von MP4/MOV-Videos in WebM-Format mit adaptiver Qualitätsoptimierung, verschiedenen Auflösungen und Video-Type-basierter Kompression.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)
Version: 1.7.0

---

## 📑 Inhaltsverzeichnis

### Schnellstart
- [📥 Installation](#-installation)
- [🚀 Quick Start für Mac](#-quick-start-für-mac)
- [🎬 Erster Testlauf](#-erster-testlauf)
- [💻 Quick Start für Windows & Linux](#-quick-start-für-windows--linux)

### Nutzung
- [Grundlegende Verwendung](#grundlegende-verwendung)
- [Häufige Anwendungsfälle](#häufige-anwendungsfälle)
- [Alle Parameter im Überblick](#parameter)

### Hilfe & Referenz
- [🔧 Troubleshooting für Mac](#-troubleshooting-für-mac)
- [HTML-Beispiele](#nutzung-im-html-beispiel)
- [Update-Anleitung](#-update-anleitung)

### Hintergrund
- [Was ist WebM?](#was-ist-webm)
- [Technische Details](#technische-details) (Fortgeschritten)

---

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

## 📥 Installation

### Variante 1: ZIP-Download (Einfach - Empfohlen für Einsteiger)

1. **Script herunterladen**:
   - Gehe zu: https://github.com/wwagner-net/convert.sh
   - Klicke auf den grünen **"Code"**-Button
   - Wähle **"Download ZIP"**
   - Die Datei `convert.sh-main.zip` wird heruntergeladen

2. **ZIP entpacken**:
   - Doppelklick auf `convert.sh-main.zip` im Downloads-Ordner
   - macOS entpackt automatisch → Ordner `convert.sh-main` entsteht

3. **Ordner verschieben und umbenennen** (optional, aber empfohlen):
   ```
   Empfohlener Speicherort:
   /Users/IhrBenutzername/scripts/webmconverter
   ```

   **So geht's**:
   - Öffne den Finder
   - Gehe zu Ihrem Benutzerordner (Haus-Symbol in der Seitenleiste)
   - Erstelle einen Ordner `scripts` (falls nicht vorhanden):
     - Rechtsklick → **Neuer Ordner** → Name: `scripts`
   - Verschiebe `convert.sh-main` in den `scripts`-Ordner
   - Benenne `convert.sh-main` um in `webmconverter`:
     - Rechtsklick auf den Ordner → **Umbenennen** → `webmconverter`

4. **Weiter mit Quick Start** ↓

---

### Variante 2: Git Clone (Für Git-Nutzer)

**Voraussetzung**: Git muss installiert sein (bei macOS meist vorinstalliert).

1. **Terminal öffnen**:
   - Drücke `Cmd + Leertaste`
   - Tippe "Terminal" und drücke Enter

2. **Zum gewünschten Ordner navigieren**:
   ```bash
   # Erstelle scripts-Ordner falls nicht vorhanden
   mkdir -p ~/scripts

   # Wechsle in den scripts-Ordner
   cd ~/scripts
   ```

3. **Repository klonen**:
   ```bash
   git clone https://github.com/wwagner-net/convert.sh.git
   ```

   **Hinweis**: Das erstellt einen Ordner namens `convert.sh` (nicht `webmconverter`)

4. **In den Ordner wechseln**:
   ```bash
   cd convert.sh
   ```

5. **Optional umbenennen** (für konsistente Pfade):
   ```bash
   # Aus dem Ordner rausgehen
   cd ..

   # Umbenennen zu webmconverter
   mv convert.sh webmconverter

   # Wieder reingehen
   cd webmconverter
   ```

6. **Weiter mit Quick Start Schritt 2** ↓

---

### Wo sollte das Script liegen?

**Empfohlene Speicherorte**:
```
✅ /Users/IhrBenutzername/scripts/webmconverter
✅ /Users/IhrBenutzername/Documents/webmconverter
✅ /Users/IhrBenutzername/Desktop/webmconverter
```

**Nicht empfohlen**:
```
❌ /Downloads/webmconverter  (wird oft aufgeräumt)
❌ /Applications/webmconverter  (nur für installierte Apps)
```

**Tipp**: Der Pfad `~/scripts/webmconverter` ist in der Anleitung Standard - wenn Sie einen anderen Ort wählen, passen Sie die Pfade entsprechend an.

---

## 🚀 Quick Start für Mac

### Schritt 1: Terminal öffnen
1. Drücke `Cmd + Leertaste` um Spotlight zu öffnen
2. Tippe "Terminal" und drücke Enter
3. Ein schwarzes oder weißes Fenster öffnet sich

### Schritt 2: FFmpeg installieren
Kopiere diese Zeile ins Terminal und drücke Enter:
```bash
brew install ffmpeg
```

**Falls "brew: command not found" erscheint**, installiere zuerst Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
*(Homebrew ist ein sicherer Paket-Manager für Mac, empfohlen von Apple-Entwicklern)*

**⚠️ WICHTIG**: Nach der Homebrew-Installation erscheint möglicherweise:
```
==> Next steps:
- Run these two commands in your terminal to add Homebrew to your PATH:
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
```
**Kopiere und führe diese beiden Befehle aus**, sonst funktioniert `brew` nicht!

Danach nochmal `brew install ffmpeg` ausführen.

### Schritt 3: Zum Script-Ordner navigieren
```bash
cd /Users/IhrBenutzername/scripts/webmconverter
```
*Ersetze "IhrBenutzername" mit Ihrem Mac-Benutzernamen (oder ziehe den Ordner ins Terminal)*

**Tipp**: Ordner ins Terminal ziehen statt Pfad eintippen:
1. Tippe `cd ` (mit Leerzeichen am Ende)
2. Ziehe den `webmconverter`-Ordner aus dem Finder ins Terminal
3. Drücke Enter

### Schritt 4: Videos konvertieren
1. Kopiere Ihre MP4/MOV-Dateien in den `input/` Ordner (wird automatisch erstellt)
2. Führe das Script aus:
```bash
bash convert.sh
```
3. Fertige WebM-Dateien finden Sie im `output/` Ordner

**Das war's!** Die konvertierten Videos sind nun bereit für Ihre Website.

---

## 🎬 Erster Testlauf

### Was passiert beim ersten Ausführen?

Wenn Sie `bash convert.sh` zum ersten Mal ausführen:

1. **Ordner werden erstellt** (falls nicht vorhanden):
   ```
   ✓ Erstelle input/-Ordner
   ✓ Erstelle output/-Ordner
   ```

2. **Video-Typ Abfrage** (wenn kein `--type` angegeben):
   ```
   Welcher Video-Typ? (screencast/animation/nature/action/film)
   Ihre Eingabe: film
   ```
   **Hilfe zur Auswahl**:
   - `screencast`: Bildschirmaufnahmen, Präsentationen, Tutorials
   - `animation`: Motion Graphics, animierte Videos, 2D/3D-Animationen
   - `nature`: Naturfilme, Interviews, Dokumentationen
   - `action`: Action-Szenen, Sport, schnelle Schnitte
   - `film`: Spielfilme, cinematische Videos, höchste Qualität

3. **Konvertierung läuft**:
   ```
   Verarbeite: mein-video.mp4
   ├─ Video-Breite: 1920px
   ├─ Bitrate: 8.5 Mbps
   ├─ CRF: 30 (optimiert für film)
   │
   ├─ Erstelle: mein-video_original.webm
   │  ├─ Encoding... ████████████████████ 100%
   │  └─ ✓ 125.3 MB → 89.7 MB (71.5%)
   │
   ├─ Erstelle: mein-video_50percent.webm (Two-Pass)
   │  ├─ Pass 1... ████████████████████ 100%
   │  ├─ Pass 2... ████████████████████ 100%
   │  └─ ✓ 125.3 MB → 62.6 MB (50.0%)
   │
   ├─ Erstelle: mein-video_1400px.webm
   │  └─ ✓ 54.2 MB
   │
   └─ ✓ Fertig!
   ```

4. **Abschluss-Statistik**:
   ```
   ═══════════════════════════════════════
   📊 Konvertierungs-Statistik
   ═══════════════════════════════════════
   Videos verarbeitet: 1
   Dateien erstellt: 3
   Übersprungen: 0
   ───────────────────────────────────────
   Input-Größe: 125.3 MB
   Output-Größe: 206.5 MB (alle Varianten zusammen)
   Durchschnittliche Kompression: 68.2%
   Platzeinsparung: 39.1 MB (pro Variante)
   ═══════════════════════════════════════
   ```

### Wie prüfe ich das Ergebnis?

**Im Finder**:
```bash
open output/
```
Öffnet den output-Ordner → Sie sehen alle erstellten WebM-Dateien

**Dateien vergleichen**:
- Original: `input/mein-video.mp4` (z.B. 125 MB)
- WebM Original: `output/mein-video_original.webm` (z.B. 89 MB = 71% Größe)
- WebM 50%: `output/mein-video_50percent.webm` (z.B. 62 MB = 50% Größe)

**Qualität prüfen**:
- Doppelklick auf `.webm`-Datei → Öffnet in QuickTime/VLC
- Vergleiche Qualität mit Original MP4
- Bei guter Einstellung: Kaum sichtbarer Unterschied!

### Was ist eine "gute" Kompression?

| Kompressionsrate | Bewertung | Typisch für |
|-----------------|-----------|-------------|
| 60-75% | ⭐⭐⭐ Ausgezeichnet | Screencast, Animation |
| 75-85% | ⭐⭐ Gut | Film, Action |
| 85-95% | ⭐ Akzeptabel | Bereits komprimierte MP4s |
| > 95% | ⚠️ Wenig Ersparnis | Schon sehr optimierte Videos |

**Faustregel**: Wenn die WebM-Datei kleiner als das Original ist und die Qualität gut aussieht, war es erfolgreich!

### Häufige Fragen beim ersten Mal

**Q: Warum gibt es keine 1400px-Version?**
→ Ihr Video ist schmaler als 1400px. Das Script vermeidet Upscaling.

**Q: Was bedeutet "Two-Pass Encoding"?**
→ FFmpeg analysiert das Video zweimal für optimale Qualität bei exakt 50% Größe. Dauert länger, ist aber präziser.

**Q: Kann ich das abbrechen?**
→ Ja, mit `Ctrl+C`. Temporäre Dateien werden automatisch aufgeräumt.

**Q: Wo finde ich die Original-Dateien?**
→ Noch im `input/`-Ordner. Das Script löscht nie Ihre Originale!

---

## 💻 Quick Start für Windows & Linux

### Windows (mit WSL - Windows Subsystem for Linux)

**Voraussetzung**: WSL2 muss installiert sein. Falls nicht:

1. **WSL installieren**:
   - Öffne PowerShell als Administrator (Rechtsklick → "Als Administrator ausführen")
   - Führe aus:
     ```powershell
     wsl --install
     ```
   - Computer neu starten

2. **Ubuntu Terminal öffnen**:
   - Windows-Suche → "Ubuntu" oder "WSL"
   - Terminal öffnet sich

3. **FFmpeg installieren**:
   ```bash
   sudo apt update
   sudo apt install ffmpeg
   ```
   → Gibt Passwort ein wenn gefragt

4. **Script installieren**:

   **Option A - Git Clone**:
   ```bash
   mkdir -p ~/scripts
   cd ~/scripts
   git clone https://github.com/wwagner-net/convert.sh.git
   cd convert.sh
   ```

   **Option B - ZIP Download**:
   - Download: https://github.com/wwagner-net/convert.sh
   - Entpacke im Windows-Explorer
   - Im WSL-Terminal:
     ```bash
     cd /mnt/c/Users/IhrBenutzername/Downloads/convert.sh-main
     ```

5. **Videos konvertieren**:
   ```bash
   # Videos in input/ ablegen (z.B. über Windows-Explorer)
   bash convert.sh
   ```

**Tipp**: Windows-Laufwerk C: ist unter `/mnt/c/` erreichbar in WSL.

---

### Linux (Ubuntu/Debian)

1. **Terminal öffnen**:
   - Tastenkombination: `Ctrl + Alt + T`

2. **FFmpeg installieren**:
   ```bash
   sudo apt update
   sudo apt install ffmpeg git
   ```

3. **Script installieren**:
   ```bash
   # Erstelle scripts-Ordner
   mkdir -p ~/scripts
   cd ~/scripts

   # Clone Repository
   git clone https://github.com/wwagner-net/convert.sh.git
   cd convert.sh
   ```

4. **Videos konvertieren**:
   ```bash
   # Videos in input/ ablegen
   # Über Dateimanager oder mit:
   cp /pfad/zum/video.mp4 input/

   # Konvertierung starten
   bash convert.sh
   ```

5. **Output anzeigen**:
   ```bash
   # Öffne output-Ordner im Dateimanager
   xdg-open output/
   ```

---

### Linux (Fedora/RHEL/CentOS)

**FFmpeg installieren**:
```bash
sudo dnf install ffmpeg git
```

Danach wie Ubuntu/Debian (Schritte 3-5).

---

### Linux (Arch/Manjaro)

**FFmpeg installieren**:
```bash
sudo pacman -S ffmpeg git
```

Danach wie Ubuntu/Debian (Schritte 3-5).

---

## Beschreibung

Das Skript konvertiert alle MP4/MOV-Dateien aus dem `input/` Ordner in WebM-Format mit intelligenter Größenoptimierung:
- **Original**: Behält die ursprüngliche Auflösung bei (mit adaptivem CRF)
- **50% Variante**: Two-Pass Encoding für exakt 50% Dateigröße des Originals
- **1400px**: Skaliert auf 1400px Breite (nur wenn Original > 1400px)
- **1000px**: Skaliert auf 1000px Breite (nur wenn Original > 1000px)
- **500px**: Skaliert auf 500px Breite (nur wenn Original > 500px)
- **500px Square** (optional): Skaliert auf 500x500 Pixel im 1:1-Format
- **Custom Resolutions**: Benutzerdefinierte Auflösungen mit `--resolutions`
- **WebP Thumbnails**: Automatische Erstellung von WebP-Standbildern (bei 1 Sekunde) für jedes Video

### 🆕 Neue Features in Version 1.7.0

#### Automatische Thumbnail-Extraktion
- **WebP Format**: Moderne, effiziente Bildkompression mit exzellenter Qualität
- **1 Sekunde Timing**: Frame-Extraktion bei 1 Sekunde Video-Laufzeit (mit Fallback für kurze Videos)
- **Original-Auflösung**: Thumbnails behalten die volle Video-Auflösung
- **Ein Thumbnail pro Video**: Nicht pro Variante, sondern pro Input-Datei
- **Automatisch**: Keine zusätzlichen Parameter nötig, funktioniert out-of-the-box

### Neue Features in Version 1.6.0

#### Intelligente Video-Type-Optimierung
- **Video-Type Detection**: Automatische oder manuelle Erkennung des Video-Typs (screencast, animation, nature, action, film)
- **Type-basierte CRF-Werte**: Optimale Kompression je nach Inhaltstyp
  - Screencast: CRF 40 (beste Kompression)
  - Animation: CRF 37
  - Nature: CRF 33
  - Action: CRF 29
  - Film: CRF 26 (höchste Qualität)
- **Bitrate-basierte Anpassung**: CRF wird zusätzlich basierend auf Input-Bitrate optimiert

#### 50% File Size Variante
- **Two-Pass Encoding**: Präzise Dateigröße-Kontrolle mit 2-Pass VP9 Encoding
- **Garantierte 50% Größe**: Ziel-Bitrate wird exakt berechnet für halbe Dateigröße
- **Original-Auflösung**: Behält volle Auflösung bei optimierter Kompression

#### Erweiterte Parametrisierung
- **`--help`**: Umfassende Hilfe und Dokumentation
- **`--version`**: Zeigt aktuelle Script-Version
- **`--type`**: Video-Typ festlegen (screencast/animation/nature/action/film)
- **`--speed`**: VP9 Encoding-Speed (0-5, Standard: 2)
- **`--variants`**: Auswahl welche Varianten erstellt werden (original, 50percent, square)
- **`--resolutions`**: Benutzerdefinierte Auflösungen (z.B. "1920,1280,720")
- **`--square`**: Erstellt 500px Square-Variante
- **`--dry-run`**: Simulation ohne tatsächliche Konvertierung
- **`--verbose`**: Zeigt detaillierte FFmpeg-Ausgabe

#### Performance & Stabilität
- **Dynamische Thread-Anzahl**: Automatische Erkennung der CPU-Kerne
- **Robuste Fehlerbehandlung**: Validierung von FFmpeg/FFprobe, Dateien, Parametern
- **Audio-Only Detection**: Überspringt Dateien ohne Video-Stream
- **Cleanup-Trap**: Automatische Bereinigung von Temp-Dateien bei Abbruch
- **Statistik-System**: Zeigt Zusammenfassung mit Kompressionsrate und gesparter Dateigröße

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

### Grundlegende Verwendung

Die einfachste Nutzung in 3 Schritten:

1. **Videos ablegen**: Kopiere MP4/MOV-Dateien in den `input/` Ordner
2. **Script starten**:
   ```bash
   bash convert.sh
   ```
3. **Fertig**: WebM-Dateien findest du im `output/` Ordner

**Standard-Modus** (erstellt alle Varianten):
```bash
bash convert.sh
```
→ Erstellt: original, 50%, 1400px, 1000px, 500px (abhängig von Video-Größe)

**Mit Video-Type** (bessere Kompression):
```bash
bash convert.sh --type film         # Höchste Qualität
bash convert.sh --type screencast   # Beste Kompression
```

**Mit Square-Version** (für Social Media):
```bash
bash convert.sh --square
```
→ Erstellt zusätzlich 500x500px quadratische Version

---

### Häufige Anwendungsfälle

Diese Beispiele decken 90% aller Nutzungsszenarien ab:

#### 🎥 Website-Video (alle Größen)
```bash
bash convert.sh --type film
```
→ Erstellt responsive Versionen für Desktop, Tablet, Mobile

#### 📺 Tutorial / Screencast
```bash
bash convert.sh --type screencast --resolutions "1920,1280"
```
→ Optimiert für Bildschirmaufnahmen, nur 1080p + 720p

#### 📱 Social Media (Instagram, TikTok)
```bash
bash convert.sh --type nature --variants "square"
```
→ Nur 500x500px quadratisches Video

#### 💾 Maximale Dateigröße-Reduktion
```bash
bash convert.sh --type action --variants "50percent"
```
→ Garantiert 50% Größe bei guter Qualität

#### 🎬 Cinematisches Video (höchste Qualität)
```bash
bash convert.sh --type film --variants "original,50percent"
```
→ Nur Original-Auflösung + 50%-Variante

#### ⚡ Schnelle Konvertierung (große Dateien)
```bash
bash convert.sh --type film --speed 4
```
→ Schnelleres Encoding, etwas größere Dateien

#### 🎨 Eigene Auflösungen
```bash
bash convert.sh --resolutions "1920,1080,720" --type film
```
→ Full HD, HD, HD-Ready Versionen

---

### Erweiterte Parameter

Für fortgeschrittene Nutzer und spezielle Anforderungen:

**Nur bestimmte Varianten**:
```bash
bash convert.sh --variants "original,50percent"  # Nur diese beiden
bash convert.sh --variants "square"              # Nur quadratisch
```

**Custom Resolutions kombinieren**:
```bash
bash convert.sh --resolutions "1920,720" --variants "original,50percent"
```

**Encoding-Speed anpassen** (0-5):
```bash
bash convert.sh --speed 0  # Langsam, beste Kompression
bash convert.sh --speed 4  # Schnell, größere Dateien
```

**Test ohne Konvertierung**:
```bash
bash convert.sh --dry-run  # Zeigt nur was passieren würde
```

**Debug-Modus**:
```bash
bash convert.sh --verbose  # Zeigt FFmpeg-Details
```

**Hilfe anzeigen**:
```bash
bash convert.sh --help
```

## Parameter

### Optionale Parameter

| Parameter | Kurzform | Beschreibung | Beispiel |
|-----------|----------|--------------|----------|
| `--help` | - | Zeigt umfassende Hilfe | `./convert.sh --help` |
| `--version` | - | Zeigt Script-Version | `./convert.sh --version` |
| `--type <TYPE>` | - | Video-Typ: screencast, animation, nature, action, film | `./convert.sh --type film` |
| `--speed <0-5>` | - | VP9 Encoding-Speed (0=langsam/beste Qualität, 5=schnell) | `./convert.sh --speed 1` |
| `--variants <LIST>` | - | Komma-separierte Liste: original, 50percent, square | `./convert.sh --variants "original,50percent"` |
| `--resolutions <LIST>` | - | Komma-separierte Custom-Resolutions in px | `./convert.sh --resolutions "1920,720"` |
| `--square` | `-s` | Erstellt 500px Square-Variante | `./convert.sh --square` |
| `--dry-run` | - | Simulation ohne Konvertierung | `./convert.sh --dry-run` |
| `--verbose` | - | Zeigt detaillierte FFmpeg-Ausgabe | `./convert.sh --verbose` |

### Parameter-Kombinationsregeln

- **`--variants` + `--resolutions`**: Variants = TYPE-Filter (original/50percent/square), Resolutions = Custom-Größen
- **Nur `--resolutions`**: Erstellt NUR Custom-Resolutions (keine original/50percent Varianten)
- **Nur `--variants`**: Filtert Standard-Varianten (original/50percent/square/1400px/1000px/500px)
- **`--square` ohne `--variants`**: Erstellt zusätzlich zur Standard-Ausgabe auch Square
- **Ohne `--type`**: Interaktive Abfrage beim ersten Video

## Ordnerstruktur

```
webmconverter/
├── convert.sh
├── input/          # Hier MP4/MOV-Dateien ablegen
│   ├── video.mp4
│   └── video.mov
└── output/         # Hier werden WebM-Dateien erstellt
    ├── video_original.webm
    ├── video_1400px.webm
    ├── video_1000px.webm
    ├── video_500px.webm
    ├── video_500px_square.webm  # (nur mit --square)
    └── video_thumbnail.webp
```

## Ausgabe

### Standard-Ausgabe
Für jede `input.mp4` Datei im `input/` Ordner werden folgende WebM-Dateien im `output/` Ordner erstellt:
- `input_original.webm` - Originalauflösung (mit optimalem CRF basierend auf Type + Bitrate)
- `input_50percent.webm` - 50% Dateigröße in Originalauflösung (Two-Pass Encoding)
- `input_1400px.webm` - 1400px Breite (nur wenn Original > 1400px)
- `input_1000px.webm` - 1000px Breite (nur wenn Original > 1000px)
- `input_500px.webm` - 500px Breite (nur wenn Original > 500px)
- `input_thumbnail.webp` - WebP Thumbnail bei 1 Sekunde (Original-Auflösung)

### Mit --square Parameter zusätzlich:
- `input_500px_square.webm` - 500x500 Pixel im 1:1-Format (zentriert zugeschnitten)

### Mit Custom Resolutions (z.B. `--resolutions "1920,720"`):
- `input_1920px.webm` - 1920px Breite
- `input_720px.webm` - 720px Breite

**Hinweis:** Bei Verwendung von `--resolutions` werden NUR die angegebenen Auflösungen erstellt (keine original/50percent Varianten). Um diese zusätzlich zu erhalten, nutze `--variants "original,50percent" --resolutions "1920,720"`.

### Statistik-Ausgabe am Ende
```
═══════════════════════════════════════
📊 Konvertierungs-Statistik
═══════════════════════════════════════
Videos verarbeitet: 3
Dateien erstellt: 15
Übersprungen: 0
───────────────────────────────────────
Input-Größe: 245.8 MB
Output-Größe: 89.3 MB
Kompression: 36.3%
Platzeinsparung: 156.5 MB
═══════════════════════════════════════
```

## Technische Details

Für die meisten Nutzer ist dieses Wissen nicht erforderlich. Das Script funktioniert "out of the box".

**Für Fortgeschrittene:** Detaillierte Informationen zu CRF-Berechnung, FFmpeg-Parametern, Algorithmen und Performance siehe [ADVANCED.md](ADVANCED.md).

### Kurz-Übersicht

**Video-Type-Optimierung:**
- Jeder Video-Typ (screencast, animation, nature, action, film) hat optimierte Einstellungen
- CRF-Werte werden automatisch basierend auf Typ, Bitrate und Auflösung berechnet
- Audio-Bitrate passt sich dem Content an (64-160 kbps)

**50% Variante:**
- Two-Pass Encoding für exakte Dateigröße (±5%)
- Behält volle Auflösung bei halber Dateigröße

**Qualitätsgarantie:**
- WebM ist garantiert ≤ Original MP4/MOV
- Automatische CRF-Anpassung bis optimales Ergebnis erreicht
- Upscaling wird vermieden (keine 1400px Version für 720px Videos)

**Performance:**
- Nutzt alle CPU-Kerne automatisch
- `--speed` Parameter für Geschwindigkeit vs. Qualität Trade-off
- Typisch: ~0.3x realtime (3 Minuten für 1 Minute Video bei Speed 2)

**Weitere Details:** [ADVANCED.md](ADVANCED.md)

## 🔄 Update-Anleitung

### Wie aktualisiere ich das Script auf eine neue Version?

#### Variante 1: Mit Git (empfohlen)

Wenn Sie das Script via `git clone` installiert haben:

```bash
# 1. Navigiere zum Script-Ordner
cd ~/scripts/webmconverter  # oder dein Installationsort

# 2. Aktualisiere das Script
git pull

# 3. Zeige die neue Version an
bash convert.sh --version
```

**Das war's!** Git lädt automatisch die neueste Version herunter.

**Hinweis**: Eigene Änderungen am Script werden überschrieben. Wenn Sie das Script angepasst haben, erstellen Sie vorher ein Backup:
```bash
cp convert.sh convert.sh.backup
```

---

#### Variante 2: Mit ZIP-Download

Wenn Sie das Script als ZIP heruntergeladen haben:

**Methode A - Komplett neu** (Sicher, aber umständlich):
1. Gehe zu https://github.com/wwagner-net/convert.sh
2. Download ZIP wie bei der Installation
3. Entpacke `convert.sh-main.zip`
4. Ersetze die alte `convert.sh` durch die neue

**Methode B - Nur Script ersetzen** (Schneller):
1. Gehe zu https://github.com/wwagner-net/convert.sh
2. Klicke auf `convert.sh`
3. Klicke auf **Raw** (oben rechts)
4. Rechtsklick → **Sichern unter** → Überschreibe alte `convert.sh`

**Wichtig**: Ihre `input/` und `output/` Ordner bleiben erhalten!

---

#### Wie prüfe ich meine aktuelle Version?

```bash
bash convert.sh --version
```

Zeigt z.B.: `Version: 1.6.2`

Vergleiche mit: https://github.com/wwagner-net/convert.sh/releases

---

#### Was ist neu in Version X.X.X?

Siehe [CHANGELOG.md](CHANGELOG.md) für detaillierte Release Notes.

---

## 🔧 Troubleshooting für Mac

### "brew: command not found"
**Problem**: Homebrew ist noch nicht installiert.

**Lösung**: Installiere Homebrew mit diesem Befehl:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Das Script fragt nach Ihrem Mac-Passwort - das ist normal und sicher.

Nach der Installation erscheint möglicherweise ein Hinweis wie:
```
==> Next steps:
- Run these two commands in your terminal to add Homebrew to your PATH:
```
Führe die angezeigten Befehle aus (meist `echo` und `eval`), danach funktioniert `brew install ffmpeg`.

---

### "ffmpeg: command not found" oder "FFprobe nicht gefunden"
**Problem**: FFmpeg ist nicht installiert oder nicht im PATH.

**Lösung**:
```bash
brew install ffmpeg
```

Falls Homebrew bereits installiert ist, aktualisiere es:
```bash
brew update
brew upgrade ffmpeg
```

**Prüfen ob FFmpeg funktioniert**:
```bash
ffmpeg -version
```
Sollte Versionsnummer anzeigen (z.B. "ffmpeg version 6.1.1").

---

### "Permission denied" beim Ausführen
**Problem**: Das Script hat keine Ausführungsrechte.

**Lösung**:
```bash
chmod +x convert.sh
```

Danach nochmal probieren:
```bash
bash convert.sh
```

---

### "No such file or directory" beim cd-Befehl
**Problem**: Der Pfad zum Script-Ordner ist falsch.

**Lösung - Einfache Methode**:
1. Öffne den `webmconverter`-Ordner im Finder
2. Im Terminal tippe: `cd ` (mit Leerzeichen!)
3. Ziehe den Ordner aus dem Finder ins Terminal-Fenster
4. Drücke Enter

**Lösung - Manuell**:
```bash
# Finde heraus wo du bist:
pwd

# Gehe zum Home-Verzeichnis:
cd ~

# Navigiere zum Script:
cd scripts/webmconverter
```

---

### "Operation not permitted" oder Sicherheitswarnung
**Problem**: macOS Gatekeeper blockiert das Script.

**Lösung**:
1. Öffne **Systemeinstellungen** > **Datenschutz & Sicherheit**
2. Scrolle nach unten zu "Sicherheit"
3. Klicke auf **"Trotzdem erlauben"** neben der FFmpeg-Warnung
4. Führe das Script erneut aus

**Alternative**: Erlaube Terminal vollen Festplattenzugriff:
1. **Systemeinstellungen** > **Datenschutz & Sicherheit**
2. **Festplattenvollzugriff**
3. Klicke auf **+** und füge **Terminal.app** hinzu

---

### Videos werden nicht gefunden
**Problem**: Keine MP4/MOV-Dateien im `input/`-Ordner.

**Lösung**:
1. Prüfe ob du im richtigen Ordner bist:
```bash
pwd
ls -la
```
Du solltest `convert.sh` sehen.

2. Prüfe den input-Ordner:
```bash
ls -la input/
```
Sind dort `.mp4` oder `.mov` Dateien?

3. Falls leer: Kopiere Videos in den input-Ordner:
```bash
# Ordner öffnen im Finder:
open input/
```
Dann Videos per Drag & Drop hineinziehen.

---

### Script bricht mit "Error" ab
**Problem**: Verschiedene Ursachen möglich.

**Lösung - Debug-Modus aktivieren**:
```bash
bash convert.sh --verbose
```
Zeigt detaillierte FFmpeg-Ausgabe. Kopiere die Fehlermeldung für weitere Hilfe.

**Häufige Ursachen**:
- **Video korrupt**: Probiere andere Datei
- **Kein Speicherplatz**: Prüfe `df -h` (mindestens 2x Video-Größe frei)
- **Audio-only Datei**: Wird automatisch übersprungen
- **Falsche Codec**: FFmpeg sollte alle gängigen Formate unterstützen

---

### "killed: 9" oder Script friert ein
**Problem**: macOS hat den Prozess abgebrochen (meist bei großen Dateien).

**Lösung**:
1. **Reduziere Encoding-Speed** (nutzt weniger RAM):
```bash
bash convert.sh --speed 4
```

2. **Verarbeite Videos einzeln**: Verschiebe alle bis auf eine Datei aus `input/`

3. **Prüfe Speicher**: Aktivitätsanzeige öffnen (Cmd+Leertaste → "Aktivitätsanzeige")
   - Ist genug RAM frei? (mindestens 2-4 GB)

---

### WebM-Dateien sind größer als MP4
**Problem**: Sollte nicht passieren - Script hat Size-Check.

**Lösung**:
1. **Prüfe Video-Typ**: Manche Inhalte komprimieren schlecht
```bash
bash convert.sh --type film  # Nutze höchste Qualität
```

2. **Manuell CRF testen**: Wenn `--verbose` zeigt "CRF 50 reached", ist das Video schon sehr komprimiert

3. **Alternative**: Nutze 50%-Variante:
```bash
bash convert.sh --variants "50percent"
```
Garantiert 50% der Originalgröße.

---

### Terminal zeigt "zsh: command not found: bash"
**Problem**: Unwahrscheinlich, aber Bash fehlt.

**Lösung**: Moderne Macs nutzen zsh als Standard-Shell. Probiere:
```bash
zsh convert.sh
```

Oder nutze die Shebang im Script:
```bash
./convert.sh
```
(Erfordert `chmod +x convert.sh` vorher)

---

### "Ich verstehe die Terminal-Befehle nicht"
**Kein Problem!** Hier die Grundlagen:

- `cd ordnername`: **Change Directory** - Wechsle in einen Ordner
- `ls`: **List** - Zeige Dateien im aktuellen Ordner
- `pwd`: **Print Working Directory** - Wo bin ich gerade?
- `bash script.sh`: Führe ein Bash-Script aus
- `Ctrl+C`: Bricht laufenden Befehl ab
- `Tab-Taste`: Auto-Vervollständigung (probiere `cd scr` + Tab)

**Tipp**: Viele Befehle unterstützen `--help`:
```bash
bash convert.sh --help
```

---

## Nutzung im HTML (Beispiel)

### Responsive Video mit Media Queries und WebP Thumbnail

```html
<video autoplay muted playsinline loop preload="metadata" class="video-bg" poster="output/video_thumbnail.webp">
    <!-- Original für sehr große Displays -->
    <source media="(min-width: 1500px)" src="output/video_original.webm" type="video/webm">

    <!-- 1400px für Desktop -->
    <source media="(min-width: 1100px)" src="output/video_1400px.webm" type="video/webm">

    <!-- 1000px für Tablet -->
    <source media="(min-width: 700px)" src="output/video_1000px.webm" type="video/webm">

    <!-- 500px für Mobile -->
    <source src="output/video_500px.webm" type="video/webm">

    <!-- MP4 Fallback für ältere Browser (sehr selten nötig bei 95% Browser-Support) -->
    <source src="input/video.mp4" type="video/mp4">
</video>
```

### Mit 50% Variante für schnelleres Laden

```html
<video autoplay muted playsinline loop preload="metadata">
    <!-- 50% Variante für beste Performance -->
    <source src="output/video_50percent.webm" type="video/webm">

    <!-- Original als Fallback -->
    <source src="output/video_original.webm" type="video/webm">
</video>
```

### Square Video für Social Media Embed

```html
<!-- Instagram-Style Video (1:1 Ratio) -->
<video width="500" height="500" controls>
    <source src="output/video_500px_square.webm" type="video/webm">
</video>
```

## Version History

Siehe [CHANGELOG.md](CHANGELOG.md) für eine detaillierte Übersicht aller Versionen.

## Bekannte Probleme

Siehe [ISSUES.md](ISSUES.md) für eine detaillierte Übersicht.

**Status**: 7/9 Probleme behoben in Version 1.6.0 ✅

**Verbleibende Optimierungen**:
- Race Conditions bei parallelen Ausführungen (PID-basierte Temp-Files)
- Disk Space Checks vor Konvertierung

## Lizenz

Dieses Projekt wurde von Wolfgang Wagner erstellt und steht zur freien Verwendung zur Verfügung.
