# WebM Converter — macOS App

Native macOS App (SwiftUI, macOS 13+) für die Konvertierung von MP4/MOV-Videos nach WebM.  
Drag & Drop, alle Funktionen des Bash-Skripts `convert.sh`, kein Xcode nötig.

---

## Voraussetzungen

| Was | Warum | Installieren |
|-----|-------|--------------|
| **macOS 13** (Ventura) oder neuer | Mindestanforderung | System-Update |
| **Xcode Command Line Tools** | Swift-Compiler | `xcode-select --install` |
| **FFmpeg** | Videokonvertierung | `brew install ffmpeg` |
| **Homebrew** *(optional)* | Nur für FFmpeg nötig | [brew.sh](https://brew.sh) |

> **Kein Xcode nötig** — nur die Command Line Tools reichen aus.  
> Größe: ~15 MB (CLT) + ~300 MB (FFmpeg).

---

## Auf einem neuen MacBook kompilieren

### 1. Xcode Command Line Tools installieren

```bash
xcode-select --install
```

Ein Dialog erscheint → „Installieren" klicken → ca. 5 Minuten warten.

Prüfen ob alles da ist:

```bash
swift --version
# Erwartete Ausgabe: swift-driver version: ... Swift version 5.9 (oder höher)
```

### 2. FFmpeg installieren

```bash
# Homebrew installieren (falls noch nicht vorhanden)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# FFmpeg installieren
brew install ffmpeg
```

Auf **Apple Silicon** (M1/M2/M3) danach sicherstellen, dass `/opt/homebrew/bin` im PATH ist:

```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
ffmpeg -version   # sollte Versionsnummer ausgeben
```

### 3. Repository klonen / Dateien kopieren

```bash
# Per Git klonen
git clone <repo-url> ~/webmconverter
cd ~/webmconverter/WebMConverterApp

# Oder: Ordner per AirDrop / USB / iCloud übertragen und dann:
cd ~/Downloads/webmconverter/WebMConverterApp
```

### 4. App bauen

```bash
bash build-app.sh
```

Das Script erledigt automatisch:
1. Swift-Quellcode kompilieren (`swift build -c release`)
2. App-Bundle-Struktur erstellen (`WebM Converter.app/Contents/…`)
3. `Info.plist` schreiben
4. App-Icon in allen erforderlichen Auflösungen rendern
5. `.icns`-Datei packen (`iconutil`)
6. Ad-hoc Code-Signatur setzen (`codesign --sign -`)

Fertige App liegt in:

```
WebMConverterApp/build/WebM Converter.app
```

### 5. App starten oder installieren

```bash
# Direkt starten
open "build/WebM Converter.app"

# In /Applications installieren (empfohlen)
cp -r "build/WebM Converter.app" /Applications/

# Danach über Spotlight (⌘ Space → "WebM") oder Launchpad starten
```

---

## Häufige Probleme beim Erstbau

### „command not found: swift"

Die Xcode Command Line Tools fehlen oder sind nicht aktiv:

```bash
xcode-select --install
# oder, wenn schon installiert:
sudo xcode-select --reset
```

### „Build failed – binary not found"

Vollständige Fehlerausgabe anzeigen:

```bash
swift build -c release
```

Häufigste Ursachen: falsches macOS (< 13), Swift < 5.9, fehlende Berechtigungen.

### Gatekeeper-Warnung beim ersten Öffnen

macOS blockiert ad-hoc signierte Apps beim ersten Start:

```
"WebM Converter" kann nicht geöffnet werden, da Apple es nicht auf Schadsoftware überprüfen kann.
```

**Lösung A** (einmalig per Rechtsklick):  
Rechtsklick auf `WebM Converter.app` → **Öffnen** → **Öffnen** bestätigen.

**Lösung B** (Terminal):

```bash
xattr -dr com.apple.quarantine "/Applications/WebM Converter.app"
```

### App startet, aber FFmpeg nicht gefunden

Die App sucht FFmpeg in diesen Pfaden (in Reihenfolge):

```
/opt/homebrew/bin/ffmpeg    ← Apple Silicon (Standard)
/usr/local/bin/ffmpeg       ← Intel Mac (Standard)
/usr/bin/ffmpeg
which ffmpeg                ← Fallback
```

Pfad prüfen:

```bash
which ffmpeg
# z.B. /opt/homebrew/bin/ffmpeg  → alles ok
# kein Output → FFmpeg nicht im PATH → brew install ffmpeg
```

---

## Nach Code-Änderungen neu bauen

```bash
cd WebMConverterApp
bash build-app.sh --open   # baut und öffnet direkt
```

Mit `--open` wird die neue Version automatisch gestartet. Läuft die App noch, zuvor beenden.

---

## Projektstruktur

```
WebMConverterApp/
│
├── Package.swift               Swift Package Manager Konfiguration
├── build-app.sh                Build-Script → erzeugt WebM Converter.app
├── create-icon.swift           App-Icon-Generator (AppKit/Core Graphics)
├── icon.svg                    Icon-Quellgrafik (SVG)
│
└── Sources/WebMConverter/
    ├── main.swift              Einstiegspunkt (NSApplication)
    ├── AppDelegate.swift       Fenster-Erstellung, SwiftUI-Host
    ├── Models.swift            VideoType, ConversionSettings, VideoFile
    ├── FFmpegService.swift     Alle FFmpeg/FFprobe-Aufrufe
    ├── ConversionManager.swift Warteschlange, async Job-Orchestrierung
    ├── ContentView.swift       Haupt-UI: Drop-Zone, Dateiliste, Log
    └── SettingsView.swift      Einstellungs-Sheet
```

### Technischer Stack

| Komponente | Technologie |
|---|---|
| UI-Framework | SwiftUI (macOS 13+) |
| Build-System | Swift Package Manager (kein Xcode nötig) |
| Concurrency | Swift async/await, `@MainActor` |
| Video-Backend | FFmpeg (VP9 + Opus, Two-Pass, FFprobe) |
| Icon-Rendering | AppKit / Core Graphics (keine externen Tools) |
| Code-Signatur | Ad-hoc (`codesign --sign -`) |

---

## Schnell-Referenz: Alle Build-Befehle

```bash
# Einmalig: Abhängigkeiten
xcode-select --install
brew install ffmpeg

# App bauen
bash build-app.sh

# App bauen + direkt starten
bash build-app.sh --open

# In /Applications installieren
cp -r "build/WebM Converter.app" /Applications/

# Gatekeeper-Quarantäne entfernen (falls nötig)
xattr -dr com.apple.quarantine "/Applications/WebM Converter.app"

# Nur kompilieren ohne App-Bundle (zum Testen)
swift build -c release

# Build-Artefakte löschen
rm -rf .build build
```
