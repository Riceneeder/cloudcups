#!/bin/bash

# CloudCups 系统服务安装脚本
# 使用方法: sudo ./install-service.sh

set -e

SERVICE_NAME="cloudcups"
SERVICE_FILE="cloudcups.service"
INSTALL_DIR="/opt/cloudcups"
SYSTEMD_DIR="/etc/systemd/system"

echo "🔧 开始安装 CloudCups 系统服务..."

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "❌ 错误: 请使用 sudo 权限运行此脚本"
    exit 1
fi

# 检查服务文件是否存在
if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ 错误: 找不到服务文件 $SERVICE_FILE"
    exit 1
fi

# 停止现有服务（如果正在运行）
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "⏹️  停止现有服务..."
    systemctl stop "$SERVICE_NAME"
fi

# 创建安装目录
echo "📁 创建安装目录 $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/logs"

# 构建程序
echo "🔨 构建程序..."
./build.sh

# 复制文件到安装目录
echo "📦 复制程序文件..."
cp cloudcups "$INSTALL_DIR/"
cp -r dist/static "$INSTALL_DIR/" 2>/dev/null || echo "⚠️  警告: 未找到静态文件目录"

# 设置权限
echo "🔐 设置文件权限..."
chmod +x "$INSTALL_DIR/cloudcups"
chown -R root:root "$INSTALL_DIR"

# 安装服务文件
echo "⚙️  安装服务文件..."
cp "$SERVICE_FILE" "$SYSTEMD_DIR/"

# 重新加载 systemd
echo "🔄 重新加载 systemd..."
systemctl daemon-reload

# 启用服务
echo "✅ 启用服务..."
systemctl enable "$SERVICE_NAME"

echo "🎉 CloudCups 服务安装完成!"
echo ""
echo "常用命令:"
echo "  启动服务: sudo systemctl start $SERVICE_NAME"
echo "  停止服务: sudo systemctl stop $SERVICE_NAME"
echo "  重启服务: sudo systemctl restart $SERVICE_NAME"
echo "  查看状态: sudo systemctl status $SERVICE_NAME"
echo "  查看日志: sudo journalctl -u $SERVICE_NAME -f"
echo "  禁用服务: sudo systemctl disable $SERVICE_NAME"
echo ""
echo "是否现在启动服务? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    systemctl start "$SERVICE_NAME"
    echo "✅ 服务已启动!"
    systemctl status "$SERVICE_NAME"
else
    echo "💡 您可以稍后使用 'sudo systemctl start $SERVICE_NAME' 启动服务"
fi
