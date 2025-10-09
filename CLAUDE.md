# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WebM Converter utility by Wolfgang Wagner - an intelligent Bash script that converts MP4/MOV videos to WebM format with automatic size optimization. The project focuses on creating optimized WebM videos that are guaranteed to be smaller than the original MP4/MOV, with intelligent video-type-based encoding and flexible resolution handling.

## Architecture

**Single-script architecture**: The entire functionality is contained in `convert.sh` - a standalone Bash script that processes MP4/MOV files from an input directory and outputs to a separate directory.

**Core functionality (Version 1.6.2)**:
- Reads all `.mp4` and `.mov` files from the `input/` directory
- Outputs converted files to the `output/` directory
- Automatically creates `input/` and `output/` directories if they don't exist
- **Intelligent resolution handling**: Only creates versions smaller than original (prevents upscaling)
- **Automatic file size control**: Guarantees WebM files ≤ MP4/MOV size through adaptive CRF adjustment
- **Video-type optimization**: CRF and audio bitrate based on content type (screencast, animation, nature, action, film)
- **Flexible resolutions**: Custom resolutions via `--resolutions` or standard (1400px, 1000px, 500px)
- **50% target size variant**: Two-pass encoding for precise 50% file size reduction
- **Optional square variant**: Dynamic size based on smallest resolution
- Uses optimized VP9 video codec and Opus audio codec
- **Adaptive CRF values**: Automatically increased until WebM < MP4/MOV or max CRF 50 reached
- **Dynamic thread count**: Automatically detects CPU cores
- **Robust error handling**: Audio-only detection, bitrate fallbacks, cleanup on exit

## Usage Commands

**Standard conversion (interactive)**:
```bash
bash ./convert.sh
```

**With video type**:
```bash
bash ./convert.sh --type screencast
bash ./convert.sh -t film
```

**Custom resolutions**:
```bash
bash ./convert.sh --resolutions "1920,1280,720"
```

**Selective variants**:
```bash
bash ./convert.sh --variants "original,50percent"
bash ./convert.sh --variants "original,square" --resolutions "1920,720"
```

**Advanced options**:
```bash
bash ./convert.sh --type film --speed 1 --verbose
bash ./convert.sh --dry-run --resolutions "1920,720"
bash ./convert.sh --help
```

## File Structure

```
webmconverter/
├── convert.sh          # Main conversion script
├── README.md          # Comprehensive German documentation
├── CLAUDE.md          # This file
├── .gitignore         # Excludes video files and IDE files
├── input/             # Directory for source MP4/MOV files
└── output/            # Directory for converted WebM files
```

## Dependencies

- **FFmpeg** - Required for video conversion
  - macOS: `brew install ffmpeg`
  - Linux: `sudo apt install ffmpeg`
- **Bash** - Script runtime (Linux/macOS/WSL)

## Parameters

### Required
None - script runs interactively if no parameters provided

### Optional
- `--help, -h` - Show comprehensive help
- `--version` - Show version number
- `--type, -t <type>` - Video type: screencast, animation, nature, action, film
- `--speed <0-5>` - VP9 encoding speed (0=slow/best, 5=fast, default: 2)
- `--variants <list>` - Variant types to create: original, 50percent, square (or 1400px, 1000px, 500px without --resolutions)
- `--resolutions <list>` - Custom resolutions in pixels (e.g., "1920,1280,720")
- `--square, -s` - Create square variant
- `--dry-run, -d` - Test mode without actual conversion
- `--verbose` - Show full FFmpeg output for debugging

## Directory Structure & Output

**Input**: Place MP4/MOV files in `input/` directory
**Output**: WebM files are created in `output/` directory

For input file `input/example.mp4` or `input/example.mov`, the script generates in `output/` (depending on parameters):
- `example_original.webm` - Original resolution
- `example_50percent.webm` - 50% file size (two-pass)
- `example_1400px.webm` - 1400px width (or custom)
- `example_1000px.webm` - 1000px width (or custom)
- `example_500px.webm` - 500px width (or custom)
- `example_500px_square.webm` - Square variant (with --square)

## Quality Settings (Version 1.6.0)

### Video-Type-Based CRF System
Base CRF values depend on video content type:
- **Screencast**: CRF 40 (aggressive compression, Audio 64k)
- **Animation**: CRF 37 (strong compression, Audio 96k)
- **Nature/Interview**: CRF 33 (balanced, Audio 128k)
- **Action/Sport**: CRF 29 (careful compression, Audio 128k)
- **Film/Cinematic**: CRF 26 (minimal compression, Audio 160k)

### Bitrate-Based Adjustments
Further CRF adjustments based on input video bitrate:
- **< 2 Mbps**: CRF -4 (preserve quality)
- **2-5 Mbps**: CRF -2
- **5-10 Mbps**: Base CRF
- **> 10 Mbps**: CRF +3 (more compression possible)

### Resolution-Based CRF
Scaled versions get higher CRF:
- **≥ 1400px**: Base CRF +2
- **≥ 1000px**: Base CRF +3
- **≥ 720px**: Base CRF +4
- **< 720px**: Base CRF +5

### Technical Optimizations
- **VP9 codec** with dynamic parameters:
  - `threads`: Auto-detected CPU cores
  - `speed`: Configurable 0-5 (default 2)
  - `tile-columns 1`: Optimized for portrait videos
  - `row-mt 1`: Enhanced multi-threading
- **Opus audio**: Dynamic bitrate based on video type (64k-160k)
- **Two-pass encoding**: Used for 50% variant for precise size control

### Intelligent Size Control
The `convert_with_size_check()` function implements iterative optimization:
1. Initial encoding with optimized CRF value
2. File size comparison with original MP4/MOV
3. Automatic CRF increment (+3) if WebM larger than MP4/MOV
4. Repeat until WebM ≤ MP4/MOV or maximum CRF 50 reached
5. Skip conversion if WebM cannot be made smaller than MP4/MOV

### 50% Variant (Two-Pass)
The `convert_to_50_percent()` function uses two-pass encoding:
1. Calculate target bitrate from file size and duration
2. Pass 1: Analyze video (speed 4 for faster analysis)
3. Pass 2: Final encoding with calculated bitrate
4. Achieves ~50% file size with better quality than CRF-based approach

## Development Notes

- No package.json or build system - pure Bash script
- No tests - functional script for direct execution
- Git ignores all video files (*.mp4, *.mov, *.webm) to keep repository clean
- Script validates FFmpeg/FFprobe installation
- Script validates all input parameters
- Audio-only files are detected and skipped
- Robust bitrate detection with multiple fallbacks
- Cleanup of temporary files on EXIT/INT/TERM
- Documentation is primarily in German (README.md)

## Version History

- **Version 1.6.2** (Current):
  - Added support for `.mov` files in addition to `.mp4`
  - Updated file detection to handle both formats
  - Improved error handling for mixed format directories

- **Version 1.6.1**:
  - Fixed array subscript error with `--variants square --resolutions "500"`
  - `--resolutions` now suppresses original/50percent variants for cleaner workflow

- **Version 1.6.0**:
  - Added `--help` and `--version` parameters
  - Added `--verbose` for debugging
  - Added `--resolutions` for custom resolutions
  - Separated `--variants` (types) and `--resolutions` (sizes)
  - Removed unsafe `eval` usage
  - Cleanup on EXIT (not just INT/TERM)
  - Improved error messages and validation

- **Version 1.5.0**:
  - Added `--speed` parameter for VP9 encoding speed
  - Added `--variants` for selective variant creation
  - Dynamic thread count detection
  - Comprehensive statistics at end
  - Cleanup trap for temporary files
  - Video-type-based CRF optimization

- **Version 1.4.0**:
  - Added video-type detection (screencast, animation, nature, action, film)
  - Bitrate-based CRF adjustment
  - 50% target size variant with binary search

- **Version 1.3.0**:
  - Automatic file size control with iterative CRF adjustment
  - Intelligent upscaling prevention through video width detection
  - Enhanced VP9 encoding parameters for better compression
  - Robust error handling and detailed progress feedback
  - Guaranteed smaller WebM output than MP4 input

- **Version 1.2.0**:
  - Introduced input/output directory structure

- **Version 1.0.0**:
  - Initial release with basic MP4 to WebM conversion

      IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant to your task.