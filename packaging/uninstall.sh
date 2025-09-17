#!/bin/bash
# CloudCups 手动卸载脚本

set -e

echo "🗑️ CloudCups 卸载脚本"
echo "===================="
echo ""

# 检查是否以 root 用户运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 此脚本需要以 root 用户权限运行"
   echo "请使用: sudo $0"
   exit 1
fi

# 确认卸载
echo "⚠️ 这将完全卸载 CloudCups 服务和所有相关文件"
echo ""
read -p "确认卸载？(y/N): " confirm_uninstall
if [[ ! $confirm_uninstall =~ ^[Yy]$ ]]; then
    echo "取消卸载"
    exit 0
fi

echo ""
echo "🛑 开始卸载 CloudCups..."

# 停止服务
if systemctl is-active --quiet cloudcups.service 2>/dev/null; then
    echo "🛑 停止服务..."
    systemctl stop cloudcups.service
fi

# 禁用服务
if systemctl is-enabled --quiet cloudcups.service 2>/dev/null; then
    echo "❌ 禁用服务..."
    systemctl disable cloudcups.service
fi

# 删除服务文件
if [ -f "/lib/systemd/system/cloudcups.service" ]; then
    echo "🗄️ 删除服务文件..."
    rm -f /lib/systemd/system/cloudcups.service
fi

# 重新加载 systemd
systemctl daemon-reload

# 删除程序文件
if [ -d "/opt/cloudcups" ]; then
    echo "📁 删除程序文件..."
    rm -rf /opt/cloudcups
fi

# 询问是否删除用户
echo ""
read -p "是否删除 cloudcups 用户？(y/N): " delete_user
if [[ $delete_user =~ ^[Yy]$ ]]; then
    if id "cloudcups" &>/dev/null; then
        echo "👤 删除用户..."
        userdel cloudcups 2>/dev/null || true
    fi
fi

echo ""
echo "✅ CloudCups 卸载完成！"
echo ""
echo "📋 已清理的内容："
echo "   - CloudCups 服务"
echo "   - 程序文件 (/opt/cloudcups)"
echo "   - systemd 服务文件"
if [[ $delete_user =~ ^[Yy]$ ]]; then
    echo "   - cloudcups 用户"
fi
echo ""