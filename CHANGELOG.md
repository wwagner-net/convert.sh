# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/).

## [1.6.1] - 2025-10-08

### Fixed
- Array subscript error bei `--variants square --resolutions "500"`

### Changed
- **Custom Resolutions Logik**: `--resolutions` unterdrückt original/50percent Varianten für intuitiveren Workflow

## [1.6.0] - 2025-10-01

### Added
- Video-Type-basierte CRF-Optimierung (screencast, animation, nature, action, film)
- 50% File Size Variante mit Two-Pass Encoding
- Bitrate-Detection mit 3-Level-Fallback für intelligente CRF-Auswahl
- `--help` und `--version` Parameter
- `--type` Parameter für Video-Typ Auswahl
- `--speed` Parameter für VP9 Encoding-Speed (0-5)
- `--variants` Parameter zur Auswahl von Varianten (original, 50percent, square)
- `--resolutions` Parameter für Custom-Resolutions
- `--dry-run` Simulation Mode
- `--verbose` für detaillierte FFmpeg-Ausgabe
- Dynamische Thread-Erkennung (nproc/sysctl)
- Cleanup-Trap für EXIT/INT/TERM Signale
- Audio-Only File Detection und Skip
- Statistik-System mit Zusammenfassung

### Changed
- Refactoring: `run_ffmpeg()` Helper-Funktion

### Fixed
- Division by Zero in Statistik
- Robuste Video-Width Validierung
- Parameter-Validierung und Konflikt-Prävention

## [1.5.0]

### Added
- Interaktive Video-Type Abfrage
- Type-spezifische Audio-Bitrates

## [1.4.0]

### Added
- Bitrate-basierte CRF-Anpassung
- Robuste Bitrate-Detection mit Fallbacks

## [1.3.0] - 2025-08-21

### Added
- Automatische Dateigröße-Kontrolle
- Intelligente Upscaling-Vermeidung
- Adaptive CRF-Anpassung
- Optimierte VP9-Einstellungen

## [1.2.0]

### Added
- Input/Output Directory-Struktur
- Intelligente Auflösungs-Erkennung

## [1.0.0]

### Added
- Initiales Release
- Standard-Resolutions (1400px, 1000px, 500px)
- Square-Variante
