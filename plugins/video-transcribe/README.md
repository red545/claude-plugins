# video-transcribe

Transcribe video and audio files using OpenAI's transcription API. Extracts audio with ffmpeg, sends it to gpt-4o-transcribe for best-in-class accuracy.

## Setup

After installing the plugin, configure your API key:

1. Find the plugin directory:
   ```bash
   ls ~/.claude/plugins/cache/*/video-transcribe/
   ```
2. Copy the example env file:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env` and add your OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-key-here
   ```

## Requirements

- **ffmpeg** — auto-installed via brew (macOS) or apt (Linux) if missing
- **jq** — auto-installed via brew (macOS) or apt (Linux) if missing
- **OpenAI API key** — with access to the transcription API

## Usage

Just ask Claude to transcribe a video or audio file:

> "Transcribe this video at /path/to/video.mp4"

For timestamped output:

> "Transcribe this video with timestamps"

## Supported formats

Video: mp4, mov, avi, mkv, webm
Audio: mp3, wav, m4a, ogg, flac, webm

## Models used

- **gpt-4o-transcribe** — default, best accuracy ($0.006/min)
- **whisper-1** — used when timestamps are requested (supports SRT output)

## Limitations

- Max file size: 25MB (auto-compressed if larger)
- Max audio duration: ~25 minutes per API call
