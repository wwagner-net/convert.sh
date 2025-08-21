# WebM Converter - Identifizierte Probleme

## Kritische Probleme (Script könnte crashen)

### 1. Fehlende `video_width` Validierung (Zeile 146)
**Problem:**
```bash
video_width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$file")
```

**Risiken:**
- `ffprobe` könnte fehlschlagen → `video_width` ist leer
- Video hat keinen Video-Stream → Crash bei numerischen Vergleichen `[[ $video_width -gt 1400 ]]`
- Korrupte Datei → unvorhersagbares Verhalten

**Lösung:**
- Validierung ob `video_width` numerisch und > 0 ist
- Fallback-Verhalten bei ungültigen Werten
- Fehlerbehandlung für `ffprobe` Failures

### 2. Division durch 0 Problem (Zeile 129)
**Problem:**
```bash
echo "... ($(( (output_size * 100) / input_size ))% des Originals...)"
```

**Risiko:**
- Crash wenn `input_size` = 0 (leere oder korrupte Dateien)

**Lösung:**
- Prüfung `if [[ $input_size -gt 0 ]]` vor Division
- Fallback-Anzeige bei ungültigen Größen

### 3. Keine Behandlung korrupter Video-Dateien
**Problem:**
- Script versucht korrupte .mp4 Dateien zu verarbeiten
- Führt zu kryptischen Fehlern und hängenden Prozessen

**Lösung:**
- Validierung mit `ffprobe` vor Verarbeitung
- Skip korrupter Dateien mit informativer Meldung

## Hohe Probleme (Performance/Stabilität)

### 4. Hardcodierte Thread-Anzahl (Zeile 51, 95, 105)
**Problem:**
```bash
-threads 8
```

**Risiken:**
- Überlastet schwächere Systeme (z.B. 4-Core CPUs)
- Unternutzt starke Systeme (z.B. 16+ Core CPUs)
- Kann System unresponsive machen

**Lösung:**
- Dynamische Thread-Erkennung: `nproc` (Linux) / `sysctl -n hw.ncpu` (macOS)
- Konfigurierbare Thread-Anzahl als Parameter
- Sane Defaults (z.B. max 75% der verfügbaren Cores)

### 5. Race Conditions bei parallelen Ausführungen
**Problem:**
- Mehrere Script-Instanzen können gleichzeitig laufen
- Temp-Dateien `${output_file}.tmp` könnten sich überschreiben
- Kein Locking-Mechanismus

**Risiken:**
- Korrupte Output-Dateien
- Unvollständige Konvertierungen
- Resource-Konflikte

**Lösung:**
- PID-basierte Temp-Dateinamen: `${output_file}.tmp.$$`
- Lock-File Mechanismus für Input-Directory
- Prüfung auf bereits laufende Instanzen

### 6. Fehlende Disk Space Checks
**Problem:**
- Keine Prüfung ob genug Speicherplatz vorhanden
- WebM-Dateien können während Konvertierung sehr groß werden
- Temp-Dateien könnten Festplatte füllen

**Risiken:**
- "No space left on device" Errors
- System-Instabilität
- Unvollständige Konvertierungen

**Lösung:**
- Verfügbaren Speicherplatz prüfen vor Konvertierung
- Mindest-Freiraum-Requirements (z.B. 2x Input-Dateigröße)
- Cleanup bei Speicherplatz-Problemen

### 7. Ineffiziente CRF-Steigerung
**Problem:**
- Erhöht immer um +3, unabhängig von Größenunterschied
- Keine Berücksichtigung wie viel kleiner das WebM werden muss
- Kann zu überoptimierter Kompression führen

**Performance-Impact:**
- Unnötige Re-Encodings
- Längere Verarbeitungszeit
- Möglicherweise schlechtere Qualität als nötig

**Lösung:**
- Adaptive CRF-Steigerung basierend auf Größenverhältnis
- Kleinere Inkremente (z.B. +1 oder +2) für feinere Kontrolle
- Intelligentere Ziel-CRF-Berechnung

## Erstellungsdatum
2025-08-21

## Status
Identifiziert - nicht behoben