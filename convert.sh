#!/bin/bash
#
# MP4/MOV zu WebM Konverter
#
# Autor: Wolfgang Wagner, wwagner@wwagner.net
# Version: 1.6.2
#
# Beschreibung: Konvertiert MP4/MOV-Videos aus dem input/ Ordner in verschiedene WebM-Formate
# mit unterschiedlichen Auflösungen und Qualitätseinstellungen.
# Konvertierte Videos werden im output/ Ordner gespeichert.
#

# Hilfsfunktion für --help
show_help() {
    cat << EOF
MP4/MOV zu WebM Konverter v1.6.2
Autor: Wolfgang Wagner <wwagner@wwagner.net>

VERWENDUNG:
    $0 [OPTIONEN]

BESCHREIBUNG:
    Konvertiert MP4/MOV-Videos aus dem input/ Ordner in WebM-Format mit
    intelligenter CRF-Optimierung, verschiedenen Auflösungen und
    garantierter Größenreduktion.

OPTIONEN:
    -h, --help              Zeigt diese Hilfe an
    -v, --version           Zeigt die Version an
    -d, --dry-run           Testmodus ohne tatsächliche Konvertierung
    -s, --square            Erstellt zusätzlich quadratische 1:1 Version (500px)
    -t, --type <typ>        Video-Typ für optimale Kompression
                            Werte: screencast, animation, nature, action, film
                            Standard: interaktive Abfrage
    --speed <0-5>           VP9 Encoding-Geschwindigkeit
                            0=langsam/beste Qualität, 5=schnell
                            Standard: 2
    --variants <liste>      Nur bestimmte Varianten-TYPEN erstellen
                            Werte: original, 50percent, square
                            (OHNE --resolutions auch: 1400px, 1000px, 500px)
                            Beispiel: --variants "original,50percent"
    --resolutions <liste>   Custom Auflösungen (Breite in px)
                            Beispiel: --resolutions "1920,1280,720"
                            Überschreibt Standard-Auflösungen (1400,1000,500)
                            Kombinierbar mit --variants für Typ-Filter
    --verbose               Zeigt FFmpeg-Ausgabe für Debugging

VIDEO-TYPEN:
    screencast              Bildschirm-Aufnahmen, Tutorials (CRF 40, Audio 64k)
    animation               Motion Graphics, Animationen (CRF 37, Audio 96k)
    nature                  Natur, Interviews, Vlogs (CRF 33, Audio 128k)
    action                  Action, Sport, schnelle Schnitte (CRF 29, Audio 128k)
    film                    Filme, Cinematic (CRF 26, Audio 160k)

VARIANTEN-TYPEN (--variants):
    original                Original-Auflösung mit optimiertem CRF
    50percent               Original-Auflösung mit 50% Ziel-Dateigröße (Two-Pass)
    square                  Quadratische Version (Größe = kleinste Auflösung)
    1400px, 1000px, 500px   Standard-Auflösungen (nur ohne --resolutions)

AUFLÖSUNGEN (--resolutions):
    Standard: 1400, 1000, 500 (wenn nicht anders angegeben)
    Custom: Komma-separierte Liste von Breiten in Pixeln
    Beispiele: "1920,1080,720" oder "2560,1280"

BEISPIELE:
    # Standard-Konvertierung (alle Varianten)
    $0

    # Nur Original + 50% Version (keine skalierten)
    $0 --variants "original,50percent"

    # Nur skalierte Versionen in custom Größen
    $0 --resolutions "1920,1280,720"

    # Original + custom skalierte + square
    $0 --variants "original,square" --resolutions "1920,720"

    # Screencast mit schnellem Encoding, nur Original
    $0 --type screencast --speed 4 --variants "original"

    # Film mit hoher Qualität, Standard-Auflösungen
    $0 -t film --speed 1

    # Debugging mit vollständiger FFmpeg-Ausgabe
    $0 --verbose --dry-run

AUSGABE:
    Konvertierte Dateien werden in output/ gespeichert mit folgendem Schema:
    - video_original.webm
    - video_50percent.webm
    - video_1400px.webm
    - video_1000px.webm
    - video_500px.webm
    - video_500px_square.webm (mit --square)

ABHÄNGIGKEITEN:
    - FFmpeg mit libvpx-vp9 und libopus Support
    - FFprobe (Teil von FFmpeg)

WEITERE INFORMATIONEN:
    GitHub: https://github.com/yourusername/webmconverter
    Dokumentation: README.md

EOF
    exit 0
}

show_version() {
    echo "MP4/MOV zu WebM Konverter v1.6.2"
    exit 0
}

# Verzeichnisse definieren
INPUT_DIR="input"
OUTPUT_DIR="output"

# Verzeichnisse erstellen falls sie nicht existieren
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# Parameter prüfen
CREATE_SQUARE=false
VIDEO_TYPE=""
DRY_RUN=false
VP9_SPEED=2
VARIANTS=""
VERBOSE=false
CUSTOM_RESOLUTIONS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            ;;
        --version)
            show_version
            ;;
        --square|-s)
            CREATE_SQUARE=true
            shift
            ;;
        --type|-t)
            VIDEO_TYPE="$2"
            shift 2
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --speed)
            VP9_SPEED="$2"
            shift 2
            ;;
        --variants)
            VARIANTS="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --resolutions)
            CUSTOM_RESOLUTIONS="$2"
            shift 2
            ;;
        *)
            echo "❌ Unbekannter Parameter: $1"
            echo "Verwenden Sie --help für eine vollständige Liste der Optionen"
            exit 1
            ;;
    esac
done

# Validierung: FFmpeg und FFprobe verfügbar?
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FEHLER: FFmpeg ist nicht installiert!"
    echo "Installation:"
    echo "  macOS:  brew install ffmpeg"
    echo "  Linux:  sudo apt install ffmpeg"
    exit 1
fi

if ! command -v ffprobe &> /dev/null; then
    echo "❌ FEHLER: FFprobe ist nicht installiert!"
    echo "Installation:"
    echo "  macOS:  brew install ffmpeg"
    echo "  Linux:  sudo apt install ffmpeg"
    exit 1
fi

# Validierung: VP9 Speed
if [[ ! "$VP9_SPEED" =~ ^[0-5]$ ]]; then
    echo "❌ FEHLER: --speed muss zwischen 0 und 5 liegen (aktuell: $VP9_SPEED)"
    exit 1
fi

# Validierung: Video-Typ (falls angegeben)
if [[ -n "$VIDEO_TYPE" ]] && [[ ! "$VIDEO_TYPE" =~ ^(screencast|animation|nature|action|film)$ ]]; then
    echo "❌ FEHLER: Unbekannter Video-Typ '$VIDEO_TYPE'"
    echo "Erlaubt: screencast, animation, nature, action, film"
    exit 1
fi

# Validierung: Varianten (falls angegeben)
if [[ -n "$VARIANTS" ]]; then
    IFS=',' read -ra VARIANT_ARRAY <<< "$VARIANTS"
    for variant in "${VARIANT_ARRAY[@]}"; do
        # Wenn --resolutions gesetzt, keine px-Werte in --variants erlaubt
        if [[ -n "$CUSTOM_RESOLUTIONS" ]] && [[ "$variant" =~ px$ ]]; then
            echo "❌ FEHLER: Auflösungs-Varianten (z.B. '${variant}') sind nicht erlaubt wenn --resolutions gesetzt ist"
            echo "Verwenden Sie --variants nur für: original, 50percent, square"
            echo "Auflösungen werden durch --resolutions definiert: $CUSTOM_RESOLUTIONS"
            exit 1
        fi

        # Standard-Validierung
        if [[ ! "$variant" =~ ^(original|50percent|1400px|1000px|500px|square)$ ]]; then
            echo "❌ FEHLER: Unbekannte Variante '$variant'"
            echo "Erlaubt: original, 50percent, square"
            if [[ -z "$CUSTOM_RESOLUTIONS" ]]; then
                echo "         1400px, 1000px, 500px (nur ohne --resolutions)"
            fi
            exit 1
        fi
    done
fi

# Statistik-Variablen
STATS_TOTAL_VIDEOS=0
STATS_CREATED_FILES=0
STATS_SKIPPED_FILES=0
STATS_INPUT_SIZE=0
STATS_OUTPUT_SIZE=0

# Cleanup-Funktion für temporäre Dateien
cleanup_temp_files() {
    echo ""
    echo "⚠️  Aufräumen von temporären Dateien..."
    find "$OUTPUT_DIR" -name "*.tmp" -delete 2>/dev/null
    find "$OUTPUT_DIR" -name "*.best" -delete 2>/dev/null
    find "$OUTPUT_DIR" -name "*.log" -delete 2>/dev/null
    echo "✓ Temporäre Dateien entfernt"
    exit 130
}

# Trap für sauberes Beenden bei Strg+C, Fehler oder normalem Exit
trap cleanup_temp_files EXIT INT TERM

# Thread-Count dynamisch ermitteln
if command -v nproc &> /dev/null; then
    THREAD_COUNT=$(nproc)
elif command -v sysctl &> /dev/null; then
    THREAD_COUNT=$(sysctl -n hw.ncpu 2>/dev/null || echo 8)
else
    THREAD_COUNT=8
fi

# Hilfsfunktion: Prüfen ob Variante aktiviert ist
should_create_variant() {
    local variant="$1"

    # Wenn keine Varianten angegeben, alle erstellen
    if [[ -z "$VARIANTS" ]]; then
        return 0
    fi

    # Prüfen ob Variante in der Liste ist
    if [[ ",$VARIANTS," == *",$variant,"* ]]; then
        return 0
    fi

    return 1
}

if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 DRY-RUN MODUS: Es werden keine Dateien konvertiert"
    echo ""
fi

echo "⚙️  VP9 Speed: $VP9_SPEED (0=langsam/beste Qualität, 5=schnell)"
echo "⚙️  Thread-Count: $THREAD_COUNT"

if [[ -n "$VARIANTS" ]]; then
    echo "⚙️  Aktive Varianten: $VARIANTS"
fi

if [[ "$CREATE_SQUARE" == true ]]; then
    echo "⚙️  Quadratische 1:1 Version wird erstellt..."
fi
echo ""

# Video-Typ abfragen wenn nicht als Parameter übergeben
if [[ -z "$VIDEO_TYPE" ]]; then
    echo ""
    echo "Welche Art von Video möchten Sie konvertieren?"
    echo ""
    echo "  1) Screencast/Tutorial (wenig Bewegung, klare Kanten)"
    echo "  2) Animation/Motion Graphics (künstliche Bewegung)"
    echo "  3) Natur/Interview/Vlog (moderate Bewegung)"
    echo "  4) Action/Sport/Schnelle Schnitte (viel Bewegung)"
    echo "  5) Film/Cinematic (hohe Qualität erwünscht)"
    echo ""
    read -p "Bitte wählen Sie (1-5): " choice
    echo ""

    case $choice in
        1)
            VIDEO_TYPE="screencast"
            ;;
        2)
            VIDEO_TYPE="animation"
            ;;
        3)
            VIDEO_TYPE="nature"
            ;;
        4)
            VIDEO_TYPE="action"
            ;;
        5)
            VIDEO_TYPE="film"
            ;;
        *)
            echo "Ungültige Auswahl. Verwende Standard-Einstellungen (Natur/Interview)."
            VIDEO_TYPE="nature"
            ;;
    esac
fi

# Video-Typ anzeigen
case $VIDEO_TYPE in
    screencast)
        echo "→ Video-Typ: Screencast/Tutorial (aggressive Kompression)"
        ;;
    animation)
        echo "→ Video-Typ: Animation/Motion Graphics (starke Kompression)"
        ;;
    nature)
        echo "→ Video-Typ: Natur/Interview/Vlog (ausgewogene Kompression)"
        ;;
    action)
        echo "→ Video-Typ: Action/Sport (vorsichtige Kompression)"
        ;;
    film)
        echo "→ Video-Typ: Film/Cinematic (minimale Kompression)"
        ;;
    *)
        echo "→ Unbekannter Video-Typ '$VIDEO_TYPE', verwende Standard-Einstellungen"
        VIDEO_TYPE="nature"
        ;;
esac
echo ""

# Prüfen ob MP4/MOV-Dateien im input-Ordner vorhanden sind
mp4_count=$(ls "$INPUT_DIR"/*.mp4 2>/dev/null | wc -l | xargs)
mov_count=$(ls "$INPUT_DIR"/*.mov 2>/dev/null | wc -l | xargs)
total_count=$((mp4_count + mov_count))

if [[ $total_count -eq 0 ]]; then
    echo "Keine MP4/MOV-Dateien im $INPUT_DIR Ordner gefunden!"
    exit 1
fi

# Hilfsfunktion: FFmpeg ausführen
run_ffmpeg() {
    local input_file="$1"
    local output_file="$2"
    local scale_filter="$3"
    local crf="$4"
    local audio_bitrate="$5"

    # FFmpeg Output-Redirect basierend auf --verbose
    local redirect_output=""
    if [[ "$VERBOSE" == false ]]; then
        redirect_output="> /dev/null 2>&1"
    fi

    if [[ -n "$scale_filter" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" -vf "$scale_filter" \
                -c:v libvpx-vp9 -b:v 0 -crf "$crf" \
                -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a "$audio_bitrate" \
                -f webm "$output_file"
        else
            ffmpeg -y -i "$input_file" -vf "$scale_filter" \
                -c:v libvpx-vp9 -b:v 0 -crf "$crf" \
                -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a "$audio_bitrate" \
                -f webm "$output_file" > /dev/null 2>&1
        fi
    else
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" \
                -c:v libvpx-vp9 -b:v 0 -crf "$crf" \
                -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a "$audio_bitrate" \
                -f webm "$output_file"
        else
            ffmpeg -y -i "$input_file" \
                -c:v libvpx-vp9 -b:v 0 -crf "$crf" \
                -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 \
                -c:a libopus -b:a "$audio_bitrate" \
                -f webm "$output_file" > /dev/null 2>&1
        fi
    fi

    return $?
}

# Funktion für optimierte VP9-Kodierung mit Dateigröße-Kontrolle
convert_with_size_check() {
    local input_file="$1"
    local output_file="$2"
    local scale_filter="$3"
    local target_crf="$4"
    local variant_name="$5"
    local audio_bitrate="${6:-128k}"  # Default 128k wenn nicht angegeben

    # Dry-run Check
    if [[ "$DRY_RUN" == true ]]; then
        echo "    [DRY-RUN] Würde erstellen: $output_file (CRF $target_crf, Audio $audio_bitrate)"
        return 0
    fi

    # Erste Kodierung mit Standard-CRF
    local temp_output="${output_file}.tmp"

    run_ffmpeg "$input_file" "$temp_output" "$scale_filter" "$target_crf" "$audio_bitrate"
    local ffmpeg_success=$?

    # Prüfen ob FFmpeg erfolgreich war
    if [[ $ffmpeg_success -ne 0 || ! -f "$temp_output" ]]; then
        echo "    ✗ Fehler bei der Kodierung!"
        [[ -f "$temp_output" ]] && rm "$temp_output"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi

    # Dateigröße vergleichen
    local input_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    local output_size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)

    # Iterativ CRF erhöhen bis WebM kleiner als MP4 ist
    local current_crf=$target_crf
    local max_crf=50
    local attempt=1

    while [[ $output_size -gt $input_size && $current_crf -le $max_crf ]]; do
        if [[ $attempt -gt 1 ]]; then
            rm "$temp_output"
        fi

        current_crf=$((current_crf + 3))
        echo "    ⚠ WebM größer als Original ($output_size > $input_size Bytes), Versuch $attempt mit CRF $current_crf"

        run_ffmpeg "$input_file" "$temp_output" "$scale_filter" "$current_crf" "$audio_bitrate"
        if [[ $? -ne 0 || ! -f "$temp_output" ]]; then
            echo "    ✗ Fehler bei der Kodierung mit CRF $current_crf!"
            STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
            return 1
        fi

        output_size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
        attempt=$((attempt + 1))
    done

    # Prüfen ob WebM jetzt kleiner ist
    if [[ $output_size -le $input_size ]]; then
        if ! mv "$temp_output" "$output_file"; then
            echo "    ✗ Fehler beim Verschieben der Datei!"
            rm -f "$temp_output"
            STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
            return 1
        fi
        echo "    ✓ Optimale Größe erreicht: $output_size Bytes ($(( (output_size * 100) / input_size ))% des Originals, CRF $current_crf)"
        STATS_CREATED_FILES=$((STATS_CREATED_FILES + 1))
        STATS_OUTPUT_SIZE=$((STATS_OUTPUT_SIZE + output_size))
    else
        # WebM konnte nicht kleiner gemacht werden
        rm "$temp_output"
        echo "    ⚠ WebM-Konvertierung übersprungen (auch mit CRF $current_crf noch $output_size > $input_size Bytes)"
        echo "    → Original MP4 bleibt die beste Option für diese Datei"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi
}

# Funktion für 50%-Ziel-Dateigröße mit Two-Pass Encoding
convert_to_50_percent() {
    local input_file="$1"
    local output_file="$2"
    local scale_filter="$3"
    local video_type="$4"
    local audio_bitrate="${5:-128k}"

    # Dry-run Check
    if [[ "$DRY_RUN" == true ]]; then
        echo "    [DRY-RUN] Würde erstellen: $output_file (50% Zielgröße, Two-Pass, Typ: $video_type, Audio: $audio_bitrate)"
        return 0
    fi

    # Eingabedateigröße ermitteln
    local input_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    local target_size=$(( input_size / 2 ))

    echo "    → Ziel: 50% der Original-Größe ($target_size Bytes, Two-Pass)"

    # Video-Dauer ermitteln für Bitrate-Berechnung
    local duration=$(ffprobe -v quiet -show_entries format=duration -of csv=s=x:p=0 "$input_file")
    if [[ -z "$duration" || "$duration" == "N/A" ]]; then
        echo "    ✗ Kann Video-Dauer nicht ermitteln!"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi

    # Audio-Bitrate in kbps extrahieren (z.B. "128k" → 128)
    local audio_kbps=${audio_bitrate%k}

    # Ziel-Bitrate berechnen (in kbps)
    # target_size (bytes) * 8 (bits) / duration (s) / 1000 (kbps) - audio_bitrate
    local target_bitrate_kbps=$(awk "BEGIN {print int(($target_size * 8 / $duration / 1000) - $audio_kbps)}")

    # Mindest-Bitrate 100 kbps
    if [[ $target_bitrate_kbps -lt 100 ]]; then
        target_bitrate_kbps=100
    fi

    echo "    → Berechnete Video-Bitrate: ${target_bitrate_kbps}k"

    # Temporäre Dateien
    local temp_output="${output_file}.tmp"
    local log_file="${output_file}.log"

    # Two-Pass Encoding
    # Pass 1: Analyse
    echo "    → Pass 1/2: Analysiere Video..."

    if [[ -n "$scale_filter" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" -vf "$scale_filter" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 1 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed 4 -tile-columns 1 -row-mt 1 -an -f webm /dev/null
        else
            ffmpeg -y -i "$input_file" -vf "$scale_filter" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 1 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed 4 -tile-columns 1 -row-mt 1 -an -f webm /dev/null > /dev/null 2>&1
        fi
    else
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 1 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed 4 -tile-columns 1 -row-mt 1 -an -f webm /dev/null
        else
            ffmpeg -y -i "$input_file" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 1 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed 4 -tile-columns 1 -row-mt 1 -an -f webm /dev/null > /dev/null 2>&1
        fi
    fi

    if [[ $? -ne 0 ]]; then
        echo "    ✗ Fehler bei Pass 1!"
        rm -f "${log_file}"*
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi

    # Pass 2: Finale Kodierung
    echo "    → Pass 2/2: Erstelle finale Datei..."

    if [[ -n "$scale_filter" ]]; then
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" -vf "$scale_filter" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 2 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 -c:a libopus -b:a "$audio_bitrate" -f webm "$temp_output"
        else
            ffmpeg -y -i "$input_file" -vf "$scale_filter" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 2 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 -c:a libopus -b:a "$audio_bitrate" -f webm "$temp_output" > /dev/null 2>&1
        fi
    else
        if [[ "$VERBOSE" == true ]]; then
            ffmpeg -y -i "$input_file" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 2 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 -c:a libopus -b:a "$audio_bitrate" -f webm "$temp_output"
        else
            ffmpeg -y -i "$input_file" -c:v libvpx-vp9 -b:v ${target_bitrate_kbps}k -pass 2 -passlogfile "$log_file" -threads "$THREAD_COUNT" -speed "$VP9_SPEED" -tile-columns 1 -row-mt 1 -c:a libopus -b:a "$audio_bitrate" -f webm "$temp_output" > /dev/null 2>&1
        fi
    fi

    if [[ $? -ne 0 || ! -f "$temp_output" ]]; then
        echo "    ✗ Fehler bei Pass 2!"
        rm -f "${log_file}"* "$temp_output"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi

    # Cleanup Log-Dateien
    rm -f "${log_file}"*

    # Dateigröße prüfen
    local final_size=$(stat -f%z "$temp_output" 2>/dev/null || stat -c%s "$temp_output" 2>/dev/null)
    local final_percent=$(( (final_size * 100) / input_size ))

    if ! mv "$temp_output" "$output_file"; then
        echo "    ✗ Fehler beim Verschieben der Datei!"
        rm -f "$temp_output"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        return 1
    fi

    echo "    ✓ Größe erreicht: $final_size Bytes (${final_percent}% des Originals, ${target_bitrate_kbps}k)"
    STATS_CREATED_FILES=$((STATS_CREATED_FILES + 1))
    STATS_OUTPUT_SIZE=$((STATS_OUTPUT_SIZE + final_size))
    return 0
}

# Video-Anzahl ermitteln für Progress-Anzeige
total_videos=$( (ls "$INPUT_DIR"/*.mp4 2>/dev/null; ls "$INPUT_DIR"/*.mov 2>/dev/null) | wc -l | xargs)
current_video=0

for file in "$INPUT_DIR"/*.mp4 "$INPUT_DIR"/*.mov; do
    # Überspringe nicht existierende Dateien (falls nur eines der Formate vorhanden)
    [[ ! -f "$file" ]] && continue
    # Dateiname ohne Pfad und Erweiterung extrahieren
    basename_file=$(basename "$file")
    name="${basename_file%.*}"
    current_video=$((current_video + 1))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Video $current_video/$total_videos: $basename_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Prüfen ob Video-Stream vorhanden ist
    video_stream_count=$(ffprobe -v quiet -select_streams v -show_entries stream=codec_type -of csv=s=x:p=0 "$file" | wc -l | xargs)

    if [[ $video_stream_count -eq 0 ]]; then
        echo "  ⚠ Keine Video-Spur gefunden (Audio-only?) - Überspringe"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        continue
    fi

    # Video-Breite ermitteln
    video_width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$file")
    if [[ -z "$video_width" || "$video_width" == "N/A" || "$video_width" == "0" ]]; then
        echo "  ⚠ Kann Video-Breite nicht ermitteln - Überspringe"
        STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
        continue
    fi

    # Bitrate ermitteln mit mehreren Fallbacks
    video_bitrate=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=bit_rate -of csv=s=x:p=0 "$file")

    # Fallback 1: Gesamt-Bitrate verwenden
    if [[ -z "$video_bitrate" || "$video_bitrate" == "N/A" || "$video_bitrate" == "0" ]]; then
        video_bitrate=$(ffprobe -v quiet -show_entries format=bit_rate -of csv=s=x:p=0 "$file")
    fi

    # Fallback 2: Aus Dateigröße und Dauer schätzen
    if [[ -z "$video_bitrate" || "$video_bitrate" == "N/A" || "$video_bitrate" == "0" ]]; then
        file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        duration=$(ffprobe -v quiet -show_entries format=duration -of csv=s=x:p=0 "$file")
        if [[ -n "$duration" && "$duration" != "N/A" && "$duration" != "0" ]]; then
            # Bitrate = (file_size * 8) / duration
            video_bitrate=$(awk "BEGIN {print int(($file_size * 8) / $duration)}")
        fi
    fi

    # Wenn immer noch keine Bitrate, Default verwenden
    if [[ -z "$video_bitrate" || "$video_bitrate" == "N/A" || "$video_bitrate" == "0" ]]; then
        video_bitrate=5000000  # Default: 5 Mbps
        echo "  → Original-Breite: ${video_width}px"
        echo "  → Original-Bitrate: Unbekannt (verwende Default 5 Mbps)"
    else
        echo "  → Original-Breite: ${video_width}px"
        echo "  → Original-Bitrate: ${video_bitrate} bps"
    fi

    # Audio-Bitrate basierend auf Video-Typ festlegen
    audio_bitrate="128k"
    case $VIDEO_TYPE in
        screencast)
            audio_bitrate="64k"  # Screencasts brauchen weniger Audio-Qualität
            ;;
        animation)
            audio_bitrate="96k"  # Animationen haben oft Musik/Effekte
            ;;
        nature)
            audio_bitrate="128k"  # Standard
            ;;
        action)
            audio_bitrate="128k"  # Action hat oft komplexe Soundtracks
            ;;
        film)
            audio_bitrate="160k"  # Filme brauchen beste Audio-Qualität
            ;;
    esac
    echo "  → Audio-Bitrate: $audio_bitrate"

    # Basis-CRF-Wert basierend auf Video-Typ wählen
    base_crf=30
    case $VIDEO_TYPE in
        screencast)
            base_crf=40  # Screencasts komprimieren sehr gut
            ;;
        animation)
            base_crf=37  # Animationen komprimieren gut
            ;;
        nature)
            base_crf=33  # Standard für moderate Bewegung
            ;;
        action)
            base_crf=29  # Action braucht mehr Bits
            ;;
        film)
            base_crf=26  # Höchste Qualität für Filme
            ;;
    esac

    # CRF-Wert basierend auf Bitrate anpassen
    # Die Bitrate gibt Hinweise auf die ursprüngliche Qualität
    optimal_crf=$base_crf
    if [[ -n "$video_bitrate" && "$video_bitrate" != "N/A" ]]; then
        bitrate_mbps=$(( video_bitrate / 1000000 ))

        if [[ $video_bitrate -lt 2000000 ]]; then
            # Sehr niedrige Bitrate: CRF um 3-5 senken (bessere Qualität erhalten)
            optimal_crf=$(( base_crf - 4 ))
            echo "  → Niedrige Bitrate (${bitrate_mbps} Mbps) erkannt"
        elif [[ $video_bitrate -lt 5000000 ]]; then
            # Mittlere Bitrate: CRF um 1-2 senken
            optimal_crf=$(( base_crf - 2 ))
            echo "  → Mittlere Bitrate (${bitrate_mbps} Mbps) erkannt"
        elif [[ $video_bitrate -lt 10000000 ]]; then
            # Hohe Bitrate: Basis-CRF verwenden
            optimal_crf=$base_crf
            echo "  → Hohe Bitrate (${bitrate_mbps} Mbps) erkannt"
        else
            # Sehr hohe Bitrate: CRF um 2-3 erhöhen (mehr Kompression möglich)
            optimal_crf=$(( base_crf + 3 ))
            echo "  → Sehr hohe Bitrate (${bitrate_mbps} Mbps) erkannt"
        fi
    else
        echo "  → Bitrate nicht erkennbar"
    fi

    # Mindest-CRF 23, Maximum 50
    if [[ $optimal_crf -lt 23 ]]; then
        optimal_crf=23
    elif [[ $optimal_crf -gt 50 ]]; then
        optimal_crf=50
    fi

    echo "  → Gewählter Start-CRF: $optimal_crf (Typ: $VIDEO_TYPE)"

    # Dateigröße des Input-MP4 ermitteln
    input_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)

    # Input-Größe zur Statistik (VOR der Konvertierung)
    STATS_INPUT_SIZE=$((STATS_INPUT_SIZE + input_size))
    STATS_TOTAL_VIDEOS=$((STATS_TOTAL_VIDEOS + 1))

    # Original und 50% Versionen nur erstellen wenn KEINE custom resolutions angegeben
    if [[ -z "$CUSTOM_RESOLUTIONS" ]]; then
        # Original mit optimalem CRF
        if should_create_variant "original"; then
            echo "  → Erstelle Original-Version..."
            convert_with_size_check "$file" "$OUTPUT_DIR/${name}_original.webm" "" "$optimal_crf" "original" "$audio_bitrate"
        fi

        # Größe der Original-WebM ermitteln (nur wenn nicht dry-run)
        original_webm_size=0
        if [[ "$DRY_RUN" == false && -f "$OUTPUT_DIR/${name}_original.webm" ]]; then
            original_webm_size=$(stat -f%z "$OUTPUT_DIR/${name}_original.webm" 2>/dev/null || stat -c%s "$OUTPUT_DIR/${name}_original.webm" 2>/dev/null)
        fi

        # 50%-Version nur erstellen wenn Original-WebM größer als 50% des MP4 ist
        if should_create_variant "50percent"; then
            target_50_percent=$(( input_size / 2 ))
            if [[ "$DRY_RUN" == true ]] || [[ $original_webm_size -gt $target_50_percent ]] || [[ $original_webm_size -eq 0 ]]; then
                echo "  → Erstelle 50%-Version (Originalauflösung)..."
                convert_to_50_percent "$file" "$OUTPUT_DIR/${name}_50percent.webm" "" "$VIDEO_TYPE" "$audio_bitrate"
            else
                percent=$(( (original_webm_size * 100) / input_size ))
                echo "  → Überspringe 50%-Version (Original-WebM ist bereits ${percent}% vom MP4)"
                STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
            fi
        fi
    fi

    # Auflösungen bestimmen: Custom oder Standard
    resolutions_to_process=()
    if [[ -n "$CUSTOM_RESOLUTIONS" ]]; then
        # Custom Auflösungen verwenden
        IFS=',' read -ra resolutions_to_process <<< "$CUSTOM_RESOLUTIONS"
        echo "  → Custom Auflösungen: ${CUSTOM_RESOLUTIONS}"
    else
        # Standard-Auflösungen
        resolutions_to_process=(1400 1000 500)
    fi

    # Skalierte Versionen erstellen
    for resolution in "${resolutions_to_process[@]}"; do
        # CRF-Anpassung basierend auf Auflösung
        # Je kleiner die Auflösung, desto höher der CRF
        size_factor=0
        if [[ $resolution -ge 1400 ]]; then
            size_factor=2
        elif [[ $resolution -ge 1000 ]]; then
            size_factor=3
        elif [[ $resolution -ge 720 ]]; then
            size_factor=4
        else
            size_factor=5
        fi

        crf_scaled=$(( optimal_crf + size_factor ))
        [[ $crf_scaled -gt 50 ]] && crf_scaled=50

        # Entscheiden ob diese Auflösung erstellt werden soll
        should_create=false
        variant_name="${resolution}px"

        if [[ -n "$CUSTOM_RESOLUTIONS" ]]; then
            # Custom Resolutions sind gesetzt
            if [[ -z "$VARIANTS" ]]; then
                # Keine --variants → alle custom resolutions erstellen
                should_create=true
            else
                # --variants ist gesetzt → NUR erstellen wenn KEINE Typ-Filter vorhanden
                # D.h. nur erstellen wenn --variants ausschließlich px-Werte hatte (was jetzt verboten ist)
                # Also: NICHT erstellen, weil --variants nur für Typ-Filter verwendet wird
                should_create=false
            fi
        else
            # Standard-Auflösungen (1400, 1000, 500)
            if should_create_variant "$variant_name"; then
                should_create=true
            fi
        fi

        if [[ "$should_create" == true ]]; then
            if [[ $video_width -gt $resolution ]]; then
                echo "  → Erstelle ${resolution}px-Version..."
                convert_with_size_check "$file" "$OUTPUT_DIR/${name}_${resolution}px.webm" "scale=${resolution}:-1" "$crf_scaled" "${resolution}px" "$audio_bitrate"
            else
                echo "  → Überspringe ${resolution}px-Version (Original ist nur ${video_width}px breit)"
                STATS_SKIPPED_FILES=$((STATS_SKIPPED_FILES + 1))
            fi
        fi
    done

    # Optionale quadratische 1:1 Version
    # Nur erstellen wenn explizit gewünscht via --square ODER --variants square
    # Größe: kleinste Auflösung oder 500px als Fallback
    if [[ "$CREATE_SQUARE" == true ]] || [[ -n "$VARIANTS" ]] && should_create_variant "square"; then
        square_size=500
        if [[ -n "$CUSTOM_RESOLUTIONS" ]] && [[ ${#resolutions_to_process[@]} -gt 0 ]]; then
            # Kleinste custom Auflösung verwenden (letztes Element)
            square_size="${resolutions_to_process[${#resolutions_to_process[@]}-1]}"
        fi

        crf_square=$(( optimal_crf + 5 ))
        [[ $crf_square -gt 50 ]] && crf_square=50

        echo "  → Erstelle ${square_size}x${square_size}px quadratische Version (1:1)..."
        convert_with_size_check "$file" "$OUTPUT_DIR/${name}_${square_size}px_square.webm" "scale=${square_size}:${square_size}:force_original_aspect_ratio=increase,crop=${square_size}:${square_size}" "$crf_square" "${square_size}px_square" "$audio_bitrate"
    fi

    echo "  ✓ $basename_file abgeschlossen"
done

# Finale Statistik anzeigen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 ZUSAMMENFASSUNG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Videos verarbeitet:    $STATS_TOTAL_VIDEOS"
echo "Dateien erstellt:      $STATS_CREATED_FILES"
echo "Dateien übersprungen:  $STATS_SKIPPED_FILES"
echo ""

if [[ "$DRY_RUN" == false && $STATS_CREATED_FILES -gt 0 && $STATS_INPUT_SIZE -gt 0 ]]; then
    # Größen in MB umrechnen
    input_mb=$(awk "BEGIN {printf \"%.2f\", $STATS_INPUT_SIZE / 1024 / 1024}")
    output_mb=$(awk "BEGIN {printf \"%.2f\", $STATS_OUTPUT_SIZE / 1024 / 1024}")
    saved_mb=$(awk "BEGIN {printf \"%.2f\", ($STATS_INPUT_SIZE - $STATS_OUTPUT_SIZE) / 1024 / 1024}")
    compression_percent=$(awk "BEGIN {printf \"%.1f\", (1 - $STATS_OUTPUT_SIZE / $STATS_INPUT_SIZE) * 100}")

    echo "Eingabe-Größe:         ${input_mb} MB"
    echo "Ausgabe-Größe:         ${output_mb} MB"
    echo "Ersparnis:             ${saved_mb} MB (${compression_percent}%)"
    echo ""
fi

echo "✅ Alle Konvertierungen abgeschlossen!"
echo ""
