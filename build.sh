#!/bin/bash
set -e

echo "🔥 开始构建 CloudCups 单文件可执行程序..."

# 清理之前的构建
echo "📁 清理构建目录..."
rm -rf dist
rm -f cloudcups cloudcups.exe

# 构建前端
echo "🚀 构建前端..."
bun run build:frontend

# 创建静态资源目录
echo "📦 准备静态资源..."
mkdir -p dist/static
cp -r frontend/dist/* dist/static/

# 编译后端为单文件可执行程序
echo "⚡编译后端为可执行文件..."
cd backend
bun build --compile --target=bun --outfile=../cloudcups server-production.ts
cd ..

# 创建部署目录
echo "📁 创建部署包..."
mkdir -p deploy
cp cloudcups deploy/
cp -r dist/static deploy/
cp -r backend/logs deploy/ 2>/dev/null || mkdir -p deploy/logs

echo "✅ 构建完成！"
echo ""
echo "📦 输出文件:"
echo "  - 可执行文件: ./deploy/cloudcups"
echo "  - 部署目录: ./deploy/"
echo ""
echo "🚀 运行方法:"
echo "  ./deploy/cloudcups"
echo ""
echo "📝 注意事项:"
echo "  - 请确保系统已安装 CUPS"
echo "  - 程序会在当前目录创建 logs 文件夹"
echo "  - 默认端口: 3000"
