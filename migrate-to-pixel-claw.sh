#!/bin/bash
# migrate-to-pixel-claw.sh - 将 openclaw-pixel-office 迁移到 pixel-claw

set -e

echo "=== 迁移到 pixel-claw 仓库 ==="
echo ""

# 1. 检查当前目录
if [ ! -d ".git" ]; then
  echo "❌ 当前目录不是git仓库"
  exit 1
fi

# 2. 提示确认
echo "当前目录: $(pwd)"
echo "这将会:"
echo "  1. 移除旧远程 origin"
echo "  2. 添加新远程 https://github.com/sharelgx/pixel-claw.git"
echo "  3. 推送到新仓库"
echo ""
read -p "确认继续？(y/N): " confirm
if [ "$confirm" != "y" ]; then
  echo "取消"
  exit 0
fi

# 3. 重设远程
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/sharelgx/pixel-claw.git
echo "✅ 远程仓库已设置为 pixel-claw"

# 4. 推送到新仓库
echo "正在推送..."
git push -u origin main

echo ""
echo "✅ 迁移完成！"
echo "新仓库: https://github.com/sharelgx/pixel-claw"
echo ""
echo "后续操作："
echo "  1. 在 GitHub 上删除旧仓库 openclaw-pixel-office（可选）"
echo "  2. 更新 README 中的旧链接"
echo "  3. 通知团队成员"
