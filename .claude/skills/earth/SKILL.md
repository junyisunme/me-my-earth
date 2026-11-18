---
name: earth
description: >-
  Build a shareable ME · My Earth globe map from a list of places. Use when the user asks
  to turn places, a ranking or a list into a map ("把这五家日本古董吉他店做成一张地图",
  "make a map of these places", "put my places on a globe"), or wants a downloadable map
  JSON. Creates the map through the public ME map API and returns a clickable map link
  plus a 1200x630 cover.
---

# earth — turn places into a shareable globe

Build one ME · My Earth map from the places a user names. The result is a single public
link; anyone with that link can open the globe — no account, no API key, no local app and
no private Core checkout.

**Maps are public by link.** Anyone who has the URL can open the map and follow its source
links. Never put private addresses, personal contact details or unpublished data into a
map.

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

Full install notes and the current verification status:
<https://github.com/junyisunme/me-my-earth/blob/main/docs/SKILL.md>

## What you return

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

The verified sample is
[`examples/guitar-five.json`](https://github.com/junyisunme/me-my-earth/blob/main/examples/guitar-five.json)
in this
repository. Use the local copy if you have one; otherwise download it.

```bash
# use the repo copy when present
if [ ! -f examples/guitar-five.json ]; then
  curl -L -o guitar-five.json \
    https://raw.githubusercontent.com/junyisunme/me-my-earth/main/examples/guitar-five.json
  INPUT=guitar-five.json
else
  INPUT=examples/guitar-five.json
fi

curl -sS -X POST \
  "https://6afc8b581813239311ea1a4d--me-interest-globe.netlify.app/api/maps" \
  -H "Content-Type: application/json" \
  --data-binary "@$INPUT"
```

Expected: HTTP `201`, `eventCount: 5`, `countryCount: 1`, `cityCount: 2`, cover `ready` at
1200x630. The first screen shows **3 shops in Tokyo and 2 in Osaka**.

Do not edit this sample's coordinates on this route — it is the verified example. If the
user wants the shops as individual storefront markers, that is a new map (Route 2), not an
edit of the sample.

## Route 2 — the user's own place list

Turn whatever the user gives you (names, addresses, a ranking, a CSV, notes) into the
public JSON contract documented in
[`docs/API.md`](https://github.com/junyisunme/me-my-earth/blob/main/docs/API.md), then POST it
exactly as
above. Minimum shape:

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
file, produce the JSON, validate it against the rules above, and hand it over — the same
file uploads at the web create page.

## Reply format

Keep the reply short and put the link first:

```text
Map:   https://…/?map=…
Cover: https://…/api/covers/v2/….png
Contents: 5 events · 1 country · 2 places (3 Tokyo, 2 Osaka)

The map is public: anyone with the link can open it.
```

If the cover failed:

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
