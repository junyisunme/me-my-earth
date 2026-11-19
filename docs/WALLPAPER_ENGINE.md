# Wallpaper Engine 2.8.42 试用：QS 2027 壁纸

日期：2026-11-18 · 2560×1440 @180 Hz · Windows 11 Pro 26200 · Wallpaper Engine 2.8.42 Steam

结论：**环境可用，编辑器预览和 Windows 桌面均能渲染并交互**。URL 直接导入不可用；本地 `index.html` 用顶层 `location.replace` 保留完整查询串后通过。桌面图标可见、主题切换、拖动/松手、空闲唤醒、框选和测试图标打开通过；Singapore → NUS 用桌面壁纸 DOM 的 Accessibility Invoke；**滚轮未通过**。测试后已恢复原壁纸。

## 1. 导入目录

[`wallpapers/wallpaper-engine/qs-2027/`](../wallpapers/wallpaper-engine/qs-2027)

| 文件 | 作用 |
| --- | --- |
| [`index.html`](../wallpapers/wallpaper-engine/qs-2027/index.html) | 顶层跳转到完整 QS URL；保留 `map` / `lang` / `welcome` / `display=wallpaper` |
| [`project.json`](../wallpapers/wallpaper-engine/qs-2027/project.json) | `type: web`、`general.mousehighlight: true`、标题 |

正式站地址：

```text
https://me-interest-globe.netlify.app/?map=5_sK-fhDyYpuTLldqT3wqvnc&lang=en&welcome=0&display=wallpaper
```

## 2. 导入步骤

1. 打开 Wallpaper Engine 2.8.42。
2. 推荐 **打开壁纸** → 选 `project.json`；或编辑器“创建壁纸” → 选 `index.html`。
3. 若编辑器预览黑屏/灰屏，点 **查看 → 重启预览**。
4. 应用后确认 2560×1440；如果生成的 `project.json` 没有 `mousehighlight`，用交付目录的文件替换或补上。
5. 交付目录只有这两个必要文件。

## 3. 实测结果

| 项目 | 结果 | 说明 |
| --- | --- | --- |
| 编辑器预览 | 通过 | 重启预览后显示地球和 dock；窗口 1475×1100 |
| 桌面 2560×1440、图标可见 | 通过 | 图标未被遮住 |
| 极简 dock | 通过 | Board map / Satellite / Index |
| 主题切换 | 通过 | Satellite 真实鼠标点击；Board map 用壁纸 DOM Toggle |
| 拖动 / 松手 | 通过 | 静置 6 秒后第一次拖动生效；松手停住 |
| Singapore → NUS | 通过（DOM 层点击） | Singapore 国家牌 → NUS 行 → rank 10 详情；没有用屏幕坐标点 NUS 圆点 |
| 空白处框选 | 通过 | 蓝色选框；框选时地球会跟着转，但不阻止选择 |
| 测试图标打开 | 通过 | 测试 `.cmd` 显示 `ME Wallpaper Test - desktop icon open OK` |
| 滚轮 | **未通过** | 上滚 3 格没有改变缩放 |
| 原壁纸恢复 | 通过 | 恢复“Windows 正在更新” |

编辑器预览：[`assets/wallpaper-engine-editor.png`](../assets/wallpaper-engine-editor.png)

桌面裁切：[`assets/wallpaper-engine-globe.png`](../assets/wallpaper-engine-globe.png)

NUS 面板裁切：[`assets/wallpaper-engine-nus.png`](../assets/wallpaper-engine-nus.png)

> 公开仓库只放不含个人桌面图标的裁切图；完整桌面截图不提交。

## 4. 性能（对照用）

测试条件：Board map、30 FPS、Ultra preset、postprocessing ultra、MSAA x2、shadows ultra、full resolution、`safemode: true`；暂停设置为 `playbackfocus: run`、全屏/最大化 pause、电池 run、睡眠 stop。桌面图标可见，无全屏应用。

CPU 为 `wallpaper64` + 全部 `webwallpaper64` 进程的 `TotalProcessorTime` 增量，按逻辑 CPU 数归一化；GPU 为 `GPU Engine` 计数器 `engtype_3D` 的合计，不是 `nvidia-smi` 全局 GPU。空闲 13.2 秒/10 点；连续旋转 15.3 秒/10 点，真实鼠标在球面画圈。

| 阶段 | CPU（全部壁纸进程/全部逻辑核） | Wallpaper Engine 3D 平均/峰值 | 全部进程 3D 合计平均/峰值 |
| --- | --- | --- | --- |
| 空闲 | **0.00%** | **0.00% / 0.00%** | **1.17% / 1.94%** |
| 连续旋转 | **1.23%** | **0.42% / 4.15%** | **1.83% / 4.90%** |

不要直接和 Lively 的数字横比：Lively 用的是 WebView2 单核百分比和 `nvidia-smi` 全局 GPU；这里的口径不同。

## 5. 限制

- **滚轮没有传到壁纸**，本轮未修；线上页面是已部署版本。
- NUS 是用国家视图右侧的 NUS 行打开的，没有用真实鼠标直接点 NUS 圆点；真实鼠标已验证拖动和 Satellite。
- 框选时地球会跟着转；不影响框选和打开图标。
- 编辑器预览是 1475×1100，不是 2560×1440；2560×1440 以实际桌面为准。
- **Mac 原生 Safari 与 Plash 仍待真机手测**。
- 公网固定预览轮换/过期后需要更新 `index.html`；`display=wallpaper` 不能丢。
- 未发布 Steam Workshop。
