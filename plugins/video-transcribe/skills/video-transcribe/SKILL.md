---
name: video-transcribe
description: Transcribe video or audio files to text. Use when the user wants to transcribe, get text from, or extract speech from a video or audio file.
allowed-tools: Bash
---

# Audio & Video Transcription

Transcribe video or audio files to text using OpenAI's transcription API.

## How to use

Run the transcription script:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/transcribe.sh" "<path-to-file>"
```

For timestamped output (SRT format):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/transcribe.sh" "<path-to-file>" --timestamps
```

## Supported formats

- **Video**: mp4, mov, avi, mkv, webm (audio is extracted automatically via ffmpeg)
- **Audio**: mp3, wav, m4a, flac, ogg, aac, wma (sent directly to API)

## Behavior

- Video files: extracts audio first using ffmpeg (auto-installs if missing)
- Audio files: sent directly to the API — no conversion needed
- Uses OpenAI's gpt-4o-transcribe model for best accuracy
- When `--timestamps` is used, falls back to whisper-1 (which supports SRT output)
- Files larger than 25MB are compressed to fit the API limit
- Temp files are cleaned up automatically

## Setup required

The script needs an OpenAI API key. It checks (in order):
1. `OPENAI_API_KEY` environment variable (set in shell profile)
2. `.env` file in the plugin's cache directory

If the script reports a missing key, tell the user to either:
- Set `export OPENAI_API_KEY=sk-...` in their `~/.zshrc` or `~/.bashrc`
- Or create a `.env` file in the path the script prints

## After transcription

Present the transcription text directly in the conversation. If the user wants it saved to a file, write it using the Write tool.
