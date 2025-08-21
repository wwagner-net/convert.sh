# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WebM Converter utility by Wolfgang Wagner - an intelligent Bash script that converts MP4 videos to WebM format with automatic size optimization. The project focuses on creating optimized WebM videos that are guaranteed to be smaller than the original MP4, with intelligent resolution handling to avoid unnecessary upscaling.

## Architecture

**Single-script architecture**: The entire functionality is contained in `convert.sh` - a standalone Bash script that processes MP4 files from an input directory and outputs to a separate directory.

**Core functionality (Version 1.3.0)**:
- Reads all `.mp4` files from the `input/` directory
- Outputs converted files to the `output/` directory
- Automatically creates `input/` and `output/` directories if they don't exist
- **Intelligent resolution handling**: Only creates versions smaller than original (prevents upscaling)
- **Automatic file size control**: Guarantees WebM files ≤ MP4 size through adaptive CRF adjustment
- Creates variants: original, 1400px, 1000px, 500px (only if source is larger)
- Optional square 500x500px variant with `--square` or `-s` flag
- Uses optimized VP9 video codec and Opus audio codec
- **Adaptive CRF values**: Automatically increased until WebM < MP4 or max CRF 50 reached
- **Upscaling prevention**: Detects video width and skips larger resolution targets

## Usage Commands

**Standard conversion**:
```bash
bash ./convert.sh
```

**With square variant**:
```bash
bash ./convert.sh --square
# or
bash ./convert.sh -s
```

## File Structure

```
webmconverter/
├── convert.sh          # Main conversion script
├── README.md          # Comprehensive German documentation  
├── CLAUDE.md          # This file
├── .gitignore         # Excludes video files and IDE files
├── input/             # Directory for source MP4 files
└── output/            # Directory for converted WebM files
```

## Dependencies

- **FFmpeg** - Required for video conversion
  - macOS: `brew install ffmpeg`
  - Linux: `sudo apt install ffmpeg`
- **Bash** - Script runtime (Linux/macOS/WSL)

## Directory Structure & Output

**Input**: Place MP4 files in `input/` directory
**Output**: WebM files are created in `output/` directory

For input file `input/example.mp4`, the script generates in `output/`:
- `example_original.webm` 
- `example_1400px.webm`
- `example_1000px.webm` 
- `example_500px.webm`
- `example_500px_square.webm` (with --square flag)

## Quality Settings (Version 1.3.0)

### Adaptive CRF System
- **Original**: Starting CRF 30, automatically adjusted upward if WebM > MP4
- **1400px**: Starting CRF 32, automatically adjusted upward if WebM > MP4
- **1000px**: Starting CRF 33, automatically adjusted upward if WebM > MP4  
- **500px**: Starting CRF 35, automatically adjusted upward if WebM > MP4
- **Maximum CRF**: 50 (script skips conversion if still not smaller than MP4)

### Technical Optimizations
- **VP9 codec** with modern parameters:
  - `threads 8`: Multi-core performance optimization
  - `speed 2`: Balanced quality/encoding speed
  - `tile-columns 1`: Optimized for portrait videos
  - `row-mt 1`: Enhanced multi-threading
- **Opus audio**: 128kbps for optimal audio quality
- **Format enforcement**: `-f webm` ensures proper container format

### Intelligent Size Control
The `convert_with_size_check()` function implements iterative optimization:
1. Initial encoding with base CRF value
2. File size comparison with original MP4
3. Automatic CRF increment (+3) if WebM larger than MP4
4. Repeat until WebM ≤ MP4 or maximum CRF reached
5. Skip conversion if WebM cannot be made smaller than MP4

## Development Notes

- No package.json or build system - pure Bash script
- No tests - functional script for direct execution
- Git ignores all video files (*.mp4, *.webm) to keep repository clean
- Script validates input directory exists and contains MP4 files
- Documentation is primarily in German (README.md)
- Version 1.2.0 introduced input/output directory structure
- **Version 1.3.0 major improvements**:
  - Automatic file size control with iterative CRF adjustment
  - Intelligent upscaling prevention through video width detection
  - Enhanced VP9 encoding parameters for better compression
  - Robust error handling and detailed progress feedback
  - Guaranteed smaller WebM output than MP4 input