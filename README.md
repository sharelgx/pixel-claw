# 🎮 OpenClaw Pixel Office

[![Godot](https://img.shields.io/badge/Godot-4.3-478CBF?logo=godot-engine)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/sharelgx/openclaw-pixel-office)](https://github.com/sharelgx/openclaw-pixel-office/releases)

> 可视化你的 OpenClaw Agent 系统 —— 像素风格的 2D 办公室模拟游戏。

---

## 📸 截图
*(即将添加)*

---

## ✨ 特性

- 🏢 **多层办公室**：5层楼，每层对应不同部门（飞书通信、开发工坊、监控室等）
- 👥 **Agent NPC**：贾维斯、克拉瑞、小远等角色，根据真实状态自动切换动作
- 📋 **实时任务板**：同步 `TASK_BOARD.md`，任务状态变化触发游戏内动画
- ⏰ **时间系统**：1:1 真实时间，昼夜/周末切换
- 🎯 **玩家交互**：WASD 移动，点击 agent 查看详情，上帝模式干预任务
- 🏆 **成就系统**：解锁各种彩蛋（"咖啡成瘾"、"零故障运行"等）
- 🔄 **数据同步**：文件监听 / WebSocket 连接真实 OpenClaw 实例

---

## 🛠️ 技术栈

- **引擎**：Godot 4.3 (2D)
- **语言**：GDScript
- **素材**：Aseprite (16x16 像素)
- **同步**：文件系统监听 + 可选 WebSocket

---

## 🚀 快速开始

### 1. 克隆仓库
```bash
git clone https://github.com/sharelgx/openclaw-pixel-office.git
cd openclaw-pixel-office
```

### 2. 安装 Godot
- 下载 [Godot 4.3+](https://godotengine.org/download)
- 打开 Godot，导入项目（选择 `project.godot`）

### 3. 运行
- 按 **F6** 运行
- 使用 **WASD** 移动视角
- 点击 agent 查看状态

---

## 📁 项目结构

```
openclaw-pixel-office/
├── addons/               # 插件（如有）
├── assets/               # 图片、音效、音乐
│   ├── sprites/
│   │   ├── characters/  # agent 角色
│   │   ├── office/      # 办公室 tileset
│   │   └── ui/
│   ├── sounds/
│   └── music/
├── scenes/               # Godot 场景文件
│   ├── main.tscn
│   ├── office_2f.tscn
│   ├── office_3f.tscn
│   └── ui/
├── scripts/              # GDScript
│   ├── agents/
│   │   ├── jarvis.gd
│   │   ├── corali.gd
│   │   └── xiaoyuan.gd
│   ├── systems/
│   │   ├── task_board.gd
│   │   ├── time_system.gd
│   │   └── sync_manager.gd
│   └── ui/
├── config/
│   └── settings.json    # 玩家配置
├── project.godot
└── README.md
```

---

## 🎮 操作指南

| 按键 | 功能 |
|-----|------|
| **W/A/S/D** | 移动视角（办公室漫游） |
| **鼠标悬停** | 查看 agent 状态气泡 |
| **左键点击** | 打开 agent 控制面板 |
| **右键点击任务板** | 添加/修改任务（需权限） |
| **1-5** | 快速跳转楼层 |
| **空格** | 时间加速（1x → 2x → 5x → 暂停） |
| **~ (波浪键)** | 打开上帝模式控制台 |

---

## 🔌 连接真实 OpenClaw

默认模式：**离线演示**（随机生成任务）

要连接真实系统：

1. 编辑 `config/settings.json`：
```json
{
  "openclaw": {
    "enabled": true,
    "task_board_path": "/Users/liulaoshi/.openclaw/workspace-feishu/shared/TASK_BOARD.md",
    "sync_mode": "file_watch",  // "file_watch" 或 "websocket"
    "websocket_url": "ws://localhost:8080/ws"
  }
}
```

2. 确保 OpenClaw 正在运行并暴露任务板文件

3. 游戏中 agent 会自动反映真实状态

---

## 🎨 美术资源

### 角色设计（16x32 像素）
- 贾维斯：企鹅机器人 👔
- 克拉瑞：眼镜女秘书 👩‍💼
- 小远：耳机极客 👨‍💻
- healthcheck：白大褂医生 👩‍⚕️
- github：Octocat 猫 🐱

### 待贡献
欢迎提交像素艺术作品！使用 [Aseprite](https://www.aseprite.org) 创作，导出为 `.png` 放入 `assets/sprites/characters/`

---

## 🤝 贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📜 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- 灵感来自：[Stardew Valley](https://www.stardewvalley.net/)、[SimTower](https://en.wikipedia.org/wiki/SimTower)
- 引擎：[Godot](https://godotengine.org/) - 开源游戏引擎
- 像素艺术社区：[Lospec](https://lospec.com/)

---

## 📧 联系

- 作者：[sharelgx](https://github.com/sharelgx)
- 问题反馈：[Issues](https://github.com/sharelgx/openclaw-pixel-office/issues)
- OpenClaw 项目：https://github.com/openclaw/openclaw

---

**🚧 项目状态：早期开发中，欢迎一起玩！**
