---
name: video-download
description: Download a video from YouTube, TikTok, or Instagram using yt-dlp. Returns the local file path.
allowed-tools: Bash
---

# Video Download

Download a video from YouTube, TikTok, or Instagram to a local file using yt-dlp.

## How to use

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/download.sh" "<video-url>"
```

Save to a specific directory:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/download.sh" "<video-url>" --output-dir /path/to/dir
```

## Input

Any video URL from:
- YouTube (e.g., `https://youtube.com/watch?v=xyz`)
- TikTok (e.g., `https://tiktok.com/@user/video/123`)
- Instagram (e.g., `https://instagram.com/reel/...`)

## Output

Prints the downloaded file path to stdout (e.g., `/tmp/dQw4w9WgXcQ.mp4`).

Status messages go to stderr so they don't interfere with the file path output.

## After downloading

The file path can be passed to other skills like `video-transcribe` for further processing:

```bash
FILE_PATH=$(bash "${CLAUDE_SKILL_DIR}/scripts/download.sh" "<url>")
bash "${CLAUDE_SKILL_DIR}/../../../video-transcribe/skills/video-transcribe/scripts/transcribe.sh" "$FILE_PATH"
```
