# The `earth` skill

One skill file turns a place list into a ME · My Earth map and returns a public map link
plus a 1200×630 cover. It uses the public API documented in [`API.md`](API.md) — no account,
no API key, no private Core checkout, no build step.

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
/earth make a map of these five guitar shops
/earth turn this list into a globe: <paste places, addresses or a ranking>
```

The skill also matches a plain request without the slash command, because its description
names the trigger phrases.

## What it does

- **Five guitar shops** — reads [`examples/guitar-five.json`](../examples/guitar-five.json),
  posts it with `POST /api/maps`, and returns the map link and cover. Expected: 5 events,
  1 country, 2 places, 3 in Tokyo and 2 in Osaka.
- **Your own list** — turns places into the JSON contract in [`API.md`](API.md), using real
  sources and verifiable locations, then posts it the same way.
- **Cover failure** — if `coverStatus` is `"failed"`, it returns the working map link and does
  not resubmit.

**Generated maps are public by link.** Anyone with the URL can open the map and follow its
source links. Do not map private addresses or unpublished data.

## Verification status

Checked on 2026-11-18 on Windows 11 with the public Deploy Preview.

| Check | Result | Evidence |
| --- | --- | --- |
| Claude Code CLI reads the skill file | **Passed** | `claude plugin validate .claude/skills` → `Validation passed` (Claude Code 2.1.327) |
| Claude Code discovers the project skill | **Passed** | session system-reminder listed `earth` with its description |
| Claude Code expands `/earth` | **Passed** | `/earth` produced `<command-name>/earth</command-name>` and injected the full SKILL.md body |
| Claude Code personal install | **Passed** | copied to `~/.claude/skills/earth/`; a run from a non-repo directory reported `Base directory for this skill: …\.claude\skills\earth` |
| Claude Code with a real model | **Not tested** | no Anthropic credentials on this machine; the runs above used a local stub that answers the API and logs the request |
| Cursor install / discovery / invocation | **Not tested** | Cursor is not installed on this machine; the shared path is taken from Cursor's documented compatibility list |
| The guitar workflow itself (download → POST → link + cover) | **Passed** | route 1 used the skill's download and POST commands; route 2 used the same `curl -X POST`; responses and covers checked below |

The two session checks used Claude Code's real binary with `ANTHROPIC_BASE_URL` pointed at a
localhost stub, so no model was called and no map was created by the model. The skill file,
its frontmatter, its discovery and its `/earth` expansion were all produced by the real
client. Everything after the model turn — the `curl` download, the `POST /api/maps`, the
returned link and the cover — is verified separately against the live public API.

### Workflow evidence

Run on 2026-11-18 from the skill's own commands (`curl -L` download, `curl -X POST` to the
public API):

| Route | Result |
| --- | --- |
| Route 1 — [`examples/guitar-five.json`](../examples/guitar-five.json) | map [`4eFRrU6yMyvw5H0KfjR6qniH`](https://6afc8b581813239311ea1a4d--me-interest-globe.netlify.app/?map=4eFRrU6yMyvw5H0KfjR6qniH&lang=en&welcome=0) · cover `ready` · 5 events / 1 country / 2 places · map and cover both `200` |
| Route 2 — a two-place own list built from verified QS records | map [`-3pGClpdZTEuXlSbP2E4keEK`](https://6afc8b581813239311ea1a4d--me-interest-globe.netlify.app/?map=-3pGClpdZTEuXlSbP2E4keEK&lang=en&welcome=0) · cover `ready` · 2 events / 1 country / 1 place |

The curated example on the site is a different map with the same guitar JSON:
<https://6afc8b581813239311ea1a4d--me-interest-globe.netlify.app/?map=jfAgs96uMi02v65ipLSfCF4l&lang=en&welcome=0>
(cover: <https://6afc8b581813239311ea1a4d--me-interest-globe.netlify.app/api/covers/v2/jfAgs96uMi02v65ipLSfCF4l.png>).
The live example pages are in [`examples/`](../examples).

## Pending

- A real-model run in Claude Code (needs an authenticated Claude Code session).
- A Cursor run: install, `/` menu discovery, `/earth` and the guitar prompt.
- Re-check both clients when the public preview base URL changes.
