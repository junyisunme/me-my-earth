# Agent 入口

这是 **ME · My Earth 的公开产品页仓库**：包含可直接打开的地图、三张示例地图、桌面壁纸导入物、演示下载、公开 API 示例、QS 2027 封面与首屏动图，以及 Claude Code / Cursor 的 `earth` 建图技能；不包含应用源码、构建脚本或内部验收记录。

第一次接触，先读 [`docs/AGENT_WORKFLOWS.md`](docs/AGENT_WORKFLOWS.md)。按用户意图选一条：

- 打开/分享地图 → 直接用公网地图链接，见指南 §1
- 给 Claude Code / Cursor 装建图技能 → `.claude/skills/earth/SKILL.md`，安装与验收见 [`docs/SKILL.md`](docs/SKILL.md)
- 放到桌面 → `wallpapers/` 下的 Lively / Wallpaper Engine 导入物，见指南 §2
- 放进演示 → `downloads/` 的 PPTX / PDF 和 `assets/qs-2027-cover-v2.png`，见指南 §3
- 新建地图 → `examples/guitar-five.json` + 公开 `POST /api/maps`；用户自有清单默认只出本地草稿，明确要求公开链接时才提交，见指南 §4
- 换图标/配色 → 公开的 `examples/art-packs/qs-warm-paper/` 清单格式说明；本地导入/预览需要应用源码，不在本仓库

不要声称本仓库能 `pnpm dev` 或运行本地素材导入；这些能力在应用仓库中。公开预览是 **Deploy Preview**，不是生产站。
