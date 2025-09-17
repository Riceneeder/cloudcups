#!/bin/bash
# 一键构建所有 Linux 发行版安装包的脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 CloudCups Linux 发行版安装包构建工具"
echo "============================================"
echo ""

# 检查操作系统
OS_TYPE=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
else
    echo "⚠️ 警告: 当前操作系统可能不支持所有构建功能"
    OS_TYPE="Unknown"
fi

echo "📋 检测到操作系统: $OS_TYPE"
echo ""

# 检查必要的构建工具
echo "🔍 检查构建工具..."

# 检查基础工具
MISSING_TOOLS=()

if ! command -v bun &> /dev/null; then
    MISSING_TOOLS+=("bun")
fi

# 检查 DEB 构建工具
DEB_BUILD_AVAILABLE=false
if command -v dpkg-deb &> /dev/null; then
    DEB_BUILD_AVAILABLE=true
    echo "✅ DEB 包构建工具可用"
else
    echo "❌ DEB 包构建工具不可用 (需要 dpkg-deb)"
fi

# 检查 RPM 构建工具
RPM_BUILD_AVAILABLE=false
if command -v rpmbuild &> /dev/null; then
    RPM_BUILD_AVAILABLE=true
    echo "✅ RPM 包构建工具可用"
else
    echo "❌ RPM 包构建工具不可用 (需要 rpmbuild)"
fi

echo ""

# 检查缺失的工具
if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "❌ 缺少必要的构建工具:"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "   - $tool"
    done
    echo ""
    echo "请安装缺失的工具后重试。"
    exit 1
fi

# 显示构建选项
echo "📦 可用的构建选项:"
echo ""
echo "1. 构建 DEB 包 (Ubuntu/Debian)"
echo "2. 构建 RPM 包 (RHEL/CentOS/Fedora)"
echo "3. 构建所有可用的包"
echo "4. 只构建项目 (不打包)"
echo "5. 退出"
echo ""

# 获取用户选择
read -p "请选择构建选项 [1-5]: " choice

case $choice in
    1)
        if [ "$DEB_BUILD_AVAILABLE" = true ]; then
            echo ""
            echo "🔥 开始构建 DEB 包..."
            cd "$SCRIPT_DIR"
            ./build-deb.sh
        else
            echo "❌ DEB 包构建工具不可用"
            exit 1
        fi
        ;;
    2)
        if [ "$RPM_BUILD_AVAILABLE" = true ]; then
            echo ""
            echo "🔥 开始构建 RPM 包..."
            cd "$SCRIPT_DIR"
            ./build-rpm.sh
        else
            echo "❌ RPM 包构建工具不可用"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "🔥 开始构建所有可用的包..."
        
        if [ "$DEB_BUILD_AVAILABLE" = true ]; then
            echo ""
            echo "📦 构建 DEB 包..."
            cd "$SCRIPT_DIR"
            ./build-deb.sh
        fi
        
        if [ "$RPM_BUILD_AVAILABLE" = true ]; then
            echo ""
            echo "📦 构建 RPM 包..."
            cd "$SCRIPT_DIR"
            ./build-rpm.sh
        fi
        
        if [ "$DEB_BUILD_AVAILABLE" = false ] && [ "$RPM_BUILD_AVAILABLE" = false ]; then
            echo "❌ 没有可用的包构建工具"
            exit 1
        fi
        ;;
    4)
        echo ""
        echo "🔥 只构建项目..."
        cd "$PROJECT_ROOT"
        ./build.sh
        ;;
    5)
        echo "退出构建工具"
        exit 0
        ;;
    *)
        echo "❌ 无效的选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 构建完成！"
echo ""
echo "📁 输出文件位置:"
echo "   - DEB 包: $SCRIPT_DIR/cloudcups_1.0.0_amd64.deb"
echo "   - RPM 包: $SCRIPT_DIR/cloudcups-1.0.0-1.*.x86_64.rpm"
echo ""
echo "📖 安装说明:"
echo ""
echo "🐧 Ubuntu/Debian 系统:"
echo "   sudo dpkg -i cloudcups_1.0.0_amd64.deb"
echo "   sudo apt-get install -f  # 如果有依赖问题"
echo ""
echo "🎩 RHEL/CentOS/Fedora 系统:"
echo "   sudo rpm -ivh cloudcups-1.0.0-1.*.x86_64.rpm"
echo "   # 或者:"
echo "   sudo dnf install cloudcups-1.0.0-1.*.x86_64.rpm"
echo ""
echo "🌐 安装后访问:"
echo "   Web 界面: http://localhost:3000"
echo ""
echo "🔧 服务管理:"
echo "   查看状态: systemctl status cloudcups"
echo "   查看日志: journalctl -u cloudcups -f"
echo "   停止服务: sudo systemctl stop cloudcups"
echo "   启动服务: sudo systemctl start cloudcups"
echo ""
echo "🗑️ 卸载方法:"
echo "   Ubuntu/Debian: sudo dpkg -r cloudcups"
echo "   RHEL/CentOS/Fedora: sudo rpm -e cloudcups"
echo ""