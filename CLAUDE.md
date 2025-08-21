# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a WebM Converter utility by Wolfgang Wagner - a simple but effective Bash script that converts MP4 videos to WebM format with multiple resolution options. The project focuses on creating optimized WebM videos for web usage with different viewport sizes.

## Architecture

**Single-script architecture**: The entire functionality is contained in `convert.sh` - a standalone Bash script that processes MP4 files from an input directory and outputs to a separate directory.

**Core functionality**:
- Reads all `.mp4` files from the `input/` directory
- Outputs converted files to the `output/` directory
- Automatically creates `input/` and `output/` directories if they don't exist
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

## Quality Settings

- **Original/1400px/1000px**: VP9 codec, CRF 32, Opus audio
- **500px variants**: VP9 codec, CRF 33 (higher compression), Opus audio
- **Square variant**: Intelligent cropping with `scale=500:500:force_original_aspect_ratio=increase,crop=500:500`

## Development Notes

- No package.json or build system - pure Bash script
- No tests - functional script for direct execution
- Git ignores all video files (*.mp4, *.webm) to keep repository clean
- Script validates input directory exists and contains MP4 files
- Documentation is primarily in German (README.md)
- Version 1.2.0 introduced input/output directory structure