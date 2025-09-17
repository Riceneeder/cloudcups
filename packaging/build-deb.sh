#!/bin/bash
# DEB 包构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/deb"
BUILD_DIR="$PROJECT_ROOT/dist"

echo "🔥 开始构建 CloudCups DEB 包..."

# 清理之前的构建
echo "📁 清理包构建目录..."
rm -rf "$PACKAGE_DIR/opt/cloudcups"/*
mkdir -p "$PACKAGE_DIR/opt/cloudcups"

# 构建项目
echo "🚀 构建项目..."
cd "$PROJECT_ROOT"
./build.sh

# 复制文件到包目录
echo "📦 准备包内容..."
cp deploy/cloudcups "$PACKAGE_DIR/opt/cloudcups/"
cp -r deploy/static "$PACKAGE_DIR/opt/cloudcups/"
mkdir -p "$PACKAGE_DIR/opt/cloudcups/logs"

# 复制 systemd 服务文件
echo "⚙️ 复制服务文件..."
cp cloudcups.service "$PACKAGE_DIR/lib/systemd/system/"

# 更新服务文件中的用户为 cloudcups
sed -i 's/User=root/User=cloudcups/' "$PACKAGE_DIR/lib/systemd/system/cloudcups.service"
sed -i 's/Group=root/Group=cloudcups/' "$PACKAGE_DIR/lib/systemd/system/cloudcups.service"

# 构建 DEB 包
echo "📦 构建 DEB 包..."
cd "$SCRIPT_DIR"
dpkg-deb --build deb

# 重命名包文件
mv deb.deb "cloudcups_1.0.0_amd64.deb"

echo "✅ DEB 包构建完成！"
echo ""
echo "📦 输出文件: $SCRIPT_DIR/cloudcups_1.0.0_amd64.deb"
echo ""
echo "🚀 安装方法:"
echo "  sudo dpkg -i cloudcups_1.0.0_amd64.deb"
echo "  sudo apt-get install -f  # 如果有依赖问题"
echo ""
echo "🗑️ 卸载方法:"
echo "  sudo dpkg -r cloudcups"
echo ""