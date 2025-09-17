#!/bin/bash
# CloudCups 手动安装脚本
# 适用于不使用包管理器的直接安装

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 CloudCups 手动安装脚本"
echo "=========================="
echo ""

# 检查是否以 root 用户运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 此脚本需要以 root 用户权限运行"
   echo "请使用: sudo $0"
   exit 1
fi

# 检查系统要求
echo "🔍 检查系统要求..."

# 检查 systemd
if ! command -v systemctl &> /dev/null; then
    echo "❌ 系统不支持 systemd，无法自动安装服务"
    echo "请手动运行程序或使用其他服务管理方式"
    exit 1
fi

# 检查 CUPS
if ! command -v lp &> /dev/null; then
    echo "⚠️ 警告: 未检测到 CUPS 打印系统"
    echo "请安装 CUPS："
    echo "  Ubuntu/Debian: apt-get install cups cups-client"
    echo "  RHEL/CentOS/Fedora: dnf install cups cups-client"
    echo ""
    read -p "是否继续安装？(y/N): " continue_install
    if [[ ! $continue_install =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ 系统检查通过"
echo ""

# 构建项目
echo "🔨 构建 CloudCups..."
cd "$PROJECT_ROOT"
if [ ! -f "build.sh" ]; then
    echo "❌ 未找到构建脚本"
    exit 1
fi
./build.sh

# 创建安装目录
echo "📁 创建安装目录..."
mkdir -p /opt/cloudcups
mkdir -p /opt/cloudcups/logs

# 复制文件
echo "📦 安装文件..."
cp deploy/cloudcups /opt/cloudcups/
cp -r deploy/static /opt/cloudcups/

# 创建用户
echo "👤 创建系统用户..."
if ! id "cloudcups" &>/dev/null; then
    useradd -r -s /bin/false -d /opt/cloudcups -c "CloudCups service user" cloudcups
    echo "✅ 创建用户 cloudcups"
else
    echo "ℹ️ 用户 cloudcups 已存在"
fi

# 设置权限
echo "🔐 设置文件权限..."
chown -R cloudcups:cloudcups /opt/cloudcups
chmod 755 /opt/cloudcups
chmod +x /opt/cloudcups/cloudcups

# 安装 systemd 服务
echo "⚙️ 安装系统服务..."
cp cloudcups.service /lib/systemd/system/

# 更新服务文件中的用户
sed -i 's/User=root/User=cloudcups/' /lib/systemd/system/cloudcups.service
sed -i 's/Group=root/Group=cloudcups/' /lib/systemd/system/cloudcups.service

# 重新加载 systemd
systemctl daemon-reload

# 启用并启动服务
echo "🚀 启动服务..."
systemctl enable cloudcups.service
systemctl start cloudcups.service

# 检查服务状态
sleep 2
if systemctl is-active --quiet cloudcups.service; then
    echo "✅ 服务启动成功！"
else
    echo "❌ 服务启动失败，请检查日志："
    echo "   journalctl -u cloudcups --no-pager"
    exit 1
fi

echo ""
echo "🎉 CloudCups 安装完成！"
echo ""
echo "📋 安装信息："
echo "   安装路径: /opt/cloudcups"
echo "   服务名称: cloudcups.service"
echo "   运行用户: cloudcups"
echo "   Web 界面: http://localhost:3000"
echo ""
echo "🔧 常用命令："
echo "   查看状态: systemctl status cloudcups"
echo "   查看日志: journalctl -u cloudcups -f"
echo "   停止服务: systemctl stop cloudcups"
echo "   启动服务: systemctl start cloudcups"
echo "   重启服务: systemctl restart cloudcups"
echo ""
echo "🗑️ 卸载方法："
echo "   $SCRIPT_DIR/uninstall.sh"
echo ""