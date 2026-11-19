# The `earth` skill

One skill file turns a place list into a ME · My Earth map. A **draft** is a local JSON file;
a **published map** is a public link plus, when ready, a 1200×630 cover. It uses the public
API documented in [`API.md`](API.md) — no account, no API key, no private Core checkout, no
build step.

The skill lives at [`.claude/skills/earth/SKILL.md`](../.claude/skills/earth/SKILL.md).

## One file, both clients

Claude Code and Cursor read the same file from the same paths:

| Client | Project | Personal |
| --- | --- | --- |
| Claude Code | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` |
| Cursor | `.claude/skills/` (compatibility) | `~/.claude/skills/` (compatibility) |

Cursor's compatibility list is documented in [Cursor — Agent Skills](https://cursor.com/docs/skills#skill-directories);
Claude Code's personal and project paths are in [Claude Code — Extend Claude with skills](https://code.claude.com/docs/en/skills#where-skills-live).
That is why this repository keeps a single copy at `.claude/skills/earth/SKILL.md` instead of
maintaining two skills.

## Install — Claude Code

**Project install** (inside a clone of this repository): nothing to do. Start Claude Code in
the repository and the skill is discovered.

**Personal install** (every project):

```bash
mkdir -p ~/.claude/skills/earth
curl -L -o ~/.claude/skills/earth/SKILL.md \
  https://raw.githubusercontent.com/junyisunme/me-my-earth/main/.claude/skills/earth/SKILL.md
```

Restart the session, run `/skills` to confirm `earth` is listed, then use `/earth` or ask in
words.

## Install — Cursor

**Project install**: open the repository in Cursor; Cursor loads `.claude/skills/` for
compatibility. Type `/` in Agent chat and choose `earth`.

**Personal install**: use the same command as above — Cursor also reads
`~/.claude/skills/`. If your Cursor build only scans its own directory, copy the same file
to Cursor's native location:

```bash
mkdir -p ~/.cursor/skills/earth
cp ~/.claude/skills/earth/SKILL.md ~/.cursor/skills/earth/SKILL.md
```

## Invoke it

```text
/earth 把这五家日本古董吉他店做成一张地图
/earth 整理去年全家去过的三个地方，先给我草稿
/earth 可以，生成公开分享链接
/earth make a map of these places
/earth turn this list into a globe: <paste places, addresses or a ranking>
```

The skill also matches a plain request without the slash command, because its description
names the trigger phrases.

## Draft or publish — the rule

| The user asks | What the skill does | What it must not do |
| --- | --- | --- |
| “整理”, “生成草稿”, “给我 JSON”, “先看看”, “make a draft” | Builds the JSON, validates it and saves a local file such as `family-2025.json` | `POST /api/maps` |
| “生成公开分享链接”, “发布”, “上传”, “make a shareable link” | Builds and validates the same JSON, then posts it **once** and returns `shareUrl` (+ cover when ready) | Post again because the cover failed |

Publishing makes the map public by link. Anything posted can be opened, and its source links
followed, by anyone who has the URL. The skill must say that when it returns a link and must
never publish a draft the user only asked to organize.

Example:

> User: 把去年全家去过的 12 个地方整理一下，先给我草稿。
>
> Skill: build `family-2025.json` with 12 events, no `POST`, and reply with the path, title
> and a short preview.

> User: 可以，生成公开分享链接。
>
> Skill: post the same file once, then return the map link and the cover if `coverStatus` is
> `ready`.

Current scope is places, dates, short text and source links. Photos and videos are not
supported yet.

## What it does

- **Five guitar shops** — downloads the official sample from a fixed commit into a fresh
  temporary directory, checks that it is the expected 5-event JSON, posts it once, and
  removes the temporary directory on exit. It never reads a local `examples/guitar-five.json`
  or writes `guitar-five.json` into the working directory. Expected: 5 events, 1 country,
  2 places, 3 in Tokyo and 2 in Osaka.
- **Your own list** — turns places into the JSON contract in [`API.md`](API.md), using real
  sources and verifiable locations. Saves a local draft by default; posts only on an explicit
  publish request.
- **Cover failure** — if `coverStatus` is `"failed"`, it returns the working map link and does
  not resubmit.

**Generated maps are public by link.** Anyone with the URL can open the map and follow its
source links. Do not map private addresses or unpublished data without the user explicitly
asking for a public map.

## How the guitar run works

The exact bash block is in the skill. In short:

1. `SAMPLE_SHA=da8a6019dd6ee469e9192e88d10b1e4f67bc7fe8` fixes the sample to the verified
   commit, so later changes to `main` cannot change what is downloaded.
2. `mktemp -d` plus `trap 'rm -rf "$WORK"' EXIT` keeps the download out of the working
   directory and deletes it afterwards.
3. `curl --fail --silent --show-error --location --retry 3` turns any HTTP error into a
   non-zero exit instead of submitting an error page.
4. Python 3, Python or Node parses the file and checks `schemaVersion: 1` with 5 events
   before the `POST`.
5. `curl --fail-with-body ... --data-binary "@$WORK/guitar-five.json"` posts the file once to
   `POST /api/maps`.

### Windows PowerShell

Use `curl.exe` explicitly — in Windows PowerShell, plain `curl` is an alias for
`Invoke-WebRequest` and does not accept these flags. Every `curl.exe` call is followed
immediately by a `$LASTEXITCODE` check. A non-zero POST exit prints the API body and fails; a
zero exit is only treated as success when the response contains a usable `shareUrl`.
`-Encoding UTF8` is required on Windows PowerShell 5.1 for the Chinese sample.

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

## Verification status

Checked on 2026-11-18 and 2026-11-19 on Windows 11, Windows PowerShell 5.1, Claude Code
2.1.327 and the production site `https://me-interest-globe.netlify.app/`.

| Check | Result | Evidence |
| --- | --- | --- |
| Claude Code reads the skill file | **Passed** | `claude plugin validate .claude/skills` → `Validation passed` |
| Claude Code discovers the revised skill | **Passed** | the session listing showed `earth: Turn places into a ME · My Earth map…` |
| Claude Code expands `/earth` | **Passed** | `/earth 整理去年全家去过的三个地方，先给我草稿` produced `<command-name>/earth</command-name>` and injected the revised body, including “Draft or publish?” |
| Claude Code personal install | **Passed** | the revised file was copied to `~/.claude/skills/earth/`; the run reported that directory as the skill base |
| Claude Code with a real model | **Not tested** | no Anthropic credentials on this machine; the session above used a local stub that logs the request |
| Cursor install / discovery / invocation | **Not tested** | Cursor is not installed on this machine; the shared path is taken from Cursor's documented compatibility list |
| Decoy-file regression | **Passed** | unrelated temp dir with `guitar-five.json` and `examples/guitar-five.json`; the mock received the official sample's exact SHA-256 and both decoys were unchanged |
| Draft / publish split | **Passed** (API side) | draft run sent 0 POSTs; publishing the same draft sent exactly 1 POST |
| Cover failure | **Passed** | 1 POST, `coverStatus: "failed"`, `previewImageUrl: null`, working `shareUrl`, no resubmit |
| PowerShell route | **Passed** | Windows PowerShell 5.1: download 404 → exit 1 / 0 POST; POST 400 & 429 → exit 1 with the API body; cover ready & failed → exit 0 with `shareUrl` |
| Live public API run | **Passed** | map [`UL0F3dsh60WHnMEx6m1aXRK4`](https://me-interest-globe.netlify.app/?map=UL0F3dsh60WHnMEx6m1aXRK4&lang=en&welcome=0) · 5 events / 1 country / 2 places · cover `ready` |

### Regression evidence

The decoy test ran from `%TEMP%\unrelated-places-*`, not from this repository:

- Local `guitar-five.json` and `examples/guitar-five.json` both contained titles beginning
  `DECOY …`. The mock API received the official sample instead, with SHA-256
  `62a7833a7f60772eede30fbc606952017ab7f125ecd9d6bd147f64dac824e54b`, title
  `日本中古电吉他店 5 选（东京・大阪）`, 5 events / 1 country / 2 places.
- Both local files kept their original bytes and hashes.
- The skill's temporary directory was empty after the run; no `guitar-five.json` appeared in
  the working directory.

The draft/publish and cover-failure checks used the same mock server and counted requests:
draft = 0 new POSTs, publish = 1 POST, cover failure = 1 POST with the link preserved. These
are API-path checks; choosing draft vs publish in a real conversation is the pending
real-model item.

### PowerShell regression (2026-11-19)

The PowerShell block from this file ran as-is under Windows PowerShell 5.1. Only `$base` was
pointed at a counting mock; the download-404 case also replaced `$url` with a missing URL.

| Case | Exit | POSTs | Result |
| --- | --- | --- | --- |
| Download 404 | 1 | **0** | Stops with `Sample download failed (curl exit 22)`; never reaches the POST |
| POST 400 JSON | 1 | 1 | `Map creation failed (curl exit 22)` plus the API body, including the `events[0].summary` field path and `summary is required` |
| POST 429 JSON | 1 | 1 | Exit 1 with the API body and `Too many maps created` |
| Cover ready | 0 | 1 | Prints the map JSON; usable `shareUrl` and cover |
| Cover failed | 0 | 1 | Prints the map JSON; usable `shareUrl`, `previewImageUrl: null`, `coverStatus: "failed"` |
| 2xx without `shareUrl` | 1 | 1 | `Map creation result is unconfirmed: no shareUrl` and no retry |

The read uses `-Encoding UTF8`; every `curl.exe` call is followed immediately by a
`$LASTEXITCODE` check, and the temporary directory is removed in `finally`.

### Live example

The live run used the exact skill block and a fixed-commit download. It created a separate
map rather than reusing the curated example:

- Map: <https://me-interest-globe.netlify.app/?map=UL0F3dsh60WHnMEx6m1aXRK4&lang=en&welcome=0>
- Cover: <https://me-interest-globe.netlify.app/api/covers/v2/UL0F3dsh60WHnMEx6m1aXRK4.png>

The curated site example remains
<https://me-interest-globe.netlify.app/?map=jfAgs96uMi02v65ipLSfCF4l&lang=en&welcome=0>.

## Pending

- A real-model run in Claude Code (needs an authenticated session): draft vs publish choice,
  plus the guitar prompt end to end.
- A Cursor run: install, `/` menu discovery, `/earth` and both prompts.
- Re-check both clients and the fixed sample URL when the public base URL changes.
- Photos and videos are not part of the current contract; only places, dates, text and
  source links are supported.
