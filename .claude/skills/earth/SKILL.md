---
name: earth
description: >-
  Turn places into a ME · My Earth interactive globe. Use when the user asks to organize
  places, a ranking, a trip or a list into a map ("把这五家日本古董吉他店做成一张地图",
  "整理去年去过的地方，先给我草稿", "make a map of these places"), or asks to put selected
  photos and a short video at two places on a globe ("把我给的照片和视频做成互动地球").
  For places plus local photos/videos, use the local me-agent tool and keep media on the
  machine. Drafts stay local; only an explicit publish request posts text places to the
  public ME API and returns a map link plus a 1200x630 cover.
---

# earth — turn places into a shareable globe

Build a ME · My Earth map from the places a user names. A draft is a local JSON file. A
published map is a public link; anyone with that link can open the globe — no account, no
API key, no local app and no private Core checkout.

## Photos and videos

If the user selected photos or a short video and wants them on the map, do **not** send
those files to `POST /api/maps`. Use the local `me-agent` tool described in
<https://github.com/junyisunme/me-my-earth/blob/main/agent/README.md>. It produces a `.mezip` that opens with **打开地图包**,
a 1600×900 PNG for slides, and an optional Lively wallpaper project. Media stays on the
user's machine; if you have no local execution ability, say so instead of claiming a
package was created.

**Maps are public by link.** Anything sent to `POST /api/maps` can be opened by anyone who
has the URL, including its source links. Never publish private addresses, personal contact
details or unpublished data unless the user explicitly asks for a public map and knows that.

## Install (a human does this once)

The skill is one file, `.claude/skills/earth/SKILL.md`. Claude Code and Cursor both read
that file, so **one copy serves both clients**.

**Project install** — inside a clone of this repository there is nothing to do: both
clients discover `.claude/skills/earth/SKILL.md` automatically.

**Personal install** — available in every project:

```bash
mkdir -p ~/.claude/skills/earth
curl -L -o ~/.claude/skills/earth/SKILL.md \
  https://raw.githubusercontent.com/junyisunme/me-my-earth/main/.claude/skills/earth/SKILL.md
```

- **Claude Code**: restart the session, run `/skills` to confirm `earth` is listed, then
  invoke it with `/earth` or just ask in words.
- **Cursor**: Cursor loads `~/.claude/skills/` and project `.claude/skills/` for
  compatibility; type `/` in Agent chat and choose `earth`, or ask in words.
- **Older Cursor** that only scans its own directory: copy the same file to
  `~/.cursor/skills/earth/SKILL.md`.

Full install notes, execution details and the current verification status:
<https://github.com/junyisunme/me-my-earth/blob/main/docs/SKILL.md>

## Draft or publish?

Default to a draft. These are two different requests:

| The user asks | Do | Do not |
| --- | --- | --- |
| “整理”, “生成草稿”, “给我 JSON”, “先看看”, “make a draft” | Build the JSON and save it as a local file (for example `family-2025.json`), then show the path, title and a short preview | Call `POST /api/maps` |
| “生成公开分享链接”, “发布”, “上传”, “make a shareable link” | Build and validate the JSON, then call `POST /api/maps` **once**; return `shareUrl` and, when ready, the cover | Call `POST` again because the cover failed |

Publishing makes the map **public by link**. Say that with the link. Never publish a draft
the user only asked to organize, and never turn a private list into a public map on your own.

Example:

> User: 把去年全家去过的 12 个地方整理一下，先给我草稿。
>
> You: build `family-2025.json` with 12 events, do **not** call the API, and reply with the
> file path, the title and a short list of the places.

> User: 可以，生成公开分享链接。
>
> You: post that same JSON once, then return the map link and the cover if `coverStatus` is
> `ready`.

Current scope is places, dates, short text and source links. Photos and videos are not
supported yet; do not promise them.

## What a publish returns

After `POST /api/maps` the response contains:

| Field | Meaning |
| --- | --- |
| `shareUrl` | The interactive globe. Always present once the map exists. |
| `previewImageUrl` | Public 1200x630 PNG cover, when the cover is ready. |
| `coverStatus` | `ready` or `failed`. |
| `eventCount` / `countryCount` / `cityCount` | What the map contains. |

Show `shareUrl` as a clickable link. Show `previewImageUrl` only when `coverStatus` is
`"ready"` and the URL is not `null`. If the cover failed, deliver the map link alone and
say the map is live — **do not resubmit**, the map has already been saved.

## Route 1 — the five Japanese vintage guitar shops

Use this route when the user says something like
「把这五家日本古董吉他店做成一张地图」 or "make a map of the five guitar shops".

The sample always comes from the fixed, verified commit below — never from a local
`examples/guitar-five.json` and never from a `guitar-five.json` in the working directory.
The download goes into a fresh temporary directory, is validated as JSON, and the directory
is removed when the command exits.

```bash
set -euo pipefail

SAMPLE_SHA="da8a6019dd6ee469e9192e88d10b1e4f67bc7fe8"
SAMPLE_URL="https://raw.githubusercontent.com/junyisunme/me-my-earth/${SAMPLE_SHA}/examples/guitar-five.json"
API_BASE="https://me-interest-globe.netlify.app"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# --fail makes any HTTP error (404, 500, ...) a non-zero exit.
curl --fail --silent --show-error --location --retry 3 \
  --output "$WORK/guitar-five.json" "$SAMPLE_URL"

# Stop before sending if the download is not the expected JSON.
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; d=json.load(open(sys.argv[1], encoding="utf-8")); assert d.get("schemaVersion")==1 and len(d.get("events",[]))==5' "$WORK/guitar-five.json"
elif command -v python >/dev/null 2>&1; then
  python -c 'import json,sys; d=json.load(open(sys.argv[1], encoding="utf-8")); assert d.get("schemaVersion")==1 and len(d.get("events",[]))==5' "$WORK/guitar-five.json"
elif command -v node >/dev/null 2>&1; then
  node -e 'const d=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")); if(d.schemaVersion!==1||!Array.isArray(d.events)||d.events.length!==5) process.exit(1)' "$WORK/guitar-five.json"
else
  echo "Need python3, python or node to validate the JSON" >&2
  exit 1
fi

# Publish once. The response contains shareUrl and the cover fields.
curl --fail-with-body --silent --show-error \
  --request POST "$API_BASE/api/maps" \
  --header "Content-Type: application/json" \
  --data-binary "@$WORK/guitar-five.json"
```

### Windows PowerShell

Use `curl.exe` explicitly — in PowerShell, plain `curl` is an alias for `Invoke-WebRequest`
and does not accept these flags. Every `curl.exe` call is followed immediately by a
`$LASTEXITCODE` check. A non-zero POST exit prints the API body and fails; a zero exit is only
treated as success when the response contains a usable `shareUrl`. `-Encoding UTF8` is
required on Windows PowerShell 5.1 for the Chinese sample.

```powershell
$ErrorActionPreference = "Stop"

$sha  = "da8a6019dd6ee469e9192e88d10b1e4f67bc7fe8"
$base = "https://me-interest-globe.netlify.app"
$work = Join-Path ([System.IO.Path]::GetTempPath()) ("me-earth-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work | Out-Null

try {
  $sample = Join-Path $work "guitar-five.json"
  $url = "https://raw.githubusercontent.com/junyisunme/me-my-earth/$sha/examples/guitar-five.json"

  $previous = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $download = & curl.exe --fail --silent --show-error --location --retry 3 `
    --output $sample $url 2>&1
  $downloadExit = $LASTEXITCODE
  $ErrorActionPreference = $previous
  if ($downloadExit -ne 0) {
    $detail = ($download | Out-String).Trim()
    throw "Sample download failed (curl exit $downloadExit). $detail"
  }

  $doc = Get-Content -LiteralPath $sample -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($doc.schemaVersion -ne 1 -or $doc.events.Count -ne 5) {
    throw "Unexpected guitar sample: schemaVersion=$($doc.schemaVersion), events=$($doc.events.Count)"
  }

  $previous = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $response = & curl.exe --fail-with-body --silent --show-error `
    --request POST "$base/api/maps" `
    --header "Content-Type: application/json" `
    --data-binary "@$sample" 2>&1
  $postExit = $LASTEXITCODE
  $ErrorActionPreference = $previous
  if ($postExit -ne 0) {
    $body = ($response | Out-String).Trim()
    throw "Map creation failed (curl exit $postExit). API response: $body"
  }

  try {
    $map = $response | ConvertFrom-Json
  } catch {
    throw "Map creation result is unconfirmed: the response was not valid JSON. The map may already be saved; do not POST again automatically."
  }
  if ([string]::IsNullOrWhiteSpace([string]$map.shareUrl)) {
    throw "Map creation result is unconfirmed: no shareUrl. The map may already be saved; do not POST again automatically."
  }

  $map | ConvertTo-Json -Depth 5
}
finally {
  Remove-Item -LiteralPath $work -Recurse -Force
}
```

Expected: HTTP `201`, `eventCount: 5`, `countryCount: 1`, `cityCount: 2`, cover `ready` at
1200x630. The first screen shows **3 shops in Tokyo and 2 in Osaka**.

Do not edit this sample's coordinates on this route — it is the verified example. If the
user wants the shops as individual storefront markers, that is a new map (Route 2), not an
edit of the sample.

## Route 2 — the user's own place list

Turn whatever the user gives you (names, addresses, a ranking, a CSV, notes) into the JSON
contract documented in
[`docs/API.md`](https://github.com/junyisunme/me-my-earth/blob/main/docs/API.md).

**If the user asked for a draft, stop after writing and validating the local file.** If the
user explicitly asked for a public share link, post that file once with the command from
Route 1 (only the input path changes), then return the link.

Minimum shape:

```json
{
  "schemaVersion": 1,
  "title": "Five vintage guitar shops in Japan",
  "events": [
    {
      "id": "shop-tokyo-1",
      "title": "Shop name",
      "summary": "One or two sentences about what makes this place worth a visit.",
      "publishedDate": null,
      "eventDate": null,
      "source": { "name": "Official shop page", "url": "https://example.com/shop" },
      "locations": [
        {
          "countryId": "JPN",
          "precision": "point",
          "placeId": null,
          "label": "Shop name, Tokyo",
          "reason": "The shop's storefront is at this address in Tokyo.",
          "lat": 35.6583,
          "lng": 139.7188
        }
      ]
    }
  ]
}
```

Rules that the API enforces:

- `schemaVersion` is exactly `1`; `title` is 1–120 characters; 1–100 events with unique
  `id`s (letters, digits, `.`, `_`, `:`, `-`).
- Every event needs `title` (1–300), `summary` (1–3000, plain text), `source.name`,
  `source.url` and 1–30 `locations`.
- `source.url` must be a real, direct `http` / `https` page. Use the official page or the
  page the user supplied. **Never invent a URL, a date, a rank or a score.**
- `publishedDate` / `eventDate`: `YYYY-MM-DD` only when you actually know it, otherwise
  `null`. Never use today's date as a placeholder.
- `countryId` is an ME country/region id such as `JPN`, `USA`, `GBR`, `NOR`.
- `precision`:
  - `country` — country-level relation only; omit `placeId`, `lat` and `lng`.
  - `city` — a known `placeId`, or a label plus city-area coordinates.
  - `point` — the actual storefront / feature coordinates. A point is a marker, never a
    boundary or a polygon claim.
- `location.reason` explains why the event belongs at that place (1–500 characters).
- Unknown country ids, duplicate event ids, mismatched `placeId`s, `0,0` coordinates and
  control characters are rejected with a JSON error that names the field path. Fix the
  named fields and retry.

If a place cannot be verified, ask the user instead of guessing. If the user only wants a
file, produce the JSON, validate it against the rules above, and hand over the path — the
same file uploads at the web create page.

## Reply format

For a published map, keep the reply short and put the link first:

```text
Map:   https://…/?map=…
Cover: https://…/api/covers/v2/….png
Contents: 5 events · 1 country · 2 places (3 Tokyo, 2 Osaka)

The map is public: anyone with the link can open it.
```

For a draft, do not print a map link:

```text
Draft: ./family-2025.json
Contents: 12 events · 9 countries · 12 places

No public link was created. Say the word if you want me to publish it.
```

If the cover failed after a publish:

```text
Map: https://…/?map=…
Cover: not generated this time — the map itself is live.

The map is public: anyone with the link can open it.
```

Never present a `previewImageUrl` that is `null`, and never create a second map because the
cover failed.

## Limits and boundaries

- Request body 512 KB; 100 events; 30 locations per event; title 120; event title 300;
  summary 3000; reason 500.
- The public base URL above is a Deploy Preview, not the production site. If it stops
  responding, report that plainly; do not silently switch to a private deployment.
- This route uses only the public API. No account, token, private service or application
  source is required.
- API guide: <https://github.com/junyisunme/me-my-earth/blob/main/docs/API.md>
