---
name: video-transcribe
description: Transcribe video or audio files to text. Use when the user wants to transcribe, get text from, or extract speech from a video or audio file.
allowed-tools: Bash
---

# Video Transcription

Transcribe a video or audio file using OpenAI's transcription API.

## How to use

Run the transcription script:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/transcribe.sh" "<path-to-file>"
```

For timestamped output (SRT format):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/transcribe.sh" "<path-to-file>" --timestamps
```

## Behavior

- The script extracts audio from video files using ffmpeg (auto-installs if missing)
- Sends audio to OpenAI's gpt-4o-transcribe model for best accuracy
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
