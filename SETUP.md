# 🚀 快速启动指南

欢迎来到 OpenClaw 像素办公室！本指南将帮你在 5 分钟内运行游戏。

---

## 1️⃣ 安装 Godot

1. 访问 https://godotengine.org/download
2. 下载 **Godot 4.3+**（标准版，64位）
3. 解压并运行 `Godot.app`

---

## 2️⃣ 导入项目

1. 打开 Godot
2. 点击 **"Import"**
3. 导航到本项目文件夹，选择 `project.godot`
4. 点击 **"Import & Edit"**

---

## 3️⃣ 运行项目

- 按 **F6**（或点击顶部 play 按钮▶️）
- 如果看到小方块（agent）在移动，恭喜你成功了！

---

## 🎮 游戏控制

| 按键 | 功能 |
|-----|------|
| **1, 2, 3, 4, 5** | 切换到对应楼层 |
| **空格 Space** | 时间加速（1x → 2x → 5x → 暂停） |
| **~ (波浪键)** | 打开调试控制台（查看命令） |
| **ESC** | 退出运行 |

**鼠标操作：**
- 移动鼠标查看各 Agent 头顶的想法气泡
- 点击 Agent 查看详情（未来功能）

---

## 📂 项目结构说明

```
openclaw-pixel-office/
├── scenes/
│   ├── main.gd           # 主场景逻辑
│   ├── main.tscn         # 主场景文件
│   └── ui_layer.tscn     # UI 界面
├── scripts/
│   ├── agents/           # Agent 角色（jarvis, corali, xiaoyuan）
│   ├── systems/          # 系统模块（任务板、时间、同步等）
│   └── office_base.gd    # 办公室环境生成
├── config/
│   └── settings.json     # 游戏配置
├── assets/               # 存放图片、音效（可自行添加）
└── project.godot         # Godot 项目配置
```

---

## ⚙️ 连接真实 OpenClaw（可选）

游戏默认使用模拟数据（演示模式）。要同步真实任务状态：

1. 打开 `config/settings.json`
2. 修改：
```json
{
  "openclaw": {
    "enabled": true,
    "task_board_path": "/Users/liulaoshi/.openclaw/workspace-feishu/shared/TASK_BOARD.md",
    "sync_mode": "file_watch"
  }
}
```
3. 重启游戏，Agent 会根据真实任务状态切换动作

---

## 🎨 自定义内容

### 更换 Agent 颜色
编辑 `scripts/agents/<agent>.gd`，修改 `agent_color` 变量：

```gdscript
agent_color = Color(0.2, 0.6, 1.0)  # RGB 0-1
```

### 调整初始位置
修改 `home_position`：

```gdscript
home_position = Vector2(300, 200)  # x, y 像素坐标
```

### 添加新 Agent
1. 在 `scripts/agents/` 创建新 `.gd` 文件
2. 继承 `Agent` 类
```gdscript
extends Agent

func _ready() -> void:
	agent_id = "my-new-agent"
	agent_name = "新员工"
	display_name = "NewBee"
	agent_color = Color(1.0, 1.0, 0.0)  # 黄色
	home_floor = 3
	home_position = Vector2(500, 300)
```
3. 在 `scenes/main.gd` 的 `_spawn_agents()` 里添加

---

## 🐛 常见问题

**Q: 运行后窗口一片空白？**
A: 检查是否选中了 `main.tscn` 作为主场景。在 Godot 项目面板，右键 `scenes/main.tscn` → "Set as Main Scene"。

**Q: Agent 不移动？**
A: 确保 `main.tscn` 根节点是 `Node2D`，已经挂载 `main.gd` 脚本。查看输出面板是否有错误。

**Q: 如何生成像素素材来替换方块？**
A: 推荐使用 [Aseprite](https://www.aseprite.org/) 绘制 16x16 图片，导入 Godot 后替换 `scripts/agents/agent_base.gd` 中的 `ColorRect` 为 `Sprite2D`。

**Q: 任务板不显示内容？**
A: 默认使用模拟数据。如需连接真实 TASK_BOARD.md，请按上述"连接真实 OpenClaw"步骤配置。

---

## 🚧 项目状态

**当前版本：** v0.1.0-dev (原型阶段)

**已完成：**
- ✅ 基础楼层渲染
- ✅ 3 个 Agent 可移动
- ✅ 时间系统和楼层切换
- ✅ 任务板读取（模拟+真实文件）

**待实现：**
- [ ] 像素美术资源（角色、家具）
- [ ] 思想气泡完善（显示真实任务）
- [ ] WebSocket 实时同步
- [ ] 玩家交互（点击 Agent 菜单）
- [ ] 成就系统
- [ ] 音效和音乐

---

## 🎯 下一步

1. **熟悉 Godot**：[官方入门教程](https://docs.godotengine.org/index.html)
2. **修改配置**：调整 `config/settings.json` 到你的 OpenClaw 路径
3. **添加美术**：替换方块为像素画
4. **自定义角色**：给你的 agents 加上专属动作

---

## 💬 获取帮助

- 项目 Issues：https://github.com/sharelgx/openclaw-pixel-office/issues
- OpenClaw 社区：https://discord.com/invite/clawd
- Godot 中文社区：https://godotcn.org

---

**祝你玩得开心！👋**
