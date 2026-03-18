---
name: tiktok-sponsors
description: Find sponsorships and partnerships in a TikTok profile's recent posts. Analyzes captions first, falls back to video transcription.
allowed-tools: Bash
---

# TikTok Sponsorship Detector

Detect sponsorships and brand partnerships in a TikTok profile's recent posts using a two-pass approach: caption analysis first, video transcription fallback.

## How to use

Given a TikTok profile or video URL, follow this workflow:

### Step 1: Scrape recent posts

```bash
bash "${CLAUDE_SKILL_DIR}/../tiktok-scrape/scripts/scrape.sh" "<tiktok-url>" --count 10
```

### Step 2: Analyze captions

Look through each post's `description` field for sponsorship signals:
- "Sponsored by", "paid partnership", "in collab with", "ad"
- Discount codes (e.g., "use code CHARLI for 15% off")
- Affiliate/tracking links
- Hashtags: #ad, #sponsored, #partner, #gifted, #collab, #brandpartner
- @mentions of brand accounts alongside promotional language
- TikTok's built-in "Paid partnership" label (visible in metadata)

### Step 3: Transcription fallback

For posts where the caption has NO sponsorship signals, download and transcribe:

```bash
FILE_PATH=$(bash "${CLAUDE_SKILL_DIR}/../video-download/scripts/download.sh" "<video-url>")
```

Then use the video-transcribe skill to transcribe the downloaded file:

```bash
bash "${CLAUDE_SKILL_DIR}/../../../video-transcribe/skills/video-transcribe/scripts/transcribe.sh" "$FILE_PATH"
```

Analyze the transcript for spoken sponsorship mentions.

### Step 4: Present structured results

For each sponsorship found, extract and present:

| Field | Description |
|---|---|
| **Brand/Company** | The sponsor's name |
| **Product/Service** | What's being promoted |
| **Type** | sponsor, affiliate, ambassador, or gifted |
| **Discount Code** | If mentioned |
| **Link** | Sponsor URL from caption |
| **Context** | Brief summary of what was said about the sponsor |

Also include which post it was found in (caption preview, URL, date).

## Important

- Always try caption analysis first — it's free and fast
- Only fall back to transcription for posts with no sponsorship signals in the caption
- TikTok videos are short, so transcription is quick and cheap
- Clean up downloaded video files after transcription
- If no sponsorships are found at all, report that clearly
