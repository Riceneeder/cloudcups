#!/bin/bash
# CI/CD 构建脚本 - 适配 GitHub Actions 环境

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🤖 CI/CD 构建模式"
echo "=================="

# 检查CI环境
if [ "$CI" = "true" ]; then
    echo "✅ 检测到CI环境"
    export NODE_ENV=production
else
    echo "⚠️ 本地环境，建议使用 ./build.sh"
fi

# 清理之前的构建
echo "📁 清理构建目录..."
rm -rf "$PROJECT_ROOT/dist"
rm -rf "$PROJECT_ROOT/cloudcups" 
rm "$PROJECT_ROOT/cloudcups.exe"

# 检查依赖
echo "🔍 检查构建依赖..."
if ! command -v bun &> /dev/null; then
    echo "❌ 未找到 bun，请先安装"
    exit 1
fi

# 构建前端
echo "🚀 构建前端..."
cd "$PROJECT_ROOT"
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
mkdir -p deploy/logs

# CI环境特殊处理
if [ "$CI" = "true" ]; then
    echo "🔧 CI环境优化..."
    
    # 设置可执行权限
    chmod +x deploy/cloudcups
    
    # 生成构建信息
    cat > deploy/build-info.txt << EOF
Build Information:
- Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
- Git Commit: ${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo 'unknown')}
- Git Branch: ${GITHUB_REF_NAME:-$(git branch --show-current 2>/dev/null || echo 'unknown')}
- Builder: GitHub Actions
- Build Number: ${GITHUB_RUN_NUMBER:-local}
EOF

    # 验证构建产物
    echo "✅ 验证构建产物..."
    if [ ! -f "deploy/cloudcups" ]; then
        echo "❌ 可执行文件未生成"
        exit 1
    fi
    
    if [ ! -d "deploy/static" ]; then
        echo "❌ 静态文件目录未生成"
        exit 1
    fi
    
    # 检查文件大小
    EXECUTABLE_SIZE=$(stat -f%z deploy/cloudcups 2>/dev/null || stat -c%s deploy/cloudcups 2>/dev/null || echo 0)
    if [ "$EXECUTABLE_SIZE" -lt 1000000 ]; then  # 小于1MB可能有问题
        echo "⚠️ 警告: 可执行文件大小异常 ($EXECUTABLE_SIZE bytes)"
    fi
    
    echo "📊 构建统计:"
    echo "  - 可执行文件大小: $(ls -lh deploy/cloudcups | awk '{print $5}')"
    echo "  - 静态文件数量: $(find deploy/static -type f | wc -l)"
    echo "  - 总体积: $(du -sh deploy | awk '{print $1}')"
fi

echo "✅ 构建完成！"
echo ""
echo "📦 输出文件:"
echo "  - 可执行文件: ./deploy/cloudcups"
echo "  - 部署目录: ./deploy/"
if [ "$CI" = "true" ]; then
    echo "  - 构建信息: ./deploy/build-info.txt"
fi
echo ""