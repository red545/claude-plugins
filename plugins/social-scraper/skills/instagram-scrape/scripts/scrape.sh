#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"

# --- Usage ---
usage() {
  echo "Usage: scrape.sh <profile-or-post-url> [--count N]"
  echo ""
  echo "  <url>       Instagram profile URL or post URL"
  echo "  --count N   Number of posts to fetch (default: 10)"
  exit 1
}

# --- Parse args ---
URL=""
COUNT=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count) COUNT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) URL="$1"; shift ;;
  esac
done

if [ -z "$URL" ]; then
  usage
fi

# --- Load API token ---
if [ -z "${APIFY_API_TOKEN:-}" ]; then
  if [ -f "$PLUGIN_DIR/.env" ]; then
    source "$PLUGIN_DIR/.env"
  fi
fi

if [ -z "${APIFY_API_TOKEN:-}" ]; then
  echo "Error: APIFY_API_TOKEN not found."
  echo ""
  echo "Setup (pick one):"
  echo "  Option A: Set environment variable"
  echo "    export APIFY_API_TOKEN=apify_api_..."
  echo ""
  echo "  Option B: Create .env in the plugin directory"
  echo "    echo 'APIFY_API_TOKEN=apify_api_...' > $PLUGIN_DIR/.env"
  exit 1
fi

# --- Install jq if missing ---
if ! command -v jq &>/dev/null; then
  echo "jq not found. Installing..."
  if command -v brew &>/dev/null; then
    brew install jq
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
  else
    echo "Error: Cannot auto-install jq. Please install it manually."
    exit 1
  fi
fi

# --- Build Apify input ---
ACTOR_ID="apify~instagram-scraper"

INPUT_JSON=$(jq -n \
  --arg url "$URL" \
  --argjson count "$COUNT" \
  '{
    directUrls: [$url],
    resultsLimit: $count,
    resultsType: "posts"
  }')

# --- Call Apify sync API ---
echo "Scraping Instagram (last $COUNT posts)..." >&2

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $APIFY_API_TOKEN" \
  -d "$INPUT_JSON" \
  "https://api.apify.com/v2/acts/$ACTOR_ID/run-sync-get-dataset-items?timeout=300")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "201" ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.error.message // .error // .' 2>/dev/null || echo "$BODY")
  echo "Error from Apify API (HTTP $HTTP_CODE): $ERROR_MSG" >&2
  exit 1
fi

# --- Extract relevant fields ---
echo "$BODY" | jq '[.[] | {
  url: (.url // .shortCode // ""),
  title: (.caption // ""),
  description: (.caption // ""),
  date: (.timestamp // .takenAt // ""),
  views: (.videoViewCount // .playCount // 0),
  likes: (.likesCount // .likes // 0),
  comments: (.commentsCount // .comments // 0)
}]'
