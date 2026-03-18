---
name: youtube-sponsors
description: Find sponsorships and partnerships in a YouTube channel's recent videos. Analyzes descriptions first, falls back to video transcription.
allowed-tools: Bash
---

# YouTube Sponsorship Detector

Detect sponsorships and brand partnerships in a YouTube channel's recent videos using a two-pass approach: description analysis first, video transcription fallback.

## How to use

Given a YouTube channel or video URL, follow this workflow:

### Step 1: Scrape recent videos

```bash
bash "${CLAUDE_SKILL_DIR}/../youtube-scrape/scripts/scrape.sh" "<youtube-url>" --count 5
```

### Step 2: Analyze descriptions

Look through each video's `description` field for sponsorship signals:
- "Sponsored by", "brought to you by", "thanks to", "in partnership with"
- Discount codes (e.g., "use code MKBHD for 20% off")
- Affiliate/tracking links (bit.ly, linktr.ee, brand-specific URLs)
- Hashtags: #ad, #sponsored, #partner, #gifted, #collab
- Dedicated sponsor sections in descriptions (common on YouTube)

### Step 3: Transcription fallback

For videos where the description has NO sponsorship signals, download and transcribe:

```bash
FILE_PATH=$(bash "${CLAUDE_SKILL_DIR}/../video-download/scripts/download.sh" "<video-url>")
```

Then use the video-transcribe skill to transcribe the downloaded file:

```bash
bash "${CLAUDE_SKILL_DIR}/../../../video-transcribe/skills/video-transcribe/scripts/transcribe.sh" "$FILE_PATH"
```

Analyze the transcript for spoken sponsorship mentions (intro/mid-roll/outro sponsor reads).

### Step 4: Present structured results

For each sponsorship found, extract and present:

| Field | Description |
|---|---|
| **Brand/Company** | The sponsor's name |
| **Product/Service** | What's being promoted |
| **Type** | sponsor, affiliate, ambassador, or gifted |
| **Discount Code** | If mentioned (e.g., "MKBHD20") |
| **Link** | Sponsor URL from description |
| **Context** | Brief summary of what was said about the sponsor |

Also include which video it was found in (title, URL, date).

## Important

- Always try description analysis first — it's free and fast
- Only fall back to transcription for videos with no sponsorship signals in the description
- Clean up downloaded video files after transcription
- If no sponsorships are found at all, report that clearly
