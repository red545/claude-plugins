---
name: instagram-scrape
description: Scrape recent posts from an Instagram profile or fetch metadata for a specific post URL using Apify.
allowed-tools: Bash
---

# Instagram Scrape

Fetch recent post metadata (caption, URL, date, engagement) from an Instagram profile or single post.

## How to use

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<instagram-url>"
```

Override the default count (10):

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/scrape.sh" "<instagram-url>" --count 5
```

## Input

- Instagram profile URL (e.g., `https://instagram.com/garyvee`)
- Or a single post URL (e.g., `https://instagram.com/p/...`)

## Output

JSON array of post objects:

```json
[
  {
    "url": "https://instagram.com/p/...",
    "title": "Caption text...",
    "description": "Caption text...",
    "date": "2026-03-15T12:00:00Z",
    "views": 500000,
    "likes": 25000,
    "comments": 800
  }
]
```

## Setup required

Needs an Apify API token. The script checks (in order):
1. `APIFY_API_TOKEN` environment variable
2. `.env` file in the plugin directory

## After scraping

Present the results as a readable summary. If the user needs further analysis, pass the captions to the appropriate skill.
