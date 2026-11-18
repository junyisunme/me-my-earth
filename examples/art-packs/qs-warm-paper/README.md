# QS Warm Paper — public art-pack example

This is a minimal, public `me-art-pack-1` example: a transparent 128×128 university icon plus a warm-paper palette. The icon is CC0; see [`SOURCE.md`](SOURCE.md).

Files:

```text
qs-warm-paper/
  me-art-pack.json
  icons/university.png
  SOURCE.md
```

The manifest uses the project category key `universities`. See [`docs/ART_PACKS.md`](../../../docs/ART_PACKS.md) for the schema.

**Boundary:** this repository is the public product page and does not include the application source or the local `import`/`preview` CLI. The full local workflow (`raw PNG → Agent writes manifest → .local import → packSource=local preview → restore → export/re-import → publish`) runs in the separate application repository. Do not expect `pnpm dev` or `node scripts/art-pack.mjs` to work in this checkout.
