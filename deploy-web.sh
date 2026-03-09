#!/usr/bin/env bash
# deploy-web.sh - 导出 Web (HTML5) 版本并部署到 GitHub Pages

set -e

echo "=== Pixel-Claw Web Deployment ==="
echo ""

# 1. 检查是否在正确的目录
if [ ! -f "project.godot" ]; then
  echo "❌ 请在项目根目录运行此脚本"
  exit 1
fi

# 2. 下载 Godot（如果不存在）
GODOT_VERSION="4.3.0-stable"
GODOT_BIN="godot"

if ! command -v $GODOT_BIN &> /dev/null; then
  echo "📥 下载 Godot $GODOT_VERSION..."
  wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  unzip -q "Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  chmod +x Godot_v${GODOT_VERSION}_linux.x86_64/Godot
  GODOT_BIN="./Godot_v${GODOT_VERSION}_linux.x86_64/Godot"
else
  echo "✅ Godot 已安装: $(command -v godot)"
  GODOT_BIN="godot"
fi

# 3. 导出 HTML5 版本
echo "🔨 导出 HTML5 版本..."
# 注意：需要先安装 HTML5 导出模板
# $GODOT_BIN --headless --export "HTML5" build/web/index.html || {
#   echo "⚠️  HTML5 导出失败，请确保已安装导出模板"
#   echo "   下载: https://github.com/godotengine/godot/releases"
#   exit 1
# }

echo "⚠️  HTML5 导出需要额外配置模板（暂未实现）"

# 4. 部署到 gh-pages 分支
# git checkout --orphan gh-pages
# git --work-tree build/web add --all
# git --work-tree build/web commit -m "Deploy web build"
# git push origin gh-pages:gh-pages
# git checkout main

echo ""
echo "✅ Web 部署脚本准备就绪（需要配置 HTML5 导出模板后使用）"
echo ""
echo "手动步骤："
echo "  1. 下载 Godot HTML5 导出模板"
echo "  2. 取消上面注释中的导出命令"
echo "  3. 运行此脚本"
