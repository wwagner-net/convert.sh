# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WebM Converter utility by Wolfgang Wagner - a simple but effective Bash script that converts MP4 videos to WebM format with multiple resolution options. The project focuses on creating optimized WebM videos for web usage with different viewport sizes.

## Architecture

**Single-script architecture**: The entire functionality is contained in `convert.sh` - a standalone Bash script that processes MP4 files in the current directory.

**Core functionality**:
- Processes all `.mp4` files in the working directory
- Creates 4 standard WebM variants: original, 1400px, 1000px, 500px
- Optional square 500x500px variant with `--square` or `-s` flag
- Uses VP9 video codec and Opus audio codec for optimal compression
- Quality settings: CRF 32 for larger sizes, CRF 33 for 500px variants

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

- `convert.sh` - Main conversion script
- `README.md` - Comprehensive German documentation
- `.gitignore` - Excludes video files (*.mp4, *.webm) and IDE files
- Sample video files (ignored by git)

## Dependencies

- **FFmpeg** - Required for video conversion
- **Bash** - Script runtime (Linux/macOS/WSL)

## Output Naming Convention

For input file `example.mp4`, the script generates:
- `example_original.webm` 
- `example_1400px.webm`
- `example_1000px.webm` 
- `example_500px.webm`
- `example_500px_square.webm` (with --square flag)

## Quality Settings

- **Original/1400px/1000px**: VP9 codec, CRF 32, Opus audio
- **500px variants**: VP9 codec, CRF 33 (higher compression), Opus audio
- **Square variant**: Intelligent cropping with `scale=500:500:force_original_aspect_ratio=increase,crop=500:500`

## Development Notes

- No package.json or build system - pure Bash script
- No tests - functional script for direct execution
- Git ignores all video files to keep repository clean
- Documentation is primarily in German (README.md)