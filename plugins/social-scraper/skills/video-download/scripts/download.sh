#!/usr/bin/env bash
set -euo pipefail

# --- Cleanup on failure only ---
OUTPUT_FILE=""
cleanup_on_error() {
  if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
    rm -f "$OUTPUT_FILE"
  fi
}
trap cleanup_on_error ERR

# --- Usage ---
usage() {
  echo "Usage: download.sh <video-url> [--output-dir DIR]"
  echo ""
  echo "  <url>           Video URL (YouTube, TikTok, Instagram)"
  echo "  --output-dir    Directory to save the video (default: /tmp)"
  echo ""
  echo "Outputs the downloaded file path to stdout."
  exit 1
}

# --- Parse args ---
URL=""
OUTPUT_DIR="/tmp"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) URL="$1"; shift ;;
  esac
done

if [ -z "$URL" ]; then
  usage
fi

# --- Install yt-dlp if missing ---
if ! command -v yt-dlp &>/dev/null; then
  echo "yt-dlp not found. Installing..." >&2
  if command -v brew &>/dev/null; then
    brew install yt-dlp
  elif command -v pip3 &>/dev/null; then
    pip3 install yt-dlp
  elif command -v pip &>/dev/null; then
    pip install yt-dlp
  else
    echo "Error: Cannot auto-install yt-dlp. Please install it manually." >&2
    exit 1
  fi
fi

# --- Download audio only ---
echo "Downloading audio..." >&2

OUTPUT_TEMPLATE="$OUTPUT_DIR/%(id)s.%(ext)s"

yt-dlp \
  --no-playlist \
  --extract-audio \
  --audio-format m4a \
  --audio-quality 9 \
  --output "$OUTPUT_TEMPLATE" \
  --print after_move:filepath \
  --quiet \
  "$URL"
