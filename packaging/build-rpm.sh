#!/bin/bash
# RPM 包构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RPM_DIR="$SCRIPT_DIR/rpm"
BUILD_DIR="$PROJECT_ROOT/dist"

echo "🔥 开始构建 CloudCups RPM 包..."

# 检查是否安装了 rpmbuild
if ! command -v rpmbuild &> /dev/null; then
    echo "❌ 错误: 未找到 rpmbuild 命令"
    echo "请安装 rpm-build 包:"
    echo "  - RHEL/CentOS/Fedora: sudo dnf install rpm-build"
    echo "  - Ubuntu/Debian: sudo apt-get install rpm"
    exit 1
fi

# 设置 RPM 构建环境
echo "📁 设置 RPM 构建环境..."
RPMBUILD_ROOT="$HOME/rpmbuild"
mkdir -p "$RPMBUILD_ROOT"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# 构建项目
echo "🚀 构建项目..."
cd "$PROJECT_ROOT"
./build.sh

# 创建源码包
echo "📦 创建源码包..."
TEMP_DIR=$(mktemp -d)
SOURCE_DIR="$TEMP_DIR/cloudcups-1.0.0"
mkdir -p "$SOURCE_DIR"

# 复制必要文件
cp deploy/cloudcups "$SOURCE_DIR/"
cp -r deploy/static "$SOURCE_DIR/"
cp cloudcups.service "$SOURCE_DIR/"

# 更新服务文件中的用户为 cloudcups
sed 's/User=root/User=cloudcups/' "$SOURCE_DIR/cloudcups.service" > "$SOURCE_DIR/cloudcups.service.tmp"
sed 's/Group=root/Group=cloudcups/' "$SOURCE_DIR/cloudcups.service.tmp" > "$SOURCE_DIR/cloudcups.service"
rm "$SOURCE_DIR/cloudcups.service.tmp"

# 创建 tar.gz 包
cd "$TEMP_DIR"
tar -czf "$RPMBUILD_ROOT/SOURCES/cloudcups-1.0.0.tar.gz" cloudcups-1.0.0/

# 复制 spec 文件
cp "$RPM_DIR/cloudcups.spec" "$RPMBUILD_ROOT/SPECS/"

# 构建 RPM 包
echo "📦 构建 RPM 包..."
cd "$RPMBUILD_ROOT"
rpmbuild -ba SPECS/cloudcups.spec

# 复制生成的 RPM 包
echo "📁 复制 RPM 包..."
cp RPMS/x86_64/cloudcups-1.0.0-1.*.x86_64.rpm "$SCRIPT_DIR/"
RPM_FILE=$(ls "$SCRIPT_DIR"/cloudcups-1.0.0-1.*.x86_64.rpm)

# 清理临时文件
rm -rf "$TEMP_DIR"

echo "✅ RPM 包构建完成！"
echo ""
echo "📦 输出文件: $RPM_FILE"
echo ""
echo "🚀 安装方法:"
echo "  sudo rpm -ivh $(basename "$RPM_FILE")"
echo "  # 或者使用 dnf/yum:"
echo "  sudo dnf install $(basename "$RPM_FILE")"
echo ""
echo "🗑️ 卸载方法:"
echo "  sudo rpm -e cloudcups"
echo ""