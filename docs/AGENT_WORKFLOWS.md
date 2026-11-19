# Agent 工作流（公开仓库）

最后核对：2026-11-18。这个仓库是 **ME · My Earth 的公开产品页**，不含应用源码；下面只列本仓库能直接完成或明确不能完成的工作流。

| 用户意图 | 入口 | 产物 |
| --- | --- | --- |
| 给 Claude Code / Cursor 安装建图技能 | [§0](#0-安装-earth-skill) | `/earth` 命令 + 地图链接 |
| 打开 / 分享一张现成地图 | [§1](#1-打开或分享现有地图) | 普通地图 URL |
| 把地图放到 Windows / Mac 桌面 | [§2](#2-把地图放到桌面) | `display=wallpaper`、Lively / Wallpaper Engine 导入物 |
| 把地图放进演示 | [§3](#3-把地图放进演示) | PPTX、PDF、PNG + 普通互动链接 |
| 新建一张用户地图 | [§4](#4-新建一张用户地图) | `?map=<mapId>` 分享链接 + 封面 |
| 用照片/视频做本地地图 | [§7](#7-照片视频地图me-agent) | `.mezip` + 16:9 PNG + Lively 项目 |
| 换图标 / 配色 | [§5](#5-换图标--配色公开示例) | `me-art-pack-1` 示例清单；本地运行需应用源码 |
| 查看验收状态 | [§6](#6-验收状态) | 通过项与待验项 |

## 0. 安装 earth skill

技能文件只有一份：[`../.claude/skills/earth/SKILL.md`](../.claude/skills/earth/SKILL.md)。Claude Code 和 Cursor 都读这个路径，所以不用维护两份。

```bash
mkdir -p ~/.claude/skills/earth
curl -L -o ~/.claude/skills/earth/SKILL.md \
  https://raw.githubusercontent.com/junyisunme/me-my-earth/main/.claude/skills/earth/SKILL.md
```

装完在 Claude Code 里 `/skills` 能看到 `earth`，用 `/earth` 调用；Cursor 在 Agent chat 里输入 `/` 选 `earth`。完整安装、验收记录和待测项见 [`docs/SKILL.md`](SKILL.md)。

**边界**：技能只调用公开 `POST /api/maps`，不需要账号、API key 或私有 Core；生成的地图按链接公开可访问。

## 1. 打开或分享现有地图

```text
普通分享：/?map=<mapId>&lang=en&welcome=0
按专题：  /?topic=qs-2027&welcome=0
```

示例：

- QS 2027：<https://me-interest-globe.netlify.app/?map=5_sK-fhDyYpuTLldqT3wqvnc&lang=en&welcome=0>
- Ski：<https://me-interest-globe.netlify.app/?map=0rbCDSfP_OyKwkvhMI6yza9D&lang=en&welcome=0>
- Oil：<https://me-interest-globe.netlify.app/?map=nMaS9Wsvb0h6-CYdJ9iXUZ3E&lang=en&welcome=0>

**边界**：这些是普通互动地图，页头/图例/Index 都在；不是壁纸布局。QS 公开案例是 100 条记录 / 102 所学校 / 21 个展示国家/地区，不是内置 QS 2027 的 50 所专题。

## 2. 把地图放到桌面

### 2.1 完整链接

**桌面壁纸请直接使用下方完整链接。`display=wallpaper` 需要部署版本支持。**

```text
https://6afd84eacabd8cf0c94443a1--me-interest-globe.netlify.app/?map=5_sK-fhDyYpuTLldqT3wqvnc&lang=en&welcome=0&display=wallpaper
```

- 极简 dock：Board map / Satellite / Index。
- 3 秒空闲暂停；指针/滚轮/键盘/切主题/resize 唤醒。
- 拖动松手后 300 ms 内忽略误触，避免拖地球后误进国家。
- 普通分享链接（不带 `display`）行为不变；正式站现在同时支持创建地图、打开地图包和旧 QS 分享链接。
- 旧版 `6afc8b58…` 快照仍可打开，但公开文档和演示统一使用正式站 `https://me-interest-globe.netlify.app/`。

**本次确认支持壁纸模式的固定 Deploy Preview（试用地址，不是生产站）**：

<https://6afd84eacabd8cf0c94443a1--me-interest-globe.netlify.app/?map=5_sK-fhDyYpuTLldqT3wqvnc&lang=en&welcome=0&display=wallpaper>

### 2.2 Lively Wallpaper

导入目录：[`wallpapers/lively/qs-2027/`](../wallpapers/lively/qs-2027)

- `index.html` 用 `location.replace` 保留完整查询串；`LivelyInfo.json` 指向同一入口；`thumbnail.png` 为封面。
- 在 Lively 里添加网页壁纸，选择 `index.html`（或整个文件夹）。
- **不要用 Lively 的“输入网址”**：它会丢查询串。
- 桌面图标可见时，Lively 的图标层可能和壁纸拖拽竞争；完整拖动可先隐藏图标。

### 2.3 Wallpaper Engine

导入目录：[`wallpapers/wallpaper-engine/qs-2027/`](../wallpapers/wallpaper-engine/qs-2027)

- `index.html` 顶层跳转；`project.json` 含 `type: web`、`general.mousehighlight: true` 和标题。
- 推荐 **打开壁纸** 选 `project.json`；或编辑器“创建壁纸”选 `index.html`，预览黑屏时点 **查看 → 重启预览**。
- 编辑器生成的工程如果缺少 `mousehighlight`，用目录里的 `project.json` 补上。

实测（Windows 2560×1440，Wallpaper Engine 2.8.42）：

| 项目 | 结果 |
| --- | --- |
| 桌面图标可见 | 通过 |
| 极简 dock | 通过 |
| Satellite / Board map 主题 | 通过（Satellite 真实鼠标点击；Board map 用壁纸 DOM Toggle） |
| 真实鼠标拖动 / 松手 | 通过；静置 6 秒后首次拖动生效 |
| Singapore → NUS | 通过（桌面壁纸 DOM 的 Accessibility Invoke；未用屏幕坐标点 NUS 圆点） |
| 桌面空白处框选 / 测试图标打开 | 通过；框选时地球会跟着转，但不阻止选择 |
| 滚轮 | **未通过**：上滚 3 格没有改变地球缩放 |
| 原壁纸恢复 | 通过 |

完整报告：[`docs/WALLPAPER_ENGINE.md`](WALLPAPER_ENGINE.md)。**Mac 原生 Safari 与 Plash 仍待真机手测**；Lively 的桌面输入竞争见仓库 README 的 Lively 节。

### 2.4 Plash（Mac，待真机）

把带 `display=wallpaper` 的完整 URL 作为网页壁纸打开，允许交互，再按同一张表检查 dock、拖动、Singapore → NUS 和空闲唤醒。本仓库没有 Mac 端实测结果。

## 3. 把地图放进演示

- [PPTX](../downloads/me-my-earth-qs-2027-demo.pptx)
- [PDF](../downloads/me-my-earth-qs-2027-demo.pdf)
- [1200×630 PNG](../assets/qs-2027-cover-v2.png)

打开的是**普通互动地图**，不是壁纸模式：

<https://me-interest-globe.netlify.app/?map=5_sK-fhDyYpuTLldqT3wqvnc&lang=en&welcome=0>

**Canva**：上传 PNG 作为整页/封面图，再给图片加同一个互动地图链接；Canva 内需要再点一次验证。

实际平台状态：

- PPTX / PDF：链接结构已验证（关系 + PDF `/URI` 指向同一 URL）；PowerPoint 桌面版本机未安装，网页版未登录。
- Canva：本机无账号；PNG + URL 已提供，未做平台内点击。
- 演示步骤：Singapore → NUS（rank 10）或 NTU。

## 4. 新建一张用户地图

四张现成示例（QS、滑雪、石油、吉他店）在 [`examples/`](../examples) 一页打开。用公开示例 [`examples/guitar-five.json`](../examples/guitar-five.json) 建图：

```bash
curl -L -o guitar-five.json \
  https://raw.githubusercontent.com/junyisunme/me-my-earth/main/examples/guitar-five.json

curl -X POST "https://me-interest-globe.netlify.app/api/maps" \
  -H "Content-Type: application/json" \
  --data-binary @guitar-five.json
```

预期响应：

```json
{
  "mapId": "…",
  "shareUrl": "https://…/?map=…",
  "eventCount": 5,
  "countryCount": 1,
  "cityCount": 2,
  "previewImageUrl": "https://…/api/covers/v2/….png",
  "coverStatus": "ready"
}
```

预期首屏：东京 3 家、大阪 2 家。字段和错误码见 [`docs/API.md`](API.md)。

**用户自己的清单**：只说「整理」「生成草稿」「给我 JSON」时，只写本地 JSON，不调用 `POST /api/maps`；明确说「生成公开分享链接」「发布」时才提交一次。提交后地图按链接公开可访问；封面失败也保留 `shareUrl`，不要重复提交。完整命令和 PowerShell 用法见 [`docs/SKILL.md`](SKILL.md)。

现成吉他店地图：<https://me-interest-globe.netlify.app/?map=jfAgs96uMi02v65ipLSfCF4l&lang=en&welcome=0>（同一个 JSON，可下载、修改、重新上传，见示例页）。

**边界**：公开 API 是站点功能；本仓库不包含 `/api` 函数源码，也不负责数据持久化。

## 5. 换图标 / 配色（公开示例）

公开示例清单：[`examples/art-packs/qs-warm-paper/`](../examples/art-packs/qs-warm-paper)（`me-art-pack.json` + 透明 PNG，CC0）。

`me-art-pack-1` 的最小结构：

```json
{
  "schema": "me-art-pack-1",
  "id": "my-pack",
  "name": "My pack",
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

类别键用项目实际值：`universities`、`michelin`、`michelin.1/2/3`、`map`、`list`；也接受 `专题键.<facet>`。图标是透明 PNG/WebP，建议 128×128，16–512 px，单张 <2 MB。

**重要边界**：本公开仓库**不包含应用源码和本地预览 CLI**，所以不能在这里执行 `import`、`export`、`publish` 或 `packSource=local` 预览。这里的示例用于说明清单格式和可公开分发的资产；完整的“原始 PNG → 本地 import → 预览 → 恢复默认 → 导出/重导入”流程在维护者的应用仓库中运行，不随本展示仓库发布。不要把本仓库误当成可直接运行的应用。

## 6. 验收状态

| 项目 | 结果 | 备注 |
| --- | --- | --- |
| 公开地图 QS / Ski / Oil | 已实测 | 公网 Deploy Preview |
| 四张示例地图 + 吉他 JSON 下载/重传 | 已实测 | [`examples/`](../examples)；重传走公开 `POST /api/maps`，封面 1200×630 |
| `earth` skill — 固定提交 / 同名文件 / 草稿与发布 | 通过（API 侧） | 官方样例 SHA 一致；两个同名诱饵未变；草稿 0 次 POST，发布 1 次 |
| `earth` skill — Claude Code 技能校验 | 通过 | `claude plugin validate .claude/skills`（2.1.327） |
| `earth` skill — Claude Code 发现与 `/earth` 调用 | 通过（本地桩模型） | 2.1.327；真实模型调用待账号 |
| `earth` skill — Cursor | **待客户端** | 本机未安装 Cursor；共用 `.claude/skills/` 路径见 Cursor 官方兼容列表 |
| Wallpaper Engine 桌面 | 通过项见 §2.3 | **滚轮未通过**；Singapore → NUS 走 DOM |
| Lively | 已实测（旧轮次） | 桌面图标层与拖拽竞争；建议隐藏图标后做完整拖动 |
| Mac Safari / Plash | **待真机** | 本机无 Mac |
| PowerPoint 桌面版 / 网页版 | **待对应环境** | 链接结构已验证 |
| Canva | **待账号** | PNG + URL 已提供 |

公开预览是固定 Deploy Preview，不是生产站；生产站仍可能是旧版。链接或部署轮换后需要更新本页和壁纸包装。

## 7. 照片/视频地图（me-agent）

用户给照片、短视频和一句建图请求时，使用独立的本地工具 `me-agent`。它把媒体按 `recordId` 绑定到地点记录，生成 `.mezip`，并从同一份地图导出 16:9 PNG；Windows 上可实际设置 Lively 壁纸。

- 安装与完整说明：[`agent/README.md`](../agent/README.md)
- 工具下载：[`me-agent-0.3.0.zip`](https://github.com/junyisunme/me-my-earth/releases/download/v0.3.0/me-agent-0.3.0.zip)
- 示例：[`agent/examples/japan-cities/`](../agent/examples/japan-cities)
- 查看器：<https://me-interest-globe.netlify.app/?welcome=0>

最短命令：

```bash
node me-agent.mjs build --brief examples/japan-cities/japan-cities.json --out-dir out --package-name japan-cities.mezip --slide
node me-agent.mjs desktop --package out/japan-cities.mezip --out-dir out --wallpaper-name "日本城市素材示例 · ME" --apply
```

**边界**：`.mezip` 默认只在本机；本工具不会调用公开 `POST /api/maps`，也不会自动发布。只有用户明确要求公开链接时，才继续用 §4 的公开建图流程。桌面模式依赖 `127.0.0.1` 本地查看器；退出 Lively 可恢复原静态壁纸。
