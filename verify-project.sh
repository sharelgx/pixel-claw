#!/usr/bin/env bash
# verify-project.sh - 快速验证项目状态（简化版，不中途退出）

echo "=== Pixel-Claw 项目验证 ==="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

passed=0
failed=0

check_file() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}✓${NC} $2"
    ((passed++))
  else
    echo -e "${RED}✗${NC} $2"
    ((failed++))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "${GREEN}✓${NC} $2"
    ((passed++))
  else
    echo -e "${RED}✗${NC} $2"
    ((failed++))
  fi
}

check_cmd() {
  if command -v "$1" &> /dev/null; then
    echo -e "${GREEN}✓${NC} $2 ($(command -v $1))"
    ((passed++))
  else
    echo -e "${RED}⚠${NC} $2 (未安装)"
    ((failed++))
  fi
}

# 1. 项目文件
check_file "project.godot" "项目配置文件存在"
check_file "config/settings.json" "游戏配置存在"

# 2. 目录结构
check_dir "scenes" "场景目录"
check_dir "scripts" "脚本目录"
check_dir "scripts/agents" "Agent 脚本目录"
check_dir "scripts/systems" "系统脚本目录"

# 3. 核心脚本文件
check_file "scenes/main.gd" "主场景脚本"
check_file "scenes/main.tscn" "主场景文件"
check_file "scripts/agents/agent_base.gd" "Agent 基类"
check_file "scripts/agents/jarvis.gd" "贾维斯脚本"
check_file "scripts/agents/corali.gd" "克拉瑞脚本"
check_file "scripts/agents/xiaoyuan.gd" "小远脚本"
check_file "scripts/systems/time_system.gd" "时间系统"
check_file "scripts/systems/task_board.gd" "任务板系统"
check_file "scripts/systems/game_settings.gd" "配置系统"
check_file "scripts/systems/ui_layer.gd" "UI 层"

# 4. Godot 安装
check_cmd "godot" "Godot 引擎"

# 5. Git 仓库
if [ -d ".git" ]; then
  check_file ".git/config" "Git 仓库"
  if git remote get-url origin &> /dev/null; then
    echo -e "${GREEN}✓${NC} 远程仓库: $(git remote get-url origin)"
    ((passed++))
  else
    echo -e "${RED}⚠${NC} 未设置远程仓库"
    ((failed++))
  fi
else
  check_cmd "false" "Git 仓库"  # will fail
fi

# 总结
echo ""
echo "=== 验证完成 ==="
echo -e "通过: ${GREEN}$passed${NC}"
echo -e "失败/警告: ${RED}$failed${NC}"
echo ""

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}✅ 项目状态完美！可以运行了。${NC}"
  echo ""
  echo "启动步骤："
  echo "  1. 打开 Godot"
  echo "  2. Import → 选择项目文件夹（包含 project.godot）"
  echo "  3. 按 F6 运行"
  exit 0
else
  echo -e "${YELLOW}⚠️  部分项目缺失，请检查。${NC}"
  exit 1
fi
