# 🚀 快速安装与运行指南

## 前提条件

- **Godot 4.3+** 已安装
  - macOS: `brew install godot` 或下载 https://godotengine.org/download
  - 验证: `godot --version` 应显示 4.3.x 或更高

---

## 安装步骤（2分钟）

### 1. 克隆仓库
```bash
git clone https://github.com/sharelgx/pixel-claw.git
cd pixel-claw
```

### 2. 导入 Godot
1. 打开 **Godot Engine**
2. 点击 **Import**
3. 导航到项目文件夹 `pixel-claw`
4. 选择 `project.godot`
5. 点击 **Import & Edit**

### 3. 运行游戏
- 按 **F6** 或点击顶部 ▶️ 按钮
- 游戏窗口弹出，开始看到3个彩色方块（agent）在办公室移动！

---

## 🎮 操作指南

| 按键 | 功能 |
|-----|------|
| **1, 2, 3, 4, 5** | 切换到对应楼层（1F-5F） |
| **空格 Space** | 时间加速（1x → 2x → 5x → 暂停） |
| **F12** | 打开调试控制台（查看命令） |

**鼠标：**
- 移动查看Agent头顶的思想气泡
- 思想气泡显示当前任务或状态（如 💼 创建像素办公室原型）

---

## 🔌 连接真实 OpenClaw（可选）

默认使用模拟数据（4个演示任务）。要同步真实任务状态：

### 编辑配置文件
打开 `config/settings.json`，修改：
```json
{
  "openclaw": {
    "enabled": true,
    "task_board_path": "/Users/liulaoshi/.openclaw/workspace-feishu/shared/TASK_BOARD.md",
    "sync_mode": "file_watch"
  }
}
```

### 重启游戏
游戏会读取真实 `TASK_BOARD.md`，Agent 会反映实际任务：
- 贾维斯（蓝色，2F）：处理飞书消息
- 克拉瑞（粉色，2F）：执行脚本
- 小远（红色，3F）：代码探索

---

## 🐛 故障排除

**Q: 运行后窗口空白？**
A: 检查主场景是否设置正确。在 Godot 中，右键 `scenes/main.tscn` → "Set as Main Scene"。

**Q: 出现错误 "Invalid assignment of property or key 'rect_size'"?**
A: 这说明 Godot 缓存了旧配置。删除项目根目录的 `.godot` 文件夹，重新导入。

**Q: Agent 不移动？**
A: 确保没有暂停。检查右下角是否有暂停图标。按 **F6** 重新运行。

**Q: 如何在 Mac 上安装 Godot？**
```bash
brew install godot
```
或下载 dmg 拖到 Applications。

---

## 📊 当前状态

- ✅ 所有 3 个 Agent 正常运行
- ✅ 思想气泡显示任务标题
- ✅ 楼层切换正常
- ✅ 任务板解析（模拟 + 真实文件）
- ✅ 60 FPS 流畅运行

---

## 🎯 下一步开发

- [ ] 像素美术素材（替换方块）
- [ ] 点击 Agent 交互
- [ ] 任务板可视化（墙上贴纸）
- [ ] 音效和音乐

详见 [ROADMAP.md](ROADMAP.md)

---

**祝玩得开心！** 🎮
