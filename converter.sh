#!/bin/bash
# =============================================================================
# Convert MP3 -> WAV (trimmed + processed) -> ATRAC3 for PSP
# =============================================================================

set -euo pipefail

# Directories
RAW_DIR="audio_raw"
MP3_DIR="audio_mp3"
WAV_DIR="audio_wav"
AT3_DIR="audio_at3"

# Create output directories
mkdir -p "$WAV_DIR" "$AT3_DIR" "$MP3_DIR" "$RAW_DIR"

# Check required tools
command -v ffmpeg >/dev/null 2>&1 || {
  echo "Error: ffmpeg not found"
  exit 1
}
command -v ffprobe >/dev/null 2>&1 || {
  echo "Error: ffprobe not found"
  exit 1
}
command -v at3tool >/dev/null 2>&1 || { echo "Warning: at3tool not found in PATH"; }

echo "Starting conversion process..."

# Process all MP3 files
for mp3_file in "$MP3_DIR"/*.mp3; do
  [[ -f "$mp3_file" ]] || {
    echo "No MP3 files found in $MP3_DIR"
    exit 1
  }

  # Extract filename without path and extension
  base=$(basename "$mp3_file" .mp3)

  # Get the number (last part after underscore)
  number=$(echo "$base" | rev | cut -d'_' -f1 | rev)

  # Validate number
  if ! [[ "$number" =~ ^[0-9]+$ ]]; then
    echo "Warning: Could not extract valid number from $mp3_file (got '$number'). Skipping."
    continue
  fi

  raw_wav="$RAW_DIR/${number}.wav"
  if [[ ! -f "$raw_wav" ]]; then
    echo "Warning: Raw reference file not found: $raw_wav. Skipping $mp3_file"
    continue
  fi

  # Get duration from raw PSP WAV
  duration=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$raw_wav")

  if [[ -z "$duration" ]]; then
    echo "Warning: Could not get duration from $raw_wav. Skipping."
    continue
  fi

  # Convert number to hex (number - 1) -> 4-digit uppercase
  hex=$(printf "%04X" $((number - 1)))

  # Output filenames
  wav_out="$WAV_DIR/${number}_${hex}.wav"
  at3_out="$AT3_DIR/${hex}"

  echo "Processing: $mp3_file -> $wav_out -> $at3_out (dur=${duration}s)"

  # MP3 -> WAV
  ffmpeg -y -loglevel error -i "$mp3_file" \
    -t "$duration" \
    -ar 44100 \
    -ac 2 \
    -sample_fmt s16 \
    -af "volume=3.0" \
    "$wav_out"

  # WAV -> ATRAC3
  if command -v at3tool >/dev/null 2>&1; then
    at3tool -e -br 132 -wholeloop "$wav_out" "$at3_out" >/dev/null 2>&1
    echo "Completed: ${hex}"
  else
    echo "at3tool not available. WAV created but ATRAC3 skipped."
  fi

  echo "--------------------------------------------------"
done

echo "Conversion finished!"
