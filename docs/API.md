# ME public map API

Create and read shareable maps with the same JSON contract used by the ME web uploader. No account, cookie or API key is required on the live preview.

> Preview base: `https://6afc360699e893e455c29a00--me-interest-globe.netlify.app`  
> This is a Deploy Preview. The stable site may run an older version.

## Create a map

```http
POST /api/maps
Content-Type: application/json
```

Download the working example first:

```bash
curl -L -o guitar-five.json \
  https://raw.githubusercontent.com/junyisunme/me-my-earth/main/examples/guitar-five.json

curl -X POST "https://6afc360699e893e455c29a00--me-interest-globe.netlify.app/api/maps" \
  -H "Content-Type: application/json" \
  --data-binary @guitar-five.json
```

A successful response is `201 Created`:

```json
{
  "mapId": "PL5oOcNN_ai4OFXx0zq9tpCT",
  "shareUrl": "https://…/?map=PL5oOcNN_ai4OFXx0zq9tpCT",
  "eventCount": 5,
  "countryCount": 1,
  "cityCount": 2,
  "previewImageUrl": "https://…/api/covers/PL5oOcNN_ai4OFXx0zq9tpCT.png",
  "coverStatus": "ready"
}
```

- `shareUrl` is the interactive map.
- `previewImageUrl` is a public 1200×630 PNG, readable without a cookie or login.
- If the map was saved but the cover could not be generated, the response is still `201` with a usable `shareUrl`, but `previewImageUrl` is `null`, `coverStatus` is `"failed"`, and `coverError` explains the cover state. Do not resubmit: the map already exists.

## Read a map

```http
GET /api/maps/<mapId>
```

Returns the stored snapshot, including `mapId` and `createdAt`.

```http
GET /api/covers/<mapId>.png
```

Returns the generated cover PNG. A missing cover returns `404` JSON.

## Minimal JSON

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
      "source": {
        "name": "Official shop page",
        "url": "https://example.com/shop"
      },
      "locations": [
        {
          "countryId": "JPN",
          "precision": "city",
          "placeId": null,
          "label": "Tokyo",
          "reason": "The shop is in Tokyo; this point is its storefront area.",
          "lat": 35.6583,
          "lng": 139.7188
        }
      ]
    }
  ]
}
```

## Fields

### Top level

| Field | Required | Rule |
| --- | --- | --- |
| `schemaVersion` | yes | Must be `1` |
| `title` | yes | 1–120 characters |
| `events` | yes | 1–100 events; each `id` unique |

### Event

| Field | Required | Rule |
| --- | --- | --- |
| `id` | yes | 1–80 characters; letters, numbers, `.` `_` `:` `-`; unique |
| `title` | yes | 1–300 characters |
| `summary` | yes | 1–3000 characters, plain text |
| `publishedDate` | no | `YYYY-MM-DD`, `null`, empty or omitted; do not invent today’s date |
| `eventDate` | no | `YYYY-MM-DD` or `null`; only when the event date is known |
| `source.name` | yes | 1–160 characters |
| `source.url` | yes | Direct `http` / `https` source, max 2048 characters |
| `locations` | yes | 1–30 linked places |

### Location

| Field | Required | Rule |
| --- | --- | --- |
| `countryId` | yes | ME country/region ID, e.g. `JPN`, `USA`, `NOR`, `GBR` |
| `precision` | yes | `country`, `city` or `point` |
| `label` | yes | Human-readable place name, 1–160 characters |
| `reason` | yes | 1–500 characters explaining why this event belongs here |
| `placeId` | no | Existing ME city ID, or `null` |
| `lat` / `lng` | depends | Required for a new city or point; latitude −90–90, longitude −180–180; `0,0` is rejected |

Rules:

1. `precision: "country"`: only country-level relation; leave `placeId`, `lat` and `lng` empty.
2. `precision: "city"`: use a known `placeId` or provide a label and coordinates.
3. `precision: "point"`: provide coordinates; use the marker for the actual feature (a resort base, field area or other representative point), not a default capital.
4. A single event may link several countries or several places. Counts are per unique event; a cross-border event counts once globally and once in each linked country.
5. The map never draws field or basin boundaries. A point is a marker, not a polygon claim.

## Limits

- Request body: **512 KB**
- Events: **100**
- Locations per event: **30**
- Title 120 / event title 300 / summary 3000 / location reason 500 characters
- `source.url` must be a direct `http` or `https` page
- Unknown country IDs, duplicate event IDs, unknown/ mismatched `placeId`s, invalid coordinates and control characters are rejected

Errors are JSON:

```json
{
  "error": {
    "code": "validation_failed",
    "message": "Map not created: 1 field needs attention",
    "issues": [
      {
        "code": "required",
        "message": "summary is required",
        "path": "events[0].summary"
      }
    ]
  }
}
```

## Displaying the result

```js
const map = await response.json();

if (map.coverStatus === "ready" && map.previewImageUrl) {
  showImage(map.previewImageUrl);
}

showLink(map.shareUrl, "Open interactive globe");
```

Text-only clients should show `shareUrl`. If the cover failed, keep the link and skip the image.

## Reusing the API examples

You may copy and modify the original API call examples in this repository to connect to ME. This permission applies only to those original call examples.

## First screen

A whole-map link with no `country`, `place`, `entry` or `loc` chooses its first view once:

- one country/region → open that country;
- multiple, and one country is strictly over 60% → keep the global zoom and centre it;
- otherwise, including exactly 60% → the default global view.

Explicit place links always win, and the automatic view is not re-applied after the user moves, zooms or changes language.
