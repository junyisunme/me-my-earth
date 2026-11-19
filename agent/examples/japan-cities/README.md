# 日本城市素材示例

这是一份可直接运行的 Agent 输入：

- 京都记录 → `photos/kyoto-day2.jpg`（合成灯笼小巷照片）
- 东京记录 → `video/test-clip.mp4`（MDN CC0 `flower.mp4`）+ `photos/tokyo-video-cover.jpg`

运行：

```bash
node me-agent.mjs build \
  --brief examples/japan-cities/japan-cities.json \
  --out-dir out \
  --package-name japan-cities.mezip \
  --slide
```

生成：

```text
out/japan-cities.mezip
out/japan-cities-slide-16x9.png
out/japan-cities-report.json
```

再设成 Windows 桌面：

```bash
node me-agent.mjs desktop \
  --package out/japan-cities.mezip \
  --out-dir out \
  --wallpaper-name "日本城市素材示例 · ME" \
  --apply
```

照片和视频只在本机处理。视频是 CC0 测试片段，不是东京实拍；记录文字里已经注明。
