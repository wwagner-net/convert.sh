# Technische Details - WebM Converter

Diese Dokumentation richtet sich an fortgeschrittene Nutzer, die verstehen möchten, wie das Script intern funktioniert.

Für die grundlegende Nutzung siehe [README.md](README.md).

---

## 📑 Inhaltsverzeichnis

- [Qualitätseinstellungen](#qualitätseinstellungen)
  - [Video-Type-basierte CRF-Auswahl](#1-video-type-basierte-crf-auswahl)
  - [Bitrate-basierte CRF-Anpassung](#2-bitrate-basierte-crf-anpassung)
  - [Resolutions-basierte CRF-Anpassung](#3-resolutions-basierte-crf-anpassung)
  - [50% Variante - Two-Pass Encoding](#4-50-variante---two-pass-encoding)
  - [Technische Optimierungen](#5-technische-optimierungen)
  - [Intelligente Dateigröße-Kontrolle](#6-intelligente-dateigröße-kontrolle)
- [Quadratische Version Details](#quadratische-version-details)
- [Performance-Hinweise](#performance-hinweise)
- [FFmpeg-Parameter im Detail](#ffmpeg-parameter-im-detail)
- [Algorithmen und Logik](#algorithmen-und-logik)

---

## Qualitätseinstellungen

### 1. Video-Type-basierte CRF-Auswahl

Das Skript wählt den optimalen Basis-CRF (Constant Rate Factor) basierend auf dem Video-Typ:

| Video-Typ | Basis-CRF | Anwendungsfall | Audio-Bitrate |
|-----------|-----------|----------------|---------------|
| **screencast** | 40 | Bildschirmaufnahmen, Präsentationen | 64 kbps |
| **animation** | 37 | Animierte Videos, Motion Graphics | 96 kbps |
| **nature** | 33 | Naturfilme, moderate Bewegung | 128 kbps |
| **action** | 29 | Action-Szenen, schnelle Schnitte | 128 kbps |
| **film** | 26 | Kinofilme, höchste Qualität | 160 kbps |

**Warum unterschiedliche CRF-Werte?**
- **Screencast**: Statische Inhalte, viel Wiederholung → aggressive Kompression möglich
- **Animation**: Flache Farben, wenig Noise → gute Kompression möglich
- **Nature**: Komplexe Texturen, moderate Bewegung → ausgewogene Einstellungen
- **Action**: Schnelle Bewegung, viele Details → vorsichtige Kompression
- **Film**: Cinematische Qualität, Grain → minimale Kompression

---

### 2. Bitrate-basierte CRF-Anpassung

Der Basis-CRF wird zusätzlich basierend auf der Input-Bitrate angepasst:

| Input-Bitrate | CRF-Anpassung | Grund |
|---------------|---------------|-------|
| < 2 Mbps | -3 | Niedrige Bitrate → mehr komprimieren |
| 2-5 Mbps | +0 | Normale Bitrate → Basis-CRF verwenden |
| 5-10 Mbps | +4 | Hohe Bitrate → weniger komprimieren |
| > 10 Mbps | +8 | Sehr hohe Bitrate → minimal komprimieren |

**Beispiel-Berechnungen:**
- Film (Basis-CRF 26) mit 8 Mbps Input-Bitrate → finaler CRF 30 (26 + 4)
- Screencast (Basis-CRF 40) mit 1.5 Mbps Input-Bitrate → finaler CRF 37 (40 - 3)
- Animation (Basis-CRF 37) mit 12 Mbps Input-Bitrate → finaler CRF 45 (37 + 8)

**Logik:**
Videos mit hoher Bitrate haben bereits viele Details → weniger aggressive Kompression nötig.
Videos mit niedriger Bitrate sind bereits komprimiert → VP9 kann besser komprimieren als H.264.

---

### 3. Resolutions-basierte CRF-Anpassung

Für skalierte Versionen wird der CRF zusätzlich angepasst:

| Resolution | CRF-Offset | Finaler CRF (Beispiel Film @ 5 Mbps) |
|------------|------------|--------------------------------------|
| Original | +0 | 26 |
| 1400px | +2 | 28 |
| 1000px | +3 | 29 |
| 500px | +5 | 31 |

**Begründung:**
Kleinere Auflösungen benötigen weniger Bits für dieselbe wahrgenommene Qualität, da:
- Weniger Pixel = weniger Daten
- Details sind bei kleiner Darstellung weniger sichtbar
- Compression Artifacts fallen weniger auf

---

### 4. 50% Variante - Two-Pass Encoding

Die 50%-Variante verwendet präzises Two-Pass Encoding für exakte Dateigröße-Kontrolle:

#### Ablauf:

**Pass 1 - Analyse:**
```bash
ffmpeg -i input.mp4 -pass 1 -passlogfile /tmp/ffmpeg2pass \
  -c:v libvpx-vp9 -b:v TARGET_BITRATE \
  -speed 4 \  # Schnellere Analyse
  -an -f null /dev/null
```
→ FFmpeg analysiert das Video und erstellt Statistik-Log in `/tmp/ffmpeg2pass-0.log`

**Bitrate-Berechnung:**
```
Ziel-Dateigröße = Input-Dateigröße / 2
Video-Bitrate = (Ziel-Dateigröße * 8) / Dauer - Audio-Bitrate
```

**Beispiel:**
- Input: 100 MB, 60 Sekunden
- Ziel: 50 MB
- Audio: 128 kbps
- Video-Bitrate = (50 MB * 8) / 60s - 128 kbps ≈ 6.54 Mbps

**Pass 2 - Encoding:**
```bash
ffmpeg -i input.mp4 -pass 2 -passlogfile /tmp/ffmpeg2pass \
  -c:v libvpx-vp9 -b:v 6540k \
  -c:a libopus -b:a 128k \
  output.webm
```
→ Nutzt Analyse von Pass 1 für optimale Bitrate-Verteilung

#### Vorteile gegenüber CRF-Iteration:
- **Präziser**: Trifft Ziel-Dateigröße auf ±5% genau
- **Schneller**: 2 Passes statt 3-6 iterative Re-Encodings
- **Konsistentere Qualität**: Bitrate wird intelligent über das Video verteilt

---

### 5. Technische Optimierungen

#### VP9-Codec Parameter:

```bash
-c:v libvpx-vp9 \
-threads DETECTED_CORES \     # Auto-detect CPU cores (8-16 typical)
-speed 2 \                    # 0=slow/best, 5=fast (default: 2)
-tile-columns 1 \             # Optimal für Portrait-Videos
-row-mt 1 \                   # Enhanced multi-threading
-crf CALCULATED_CRF \         # Dynamic CRF based on type+bitrate
-b:v 0                        # CRF mode (not bitrate)
```

**Parameter-Erklärung:**

- **`-threads`**: Nutzt alle verfügbaren CPU-Kerne für schnelleres Encoding
- **`-speed 2`**: Balance zwischen Geschwindigkeit und Kompression
  - 0: Sehr langsam, beste Qualität (~2x Laufzeit)
  - 2: Gut ausgewogen (Standard)
  - 4: Schneller, ~20% größere Dateien
- **`-tile-columns 1`**:
  - Portrait-Videos profitieren von vertikaler Teilung
  - Landscape-Videos: Kein Unterschied
- **`-row-mt 1`**:
  - Multi-Threading auf Zeilen-Ebene
  - ~30% schneller auf modernen CPUs

#### Opus-Audio Parameter:

```bash
-c:a libopus \
-b:a DYNAMIC_BITRATE  # 64-160 kbps based on video type
```

| Video-Typ | Audio-Bitrate | Grund |
|-----------|--------------|-------|
| screencast | 64 kbps | Meist nur Sprache |
| animation | 96 kbps | Musik, aber nicht kritisch |
| nature/action | 128 kbps | Ambient-Sounds wichtig |
| film | 160 kbps | Höchste Audio-Qualität |

---

### 6. Intelligente Dateigröße-Kontrolle

Das Skript garantiert, dass WebM-Dateien ≤ Original MP4/MOV sind durch iterative CRF-Anpassung:

#### Algorithmus:

```
1. Berechne initialen CRF:
   CRF = BASE_CRF (type) + BITRATE_OFFSET + RESOLUTION_OFFSET

2. Encode mit CRF:
   ffmpeg ... -crf CRF ... output.webm

3. Vergleiche Dateigrößen:
   IF webm_size > mp4_size THEN
     CRF = CRF + 3
     GOTO 2

4. Abbruch-Bedingungen:
   - WebM ≤ MP4 → ✓ Erfolg
   - CRF ≥ 50 → ⚠️ Skip (WebM kann nicht kleiner werden)
```

#### Typisches Beispiel:

```
Film (1920x1080, 6 Mbps) → Original-Variante
├─ Basis-CRF: 26 (film)
├─ Bitrate-Adjustment: +4 (5-10 Mbps)
├─ Resolution-Offset: +0 (original)
├─ Start-CRF: 30
│
├─ Iteration 1: CRF 30
│  ├─ Input: 125.3 MB
│  ├─ Output: 106.5 MB (85% von Input)
│  └─ ✅ WebM < MP4 → Fertig!
│
└─ Resultat: 106.5 MB (15% Ersparnis)
```

**Worst-Case-Szenario:**
```
Bereits stark komprimiertes MP4 (1 Mbps)
├─ Iteration 1: CRF 33 → 102%
├─ Iteration 2: CRF 36 → 98%
├─ Iteration 3: CRF 39 → 95%
├─ Iteration 4: CRF 42 → 93%
├─ Iteration 5: CRF 45 → 91%
└─ ✅ Erfolg bei CRF 45
```

---

## Quadratische Version Details

Die quadratische 500px-Version (`--square`) verwendet intelligentes Zuschneiden:

### Algorithmus:

```bash
# 1. Skaliere so dass die kleinere Dimension = 500px
scale=500:500:force_original_aspect_ratio=increase

# 2. Zentriertes Zuschneiden auf exakt 500x500
crop=500:500
```

### Beispiele:

**Landscape-Video (1920x1080)**:
```
1920x1080
  → scale → 889x500 (Höhe auf 500, Breite proportional)
  → crop  → 500x500 (schneide 194px links + 194px rechts)
```

**Portrait-Video (1080x1920)**:
```
1080x1920
  → scale → 500x889 (Breite auf 500, Höhe proportional)
  → crop  → 500x500 (schneide 194px oben + 194px unten)
```

**Bereits quadratisch (1080x1080)**:
```
1080x1080
  → scale → 500x500 (direkt skalieren)
  → crop  → 500x500 (kein Zuschnitt nötig)
```

### FFmpeg-Befehl:

```bash
ffmpeg -i input.mp4 \
  -vf "scale=500:500:force_original_aspect_ratio=increase,crop=500:500" \
  -c:v libvpx-vp9 -crf CALCULATED_CRF \
  -c:a libopus -b:a 96k \
  output_square.webm
```

**Verwendung:**
Ideal für Social Media Plattformen:
- Instagram Feed (1:1)
- Facebook Posts
- TikTok (kann auch 9:16, aber 1:1 funktioniert)
- Twitter/X

---

## Performance-Hinweise

### Encoding-Geschwindigkeit

Typische Encoding-Zeiten auf Apple Silicon M1 (8-Core):

| Video | Auflösung | Dauer | Speed 0 | Speed 2 | Speed 4 |
|-------|-----------|-------|---------|---------|---------|
| Film | 1920x1080 | 60s | ~8 min | ~3 min | ~1.5 min |
| Film | 3840x2160 | 60s | ~30 min | ~12 min | ~6 min |
| Screencast | 1920x1080 | 60s | ~5 min | ~2 min | ~1 min |

**Faustregel:**
- Speed 0: ~0.1x realtime (10 Minuten für 1 Minute Video)
- Speed 2: ~0.3x realtime (3 Minuten für 1 Minute Video)
- Speed 4: ~0.6x realtime (1.5 Minuten für 1 Minute Video)

### CPU & RAM-Nutzung

**CPU:**
- Nutzt alle verfügbaren Kerne (100% Auslastung normal)
- Multi-Threading über `-threads` und `-row-mt`

**RAM:**
- Typical: 500-1000 MB pro Encoding-Prozess
- 4K-Videos: Bis zu 2-3 GB
- Two-Pass: Zusätzlich ~50 MB für Log-Files

**Empfehlung:**
- Mindestens 4 GB freier RAM
- Bei großen Videos (4K): 8 GB empfohlen
- Bei Problemen: `--speed 4` nutzen (weniger RAM-intensiv)

### Disk I/O

**Temporäre Dateien:**
- Two-Pass: `/tmp/ffmpeg2pass-*.log` (~50 MB)
- Werden nach Fertigstellung automatisch gelöscht
- Bei Abbruch (Ctrl+C): Cleanup-Trap löscht Temp-Files

**Speicherplatz:**
- Mindestens 2x Input-Größe frei empfohlen
- Output typisch 50-85% von Input
- Beispiel: 1 GB MP4 → ~500-850 MB WebM

---

## FFmpeg-Parameter im Detail

### Vollständiger Befehl (Original-Variante):

```bash
ffmpeg -i input.mp4 \
  -c:v libvpx-vp9 \
  -crf 30 \
  -b:v 0 \
  -threads 8 \
  -speed 2 \
  -tile-columns 1 \
  -row-mt 1 \
  -c:a libopus \
  -b:a 128k \
  -f webm \
  output.webm
```

**Parameter-Breakdown:**

| Parameter | Wert | Bedeutung |
|-----------|------|-----------|
| `-i input.mp4` | - | Input-Datei |
| `-c:v libvpx-vp9` | VP9 | Video-Codec (Google VP9) |
| `-crf 30` | 0-63 | Constant Rate Factor (niedriger = bessere Qualität) |
| `-b:v 0` | 0 | Disable Bitrate-Limit (CRF-Modus) |
| `-threads 8` | Auto | Anzahl CPU-Threads |
| `-speed 2` | 0-5 | Encoding-Speed/Qualität Trade-off |
| `-tile-columns 1` | 1 | Vertikal teilen für Portrait |
| `-row-mt 1` | 1 | Row-based Multi-Threading |
| `-c:a libopus` | Opus | Audio-Codec (Opus) |
| `-b:a 128k` | 64-160k | Audio-Bitrate |
| `-f webm` | webm | Force WebM Container |

---

## Algorithmen und Logik

### CRF-Berechnung (Pseudocode):

```python
def calculate_crf(video_type, input_bitrate, target_width, original_width):
    # 1. Base CRF from video type
    base_crf = {
        'screencast': 40,
        'animation': 37,
        'nature': 33,
        'action': 29,
        'film': 26
    }[video_type]

    # 2. Bitrate adjustment
    if input_bitrate < 2:
        bitrate_offset = -3
    elif input_bitrate < 5:
        bitrate_offset = 0
    elif input_bitrate < 10:
        bitrate_offset = 4
    else:
        bitrate_offset = 8

    # 3. Resolution adjustment
    if target_width >= 1400:
        resolution_offset = 2
    elif target_width >= 1000:
        resolution_offset = 3
    elif target_width >= 720:
        resolution_offset = 4
    else:
        resolution_offset = 5

    # Original resolution = no offset
    if target_width == original_width:
        resolution_offset = 0

    # Final CRF
    crf = base_crf + bitrate_offset + resolution_offset

    # Clamp to valid range
    return max(0, min(63, crf))
```

### Size-Check-Iteration (Pseudocode):

```python
def convert_with_size_check(input_file, output_file, initial_crf):
    max_crf = 50
    crf = initial_crf
    input_size = get_file_size(input_file)

    while crf <= max_crf:
        # Encode
        ffmpeg_encode(input_file, output_file, crf)
        output_size = get_file_size(output_file)

        # Check size
        if output_size <= input_size:
            print(f"✓ Success: {output_size} < {input_size}")
            return True

        # Increase CRF and retry
        print(f"⚠ WebM larger ({output_size}), increasing CRF")
        crf += 3
        delete(output_file)

    # Failed to make smaller
    print(f"✗ Cannot make smaller than MP4 (CRF 50 reached)")
    return False
```

### Bitrate-Detection (mit Fallbacks):

```bash
# Level 1: FFprobe - Video-Stream Bitrate
bitrate=$(ffprobe -v error -select_streams v:0 \
  -show_entries stream=bit_rate \
  -of default=noprint_wrappers=1:nokey=1 input.mp4)

# Level 2: FFprobe - Format Bitrate
if [ -z "$bitrate" ]; then
  bitrate=$(ffprobe -v error \
    -show_entries format=bit_rate \
    -of default=noprint_wrappers=1:nokey=1 input.mp4)
fi

# Level 3: Berechnung aus Dateigröße/Dauer
if [ -z "$bitrate" ]; then
  size=$(stat -f%z input.mp4)  # Bytes
  duration=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 input.mp4)
  bitrate=$((size * 8 / duration))
fi

# Fallback: Default 5 Mbps
bitrate=${bitrate:-5000000}
```

---

## Weitere Ressourcen

- [VP9 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/VP9)
- [Opus Audio Codec](https://opus-codec.org/)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [WebM Project](https://www.webmproject.org/)

---

**Zurück zur Hauptdokumentation:** [README.md](README.md)
