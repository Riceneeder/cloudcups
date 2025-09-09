#!/bin/bash

# CloudCups 系统服务卸载脚本
# 使用方法: sudo ./uninstall-service.sh

set -e

SERVICE_NAME="cloudcups"
INSTALL_DIR="/opt/cloudcups"
SYSTEMD_DIR="/etc/systemd/system"

echo "🗑️  开始卸载 CloudCups 系统服务..."

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "❌ 错误: 请使用 sudo 权限运行此脚本"
    exit 1
fi

# 停止服务
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "⏹️  停止服务..."
    systemctl stop "$SERVICE_NAME"
fi

# 禁用服务
if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "❌ 禁用服务..."
    systemctl disable "$SERVICE_NAME"
fi

# 删除服务文件
if [ -f "$SYSTEMD_DIR/$SERVICE_NAME.service" ]; then
    echo "🗑️  删除服务文件..."
    rm -f "$SYSTEMD_DIR/$SERVICE_NAME.service"
fi

# 重新加载 systemd
echo "🔄 重新加载 systemd..."
systemctl daemon-reload

# 询问是否删除程序文件
echo ""
echo "是否删除程序文件 ($INSTALL_DIR)? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [ -d "$INSTALL_DIR" ]; then
        echo "🗑️  删除程序文件..."
        rm -rf "$INSTALL_DIR"
        echo "✅ 程序文件已删除"
    fi
else
    echo "💡 程序文件保留在 $INSTALL_DIR"
fi

echo "🎉 CloudCups 服务卸载完成!"
