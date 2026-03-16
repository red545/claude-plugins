#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Cleanup ---
TEMP_FILES=()
cleanup() {
  for f in "${TEMP_FILES[@]+"${TEMP_FILES[@]}"}"; do
    rm -f "$f"
  done
}
trap cleanup EXIT

# --- Usage ---
usage() {
  echo "Usage: transcribe.sh <file> [--timestamps]"
  echo ""
  echo "  <file>          Path to video or audio file"
  echo "  --timestamps    Output SRT format with timestamps (uses whisper-1)"
  exit 1
}

# --- Parse args ---
FILE=""
TIMESTAMPS=false

for arg in "$@"; do
  case "$arg" in
    --timestamps) TIMESTAMPS=true ;;
    -h|--help) usage ;;
    *) FILE="$arg" ;;
  esac
done

if [ -z "$FILE" ]; then
  usage
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

# --- Load API key ---
# Check: 1) environment variable, 2) .env in plugin dir (cache), 3) .env next to .env.example (source)
if [ -z "${OPENAI_API_KEY:-}" ]; then
  if [ -f "$PLUGIN_DIR/.env" ]; then
    source "$PLUGIN_DIR/.env"
  fi
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "Error: OPENAI_API_KEY not found."
  echo ""
  echo "Setup (pick one):"
  echo "  Option A: Set environment variable"
  echo "    export OPENAI_API_KEY=sk-..."
  echo ""
  echo "  Option B: Create .env in the plugin cache"
  echo "    echo 'OPENAI_API_KEY=sk-...' > $PLUGIN_DIR/.env"
  exit 1
fi

# --- Install ffmpeg if missing ---
install_ffmpeg() {
  echo "ffmpeg not found. Installing..."
  if command -v brew &>/dev/null; then
    brew install ffmpeg
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y ffmpeg
  else
    echo "Error: Cannot auto-install ffmpeg. Please install it manually."
    exit 1
  fi
}

command -v ffmpeg &>/dev/null || install_ffmpeg

# --- Install jq if missing ---
install_jq() {
  echo "jq not found. Installing..."
  if command -v brew &>/dev/null; then
    brew install jq
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
  else
    echo "Error: Cannot auto-install jq. Please install it manually."
    exit 1
  fi
}

command -v jq &>/dev/null || install_jq

# --- Determine if input is video or audio ---
MIME_TYPE=$(file --mime-type -b "$FILE")
AUDIO_FILE="$FILE"

if [[ "$MIME_TYPE" == video/* ]]; then
  echo "Extracting audio from video..."
  TEMP_AUDIO=$(mktemp /tmp/transcribe_XXXXXX.wav)
  TEMP_FILES+=("$TEMP_AUDIO")
  ffmpeg -i "$FILE" -ar 16000 -ac 1 -f wav -y "$TEMP_AUDIO" 2>/dev/null
  AUDIO_FILE="$TEMP_AUDIO"
elif [[ "$MIME_TYPE" == audio/* ]]; then
  echo "Audio file detected. Sending directly to API..."
else
  echo "Error: Unsupported file type: $MIME_TYPE"
  echo "Supported: video (mp4, mov, avi, mkv, webm) and audio (mp3, wav, m4a, flac, ogg, aac)"
  exit 1
fi

# --- Check file size and compress if needed (25MB API limit) ---
FILE_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE" 2>/dev/null)
MAX_SIZE=$((25 * 1024 * 1024))

if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
  echo "File exceeds 25MB API limit. Compressing audio..."
  COMPRESSED=$(mktemp /tmp/transcribe_XXXXXX.mp3)
  TEMP_FILES+=("$COMPRESSED")
  ffmpeg -i "$AUDIO_FILE" -ac 1 -ar 16000 -b:a 64k -y "$COMPRESSED" 2>/dev/null
  AUDIO_FILE="$COMPRESSED"

  FILE_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE" 2>/dev/null)
  if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
    echo "Error: Audio still exceeds 25MB after compression. Try a shorter file."
    exit 1
  fi
fi

# --- Select model and format ---
if [ "$TIMESTAMPS" = true ]; then
  MODEL="whisper-1"
  RESPONSE_FORMAT="srt"
else
  MODEL="gpt-4o-transcribe"
  RESPONSE_FORMAT="text"
fi

# --- Call OpenAI API ---
echo "Transcribing with $MODEL..."

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "https://api.openai.com/v1/audio/transcriptions" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "file=@$AUDIO_FILE" \
  -F "model=$MODEL" \
  -F "response_format=$RESPONSE_FORMAT")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.error.message // .error // .' 2>/dev/null || echo "$BODY")
  echo "Error from OpenAI API (HTTP $HTTP_CODE): $ERROR_MSG"
  exit 1
fi

echo "$BODY"
