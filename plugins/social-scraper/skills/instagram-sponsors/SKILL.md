---
name: instagram-sponsors
description: Find sponsorships and partnerships in an Instagram profile's recent posts. Analyzes captions first, falls back to video transcription for Reels.
allowed-tools: Bash
---

# Instagram Sponsorship Detector

Detect sponsorships and brand partnerships in an Instagram profile's recent posts using a two-pass approach: caption analysis first, video transcription fallback for Reels.

## How to use

Given an Instagram profile or post URL, follow this workflow:

### Step 1: Scrape recent posts

```bash
bash "${CLAUDE_SKILL_DIR}/../instagram-scrape/scripts/scrape.sh" "<instagram-url>" --count 10
```

### Step 2: Analyze captions

Look through each post's `description` field for sponsorship signals:
- "Sponsored", "paid partnership with", "ad", "gifted"
- Discount codes (e.g., "use code GARY for 20% off")
- Affiliate/tracking links (linktr.ee, brand URLs)
- Hashtags: #ad, #sponsored, #partner, #gifted, #collab, #paidpartnership
- @mentions of brand accounts alongside promotional language
- Instagram's "Paid partnership with" label (visible in metadata)

### Step 3: Transcription fallback (Reels only)

For Reels where the caption has NO sponsorship signals, download and transcribe:

```bash
FILE_PATH=$(bash "${CLAUDE_SKILL_DIR}/../video-download/scripts/download.sh" "<reel-url>")
```

Then use the video-transcribe skill to transcribe the downloaded file:

```bash
bash "${CLAUDE_SKILL_DIR}/../../../video-transcribe/skills/video-transcribe/scripts/transcribe.sh" "$FILE_PATH"
```

Analyze the transcript for spoken sponsorship mentions.

Note: Static image posts cannot be transcribed — only analyze their captions.

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
- Only fall back to transcription for Reels (video posts) with no sponsorship signals
- Static image posts: caption-only analysis (no transcription possible)
- Clean up downloaded video files after transcription
- If no sponsorships are found at all, report that clearly
