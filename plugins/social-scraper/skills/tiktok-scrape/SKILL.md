---
name: tiktok-scrape
description: Scrape recent posts from a TikTok profile or fetch metadata for a specific video URL using Apify.
allowed-tools: Bash
---

# TikTok Scrape

Fetch recent post metadata (caption, URL, date, engagement) from a TikTok profile or single video.

## How to use

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<tiktok-url>"
```

Override the default count (10):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<tiktok-url>" --count 5
```

## Input

- TikTok profile URL (e.g., `https://tiktok.com/@charlidamelio`)
- Or a single video URL

## Output

JSON array of post objects:

```json
[
  {
    "url": "https://tiktok.com/@user/video/...",
    "title": "Caption text...",
    "description": "Caption text...",
    "date": "2026-03-15T12:00:00Z",
    "views": 5000000,
    "likes": 300000,
    "comments": 12000
  }
]
```

## Setup required

Needs an Apify API token. The script checks (in order):
1. `APIFY_API_TOKEN` environment variable
2. `.env` file in the plugin directory

## After scraping

Present the results as a readable summary. If the user needs further analysis, pass the captions to the appropriate skill.
