---
name: youtube-scrape
description: Scrape recent videos from a YouTube channel or fetch metadata for a specific video URL using Apify.
allowed-tools: Bash
---

# YouTube Scrape

Fetch recent video metadata (title, description, URL, date, engagement) from a YouTube channel or single video.

## How to use

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<youtube-url>"
```

Override the default count (5):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<youtube-url>" --count 10
```

## Input

- YouTube channel URL (e.g., `https://youtube.com/@mkbhd`)
- Or a single video URL (e.g., `https://youtube.com/watch?v=xyz`)

## Output

JSON array of video objects:

```json
[
  {
    "url": "https://youtube.com/watch?v=...",
    "title": "Video Title",
    "description": "Full video description...",
    "date": "2026-03-15",
    "views": 1200000,
    "likes": 45000,
    "comments": 3200
  }
]
```

## Setup required

Needs an Apify API token. The script checks (in order):
1. `APIFY_API_TOKEN` environment variable
2. `.env` file in the plugin directory

If the script reports a missing token, tell the user to set it up.

## After scraping

Present the results as a readable summary. If the user needs further analysis (e.g., sponsorship detection), pass the descriptions to the appropriate skill.
