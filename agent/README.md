# ME Agent · 照片/视频地图工具

`me-agent` 把用户选中的照片、短视频和地点记录打包成一个可在 ME 打开的 `.mezip`，并从同一份地图导出 16:9 幻灯片 PNG。它也可以生成并应用 Lively 桌面壁纸项目。

**下载**：[`me-agent-0.2.0.zip`](https://github.com/junyisunme/me-my-earth/releases/download/v0.2.0/me-agent-0.2.0.zip)  
**查看器**：<https://6afe58ca24c94fd7200013ee--me-interest-globe.netlify.app/?welcome=0>  
**示例输入**：[`examples/japan-cities/`](examples/japan-cities/)

这个工具只处理本机文件：照片、视频、地点和备注不会上传到 ME 或任何第三方。公开地图链接仍走 ME 现有的 `POST /api/maps`；本工具不会自动发布。

## 安装

需要 **Node.js 24+**。

### Windows

```powershell
$ErrorActionPreference = "Stop"
$version = "0.2.0"
$zip = Join-Path $env:TEMP "me-agent-$version.zip"
$dest = Join-Path $env:USERPROFILE "me-agent"
Invoke-WebRequest -Uri "https://github.com/junyisunme/me-my-earth/releases/download/v$version/me-agent-$version.zip" -OutFile $zip
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath (Split-Path $dest) -Force
if (Test-Path (Join-Path (Split-Path $dest) "me-agent-$version")) { Move-Item (Join-Path (Split-Path $dest) "me-agent-$version") $dest }
Push-Location $dest
npm install
Pop-Location
node "$dest\me-agent.mjs" help
```

### macOS / Linux

```bash
curl -L --fail -o /tmp/me-agent-0.2.0.zip \
  https://github.com/junyisunme/me-my-earth/releases/download/v0.2.0/me-agent-0.2.0.zip
rm -rf "$HOME/me-agent" && mkdir -p "$HOME/me-agent"
unzip -q /tmp/me-agent-0.2.0.zip -d "$HOME/me-agent"
cd "$HOME/me-agent"
npm install
node me-agent.mjs help
```

`npm install` 会安装 `sharp`、`@zip.js/zip.js` 和 `exifr`。不需要 ME 账号、API key 或 ME 私有源码。

## Agent 怎么用

1. 用户给出自然语言和**明确选中的文件**。Agent 先整理成一份 media brief：地点记录 + 每条记录要挂的照片/视频。
2. 用 `recordId` 明确绑定媒体。嵌套写在记录的 `photos`/`videos` 里，或使用顶层 `media` + `recordId`。
3. 如果文件属于哪条记录不明确，**只问这一个缺失信息**；不要猜。
4. 调用 `me-agent build`，把返回 JSON 原样/摘要交给用户。
5. 用户追加「设成桌面」时，用同一份 `.mezip` 调 `me-agent desktop --apply`；不要重新建包。
6. 用户要幻灯片时加 `--slide`；只交付 PNG，或用已有 Office 能力插入指定页码。

### 最小命令

```bash
node me-agent.mjs build \
  --brief examples/japan-cities/japan-cities.json \
  --out-dir out \
  --package-name japan-cities.mezip \
  --slide
```

输出：

```text
out/japan-cities.mezip
out/japan-cities-slide-16x9.png
out/japan-cities-report.json
```

### 加桌面壁纸

```bash
node me-agent.mjs desktop \
  --package out/japan-cities.mezip \
  --out-dir out \
  --wallpaper-name "日本城市素材示例 · ME" \
  --apply
```

- Windows 且已安装 Lively Wallpaper 时，`--apply` 会实际把壁纸应用到主屏（`--monitor 1` 可改）。
- 其他环境返回 `status: "project-ready"`，并给出可导入的 Lively 项目路径和命令。
- 桌面模式依赖本机回环查看器；`desktop` 输出里的 `serverCommand` 可重启它。退出 Lively 可恢复原静态壁纸；原来选中的 Lively 项目不会被删除。

## 输入格式

```json
{
  "schema": "me-map-package-input-1",
  "title": "旅行回忆 · 京都与东京",
  "records": [
    {
      "id": "kyoto-photo",
      "title": "京都 · 灯笼小巷",
      "note": "用户提供的照片，绑定到京都记录。",
      "date": "2026-11-18",
      "locations": [
        {
          "countryId": "JPN",
          "precision": "city",
          "placeId": "jpn-kyoto",
          "label": "京都 · 先斗町",
          "reason": "照片拍摄于京都。"
        }
      ],
      "photos": [
        { "file": "examples/japan-cities/photos/kyoto-day2.jpg", "caption": "京都 · 灯笼小巷" }
      ]
    },
    {
      "id": "tokyo-video",
      "title": "东京 · 街头短片",
      "note": "用户提供的短视频，绑定到东京记录。",
      "date": "2026-11-18",
      "locations": [
        {
          "countryId": "JPN",
          "precision": "city",
          "placeId": "jpn-tokyo",
          "label": "东京 · 御茶之水",
          "reason": "短视频放在东京记录。"
        }
      ],
      "videos": [
        {
          "file": "examples/japan-cities/video/test-clip.mp4",
          "cover": "examples/japan-cities/photos/tokyo-video-cover.jpg",
          "caption": "东京记录 · 测试短片（CC0）"
        }
      ]
    }
  ]
}
```

- `file` / `cover` 相对 brief 文件所在目录，也可以给绝对路径。
- `id` 成为媒体绑定的 `recordId`；同一地点的两条记录可以各带自己的媒体。
- 日期、备注、`reason`、`placeId` 都可选；`countryId` 和 `label` 必填。`precision` 省略时按 `placeId`/坐标推断。
- 顶层扁平写法：`"media": [{ "recordId": "kyoto-photo", "kind": "photo", "file": "..." }]`。**扁平写法必须带 `recordId`**；缺了会返回 `media_mapping_missing` 和候选记录列表。

## 支持的媒体

| 媒体 | 输入 | 处理 |
| --- | --- | --- |
| 照片 | JPEG、PNG | EXIF 朝向转正；480 px 缩略图 + 1600 px 查看图；导出副本移除 EXIF/GPS |
| 视频 | MP4（H.264 + AAC，或无音轨） | 原样复制；可选封面；容器元数据不剥离，检测到 `udta`/`©xyz` 会写入 warning |
| 封面 | JPEG、PNG | 生成 640–800 px JPEG |

其他格式（HEIC、MOV、WebM、HEVC）会返回具体跳过原因，不阻断已能用的地图。超大视频（>512 MB）或照片处理失败也会记录在 `skipped[]`。

## 返回结果

```json
{
  "ok": true,
  "outputs": {
    "map": {
      "status": "created",
      "packagePath": "D:\\work\\out\\japan-cities.mezip",
      "recordCount": 2,
      "photoCount": 1,
      "videoCount": 1,
      "skipped": [],
      "viewer": {
        "openUrl": "https://6afe58ca24c94fd7200013ee--me-interest-globe.netlify.app/?welcome=0",
        "howToOpen": "Open the viewer, click 打开地图包, choose japan-cities.mezip"
      }
    },
    "slide": { "status": "created", "pngPath": "D:\\work\\out\\japan-cities-slide-16x9.png", "width": 1600, "height": 900 },
    "desktop": { "status": "not-requested" }
  },
  "completed": ["map-created", "map-verified", "slide-created"],
  "reportPath": "D:\\work\\out\\japan-cities-report.json"
}
```

`completed` 是 Agent 汇报的事实依据：

- `map-created` / `map-verified`：包已生成并通过 `verify --read-media`；
- `slide-created`：16:9 PNG 已生成；
- `wallpaper-project-created`：Lively 项目已生成；
- `wallpaper-applied`：**已经实际切换** Lively 壁纸。

`desktop.status` 可能是 `applied`、`project-ready`、`failed` 或 `not-requested`。`project-ready` 不等于已应用，必须如实告诉用户。

## 错误与跳过

| code / 字段 | 含义 | Agent 应该做什么 |
| --- | --- | --- |
| `media_mapping_missing` | 扁平 media 缺 `recordId` | 问用户每个文件属于哪条记录 |
| `file_not_found` | 明确列出的文件不存在 | 让用户重新选择/确认路径 |
| `unsupported_photo_format` / `unsupported_video_codec` | 素材格式不支持 | 报告具体文件和原因；其余素材仍可打包 |
| `missing_coordinates` / `unknown_country` | 地点缺坐标或国家 ID 无效 | 补齐地点信息后重试 |
| `strict_failed` | 使用 `--strict` 且有跳过项 | 汇报跳过项，询问是否保留 |
| `viewer_start_failed` | 本地查看器未启动 | 检查端口/日志，不要谎称壁纸已应用 |
| `desktop.status=failed` | Lively 应用失败 | 地图包仍然可用；给出项目路径和恢复步骤 |

跳过项在 `skipped[]` 里带 `file`、`reason`、`message`；视频元数据警告在 `warnings[]`。Agent 必须把这两个数组转述给用户。

## 查看与分享

- **本地打开**：打开查看器 URL，点 **打开地图包**，选择 `.mezip`。照片缩略图/视频封面在打开记录时才读取，查看图在放大时才读取，视频在点播放时才读取。
- **发给别人**：把 `.mezip` 和查看器 URL 一起给对方；对方用同版查看器打开。私人地图包不需要公开 `mapId`。
- **公开发布**：本工具不发布。用户明确要求公开链接时，继续使用 ME 现有 `POST /api/maps` 流程（文本地图），不要把 `.mezip` 上传到公开服务。
- **PPT / Canva**：使用 `--slide` 生成的 1600×900 PNG。它是从同一张地图的封面渲染器生成的，不依赖公开 `mapId`。

## 隐私

- 所有媒体处理、封面渲染和 16:9 合成都在本机完成。
- Lively 本地查看器只监听 `127.0.0.1`，只提供选定的 `.mezip` 和查看器资源。
- 公开查看器只提供程序；打开私人 `.mezip` 时文件仍由浏览器本地读取，不上传。
- 只有显式调用 ME 的公开建图 API 才会产生公开地图；本工具没有这个调用。

## 版本

- 工具版本：`0.2.0`
- 查看器：`https://6afe58ca24c94fd7200013ee--me-interest-globe.netlify.app/`
- 示例：`examples/japan-cities/`（合成照片 + MDN CC0 `flower.mp4`）
