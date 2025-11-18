# WebM Converter

Ein intelligentes Bash-Skript zur automatischen Konvertierung von MP4/MOV-Videos in WebM-Format mit adaptiver Qualitätsoptimierung, verschiedenen Auflösungen und Video-Type-basierter Kompression.

## Autor
Wolfgang Wagner (wwagner@wwagner.net)
Version: 1.6.2

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

## Beschreibung

Das Skript konvertiert alle MP4/MOV-Dateien aus dem `input/` Ordner in WebM-Format mit intelligenter Größenoptimierung:
- **Original**: Behält die ursprüngliche Auflösung bei (mit adaptivem CRF)
- **50% Variante**: Two-Pass Encoding für exakt 50% Dateigröße des Originals
- **1400px**: Skaliert auf 1400px Breite (nur wenn Original > 1400px)
- **1000px**: Skaliert auf 1000px Breite (nur wenn Original > 1000px)
- **500px**: Skaliert auf 500px Breite (nur wenn Original > 500px)
- **500px Square** (optional): Skaliert auf 500x500 Pixel im 1:1-Format
- **Custom Resolutions**: Benutzerdefinierte Auflösungen mit `--resolutions`

### 🆕 Neue Features in Version 1.6.0

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

1. Lege alle MP4/MOV-Dateien, die konvertiert werden sollen, in den `input/` Ordner
2. Führe das Skript aus (die Ordner `input/` und `output/` werden automatisch erstellt)

### Grundlegende Verwendung

**Standard-Modus** (alle Standard-Varianten):
```bash
bash ./convert.sh
```

**Mit Video-Type Angabe** (optimierte Kompression):
```bash
bash ./convert.sh --type film
bash ./convert.sh --type screencast
bash ./convert.sh --type animation
```

**Mit quadratischer 500px-Version**:
```bash
bash ./convert.sh --square
```

**Interaktive Type-Auswahl** (Script fragt nach Video-Typ):
```bash
bash ./convert.sh
# → Interaktive Abfrage: "Welcher Video-Typ?"
```

### Erweiterte Verwendung

**Nur bestimmte Varianten erstellen**:
```bash
# Nur Original + 50% Variante
bash ./convert.sh --variants "original,50percent"

# Nur Square-Variante
bash ./convert.sh --variants "square"

# Nur 50% Variante
bash ./convert.sh --variants "50percent"
```

**Custom Resolutions**:
```bash
# Statt 1400/1000/500px → Custom Resolutions
bash ./convert.sh --resolutions "1920,1280,720"

# Kombinierbar mit Varianten (Type-Filter)
bash ./convert.sh --resolutions "1920,720" --variants "original,50percent"
```

**Encoding-Speed anpassen**:
```bash
# Schneller (schlechtere Kompression)
bash ./convert.sh --speed 4

# Langsamer (bessere Kompression)
bash ./convert.sh --speed 0
```

**Dry-Run (Simulation)**:
```bash
# Zeigt was gemacht würde, ohne zu konvertieren
bash ./convert.sh --dry-run
```

**Verbose Mode**:
```bash
# Zeigt detaillierte FFmpeg-Ausgabe
bash ./convert.sh --verbose
```

**Hilfe anzeigen**:
```bash
bash ./convert.sh --help
```

### Beispiele aus der Praxis

**Screencast für Tutorial-Video**:
```bash
bash ./convert.sh --type screencast --resolutions "1920,1280" --verbose
```

**Film für Website (alle Varianten)**:
```bash
bash ./convert.sh --type film --square
```

**Social Media (nur Square)**:
```bash
bash ./convert.sh --type nature --variants "square"
```

**Action-Video mit 50% Größenreduktion**:
```bash
bash ./convert.sh --type action --variants "50percent"
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
    └── video_500px_square.webm  # (nur mit --square)
```

## Ausgabe

### Standard-Ausgabe
Für jede `input.mp4` Datei im `input/` Ordner werden folgende WebM-Dateien im `output/` Ordner erstellt:
- `input_original.webm` - Originalauflösung (mit optimalem CRF basierend auf Type + Bitrate)
- `input_50percent.webm` - 50% Dateigröße in Originalauflösung (Two-Pass Encoding)
- `input_1400px.webm` - 1400px Breite (nur wenn Original > 1400px)
- `input_1000px.webm` - 1000px Breite (nur wenn Original > 1000px)
- `input_500px.webm` - 500px Breite (nur wenn Original > 500px)

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

## Qualitätseinstellungen

### 1. Video-Type-basierte CRF-Auswahl (Version 1.6.0)

Das Skript wählt den optimalen Basis-CRF basierend auf dem Video-Typ:

| Video-Typ | Basis-CRF | Anwendungsfall | Audio-Bitrate |
|-----------|-----------|----------------|---------------|
| **screencast** | 40 | Bildschirmaufnahmen, Präsentationen | 64 kbps |
| **animation** | 37 | Animierte Videos, Motion Graphics | 96 kbps |
| **nature** | 33 | Naturfilme, moderate Bewegung | 128 kbps |
| **action** | 29 | Action-Szenen, schnelle Schnitte | 128 kbps |
| **film** | 26 | Kinofilme, höchste Qualität | 160 kbps |

### 2. Bitrate-basierte CRF-Anpassung

Der Basis-CRF wird zusätzlich basierend auf der Input-Bitrate angepasst:

| Input-Bitrate | CRF-Anpassung | Grund |
|---------------|---------------|-------|
| < 2 Mbps | -3 | Niedrige Bitrate → mehr komprimieren |
| 2-5 Mbps | +0 | Normale Bitrate → Basis-CRF verwenden |
| 5-10 Mbps | +4 | Hohe Bitrate → weniger komprimieren |
| > 10 Mbps | +8 | Sehr hohe Bitrate → minimal komprimieren |

**Beispiel:**
- Film (Basis-CRF 26) mit 8 Mbps Input-Bitrate → finaler CRF 30 (26 + 4)
- Screencast (Basis-CRF 40) mit 1.5 Mbps Input-Bitrate → finaler CRF 37 (40 - 3)

### 3. Resolutions-basierte CRF-Anpassung

Für skalierte Versionen wird der CRF zusätzlich angepasst:

| Resolution | CRF-Offset | Finaler CRF (Beispiel Film @ 5 Mbps) |
|------------|------------|--------------------------------------|
| Original | +0 | 26 |
| 1400px | +2 | 28 |
| 1000px | +3 | 29 |
| 500px | +5 | 31 |

Kleinere Auflösungen benötigen weniger Bits für dieselbe wahrgenommene Qualität.

### 4. 50% Variante - Two-Pass Encoding

Die 50%-Variante verwendet präzises Two-Pass Encoding:

1. **Pass 1**: FFmpeg analysiert das Video und erstellt Statistik-Log
2. **Bitrate-Berechnung**:
   ```
   Ziel-Bitrate = (Input-Dateigröße / 2) / Dauer
   ```
3. **Pass 2**: FFmpeg kodiert mit exakter Ziel-Bitrate
4. **Resultat**: WebM-Datei mit ~50% Größe (±5%)

**Vorteile gegenüber CRF-Iteration:**
- Präziser (2 Passes statt 3-6 Iterationen)
- Schneller (weniger Re-Encodings)
- Konsistentere Qualität

### 5. Technische Optimierungen

- **VP9-Codec** mit modernsten Einstellungen:
  - `threads`: Dynamisch (basierend auf CPU-Kerne)
  - `speed`: Konfigurierbar 0-5 (Standard: 2)
  - `tile-columns 1`: Optimal für Portrait-Videos
  - `row-mt 1`: Verbessertes Multi-Threading
- **Opus-Audio**: Variabel 64-160 kbps (abhängig von Video-Type)
- **Format-Enforcement**: `-f webm` für korrekte Container-Struktur

### 6. Intelligente Dateigröße-Kontrolle

Das Skript garantiert, dass WebM-Dateien ≤ Original MP4 sind:

1. Erste Kodierung mit berechnetem CRF (Type + Bitrate + Resolution)
2. Automatische CRF-Erhöhung um +3 wenn WebM > MP4
3. Wiederholung bis WebM ≤ MP4 oder max. CRF 50 erreicht
4. Überspringt Konvertierung falls nicht kleiner machbar

**Typisches Beispiel:**
```
Film (2000px, 6 Mbps) → Original
├─ Basis-CRF: 26 (film)
├─ Bitrate-Adjustment: +4 (5-10 Mbps)
├─ Start-CRF: 30
├─ Iteration 1: CRF 30 → WebM 85% von MP4
└─ ✅ Fertig (WebM < MP4)
```

## Quadratische Version Details

Die quadratische 500px-Version verwendet intelligentes Zuschneiden:
- Das Video wird zunächst so skaliert, dass es mindestens 500px in beide Richtungen hat
- Anschließend wird es zentriert auf exakt 500x500 Pixel zugeschnitten
- Das Ergebnis ist ein perfektes 1:1-Quadrat, ideal für Social Media Plattformen

## Hinweise

### Performance
- Die Konvertierung kann je nach Dateigröße, Video-Typ und Systemleistung einige Zeit dauern
- **Two-Pass Encoding** (50% Variante) dauert länger, ist aber präziser
- **`--speed`** Parameter ermöglicht Trade-off zwischen Geschwindigkeit und Kompression
- **Threads** werden automatisch an CPU-Kerne angepasst

### Qualität & Größe
- WebM-Dateien sind **garantiert** kleiner oder gleich dem Original MP4
- **Video-Type-Optimierung** sorgt für beste Qualität bei kleinster Dateigröße
- Das Seitenverhältnis wird automatisch beibehalten
- **Upscaling wird vermieden**: Keine 1400px Version für 800px breite Videos
- **Bitrate-Detection** mit 3-Level-Fallback für robuste CRF-Auswahl

### Fehlerbehandlung
- Audio-only Dateien werden automatisch übersprungen
- Korrupte Dateien führen nicht zum Script-Abbruch
- **Cleanup-Trap** entfernt Temp-Dateien bei Abbruch (Ctrl+C)
- Detaillierte Statistik am Ende zeigt Erfolge und Fehler

### Ausgabe
- **Verbose Mode** (`--verbose`): Zeigt vollständige FFmpeg-Ausgabe
- **Dry-Run** (`--dry-run`): Simulation ohne tatsächliche Konvertierung
- **Statistik**: Automatische Zusammenfassung mit Kompressionsrate und Platzeinsparung
- Das Skript zeigt detaillierte Informationen über Dateigröße und verwendete CRF-Werte

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

### Responsive Video mit Media Queries

```html
<video autoplay muted playsinline loop preload="metadata" class="video-bg" poster="thumbnail.jpg">
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
