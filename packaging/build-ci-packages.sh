#!/bin/bash
# CI专用包构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 函数：构建DEB包
build_deb() {
    echo "📦 开始构建 DEB 包..."
    
    local PACKAGE_DIR="$SCRIPT_DIR/deb"
    
    # 清理之前的构建
    rm -rf "$PACKAGE_DIR/opt/cloudcups"/*
    mkdir -p "$PACKAGE_DIR/opt/cloudcups"
    
    # 复制文件到包目录
    cp "$PROJECT_ROOT/deploy/cloudcups" "$PACKAGE_DIR/opt/cloudcups/"
    cp -r "$PROJECT_ROOT/deploy/static" "$PACKAGE_DIR/opt/cloudcups/"
    mkdir -p "$PACKAGE_DIR/opt/cloudcups/logs"
    
    # 复制systemd服务文件
    cp "$PROJECT_ROOT/cloudcups.service" "$PACKAGE_DIR/lib/systemd/system/"
    
    # 更新服务文件中的用户为cloudcups
    sed -i.bak 's/User=root/User=cloudcups/' "$PACKAGE_DIR/lib/systemd/system/cloudcups.service"
    sed -i.bak 's/Group=root/Group=cloudcups/' "$PACKAGE_DIR/lib/systemd/system/cloudcups.service"
    rm -f "$PACKAGE_DIR/lib/systemd/system/cloudcups.service.bak"
    
    # 构建DEB包
    cd "$SCRIPT_DIR"
    
    # 检查dpkg-deb是否可用
    if ! command -v dpkg-deb &> /dev/null; then
        echo "❌ dpkg-deb 未找到，尝试使用fakeroot..."
        if command -v fakeroot &> /dev/null; then
            fakeroot dpkg-deb --build deb
        else
            echo "❌ 无法构建DEB包：缺少dpkg-deb或fakeroot"
            return 1
        fi
    else
        dpkg-deb --build deb
    fi
    
    # 重命名包文件
    local VERSION=$(grep "^Version:" deb/DEBIAN/control | awk '{print $2}')
    mv deb.deb "cloudcups_${VERSION}_amd64.deb"
    
    echo "✅ DEB 包构建完成: cloudcups_${VERSION}_amd64.deb"
}

# 函数：构建RPM包
build_rpm() {
    echo "📦 开始构建 RPM 包..."
    
    # 检查是否安装了rpmbuild
    if ! command -v rpmbuild &> /dev/null; then
        echo "❌ rpmbuild 未找到，跳过RPM包构建"
        echo "ℹ️ 在Ubuntu/Debian上安装: sudo apt-get install rpm"
        return 1
    fi
    
    # 设置RPM构建环境
    local RPMBUILD_ROOT="$HOME/rpmbuild"
    mkdir -p "$RPMBUILD_ROOT"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    
    # 创建源码包
    local TEMP_DIR=$(mktemp -d)
    local VERSION=$(grep "^Version:" rpm/cloudcups.spec | awk '{print $2}')
    local SOURCE_DIR="$TEMP_DIR/cloudcups-${VERSION}"
    mkdir -p "$SOURCE_DIR"
    
    # 复制必要文件
    cp "$PROJECT_ROOT/deploy/cloudcups" "$SOURCE_DIR/"
    cp -r "$PROJECT_ROOT/deploy/static" "$SOURCE_DIR/"
    cp "$PROJECT_ROOT/cloudcups.service" "$SOURCE_DIR/"
    
    # 更新服务文件中的用户为cloudcups
    sed 's/User=root/User=cloudcups/' "$SOURCE_DIR/cloudcups.service" > "$SOURCE_DIR/cloudcups.service.tmp"
    sed 's/Group=root/Group=cloudcups/' "$SOURCE_DIR/cloudcups.service.tmp" > "$SOURCE_DIR/cloudcups.service"
    rm "$SOURCE_DIR/cloudcups.service.tmp"
    
    # 创建tar.gz包
    cd "$TEMP_DIR"
    tar -czf "$RPMBUILD_ROOT/SOURCES/cloudcups-${VERSION}.tar.gz" "cloudcups-${VERSION}/"
    
    # 复制spec文件
    cp "$SCRIPT_DIR/rpm/cloudcups.spec" "$RPMBUILD_ROOT/SPECS/"
    
    # 构建RPM包
    cd "$RPMBUILD_ROOT"
    rpmbuild -ba SPECS/cloudcups.spec
    
    # 复制生成的RPM包
    cp RPMS/x86_64/cloudcups-${VERSION}-1.*.x86_64.rpm "$SCRIPT_DIR/"
    
    # 清理临时文件
    rm -rf "$TEMP_DIR"
    
    echo "✅ RPM 包构建完成: cloudcups-${VERSION}-1.*.x86_64.rpm"
}

# 主逻辑
PACKAGE_TYPE="${1:-all}"

case "$PACKAGE_TYPE" in
    "deb")
        build_deb
        ;;
    "rpm")
        build_rpm
        ;;
    "all")
        echo "🚀 构建所有包格式..."
        build_deb
        build_rpm
        ;;
    *)
        echo "用法: $0 [deb|rpm|all]"
        echo "  deb - 只构建DEB包"
        echo "  rpm - 只构建RPM包"
        echo "  all - 构建所有包格式（默认）"
        exit 1
        ;;
esac

echo ""
echo "📦 构建完成的包:"
ls -la "$SCRIPT_DIR"/*.deb "$SCRIPT_DIR"/*.rpm 2>/dev/null || echo "  (无包文件生成)"
echo ""