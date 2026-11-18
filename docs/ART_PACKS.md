# 外观素材包（公开说明）

本仓库只公开 **`me-art-pack-1` 的清单格式和 CC0 示例**，不包含应用源码、本地导入 CLI 或预览服务。

示例：[`examples/art-packs/qs-warm-paper/`](../examples/art-packs/qs-warm-paper)

```json
{
  "schema": "me-art-pack-1",
  "id": "qs-warm-paper",
  "name": "QS Warm Paper",
  "icons": {
    "universities": { "file": "icons/university.png", "anchor": "center" }
  },
  "palette": {
    "land": "#C89B6A",
    "sea": "#173A5E",
    "border": "#3A2A1D",
    "coast": "#F1DDB6",
    "label": "#241A12",
    "labelHalo": "#F8EBD3"
  }
}
```

- 类别键：`universities`、`michelin`、`michelin.1/2/3`、`map`、`list`，也接受 `专题键.<facet>`。
- 图标：透明 PNG/WebP，建议 128×128，16–512 px，单张 <2 MB。
- 只做分类图标和拼版配色；纹理、整球贴图、自定义封面待后续。
- 完整本地流程（原始 PNG → Agent 写清单 → `.local` import → `packSource=local` 预览 → 恢复默认 → export/重导入）需要应用仓库；**本公开仓库不能运行这些命令**。
- 公开分发需显式 `publish` 到应用的 `public/data/art-packs/<id>/`，再随构建/部署上线；本地 `.local` 预览链接不能直接给外部用户。
- 示例资产声明 CC0；第三方图标/校徽需要自行确认授权。
