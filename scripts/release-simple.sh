#!/bin/bash
# CloudCups 版本发布脚本 - 简化版

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 函数：打印消息
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# 获取当前版本
get_version() {
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        node -p "require('$PROJECT_ROOT/package.json').version" 2>/dev/null || echo "0.1.0"
    else
        echo "0.1.0"
    fi
}

# 验证版本格式
validate_version() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# 更新所有文件的版本号
update_versions() {
    local version=$1
    info "更新版本号到 $version"
    
    # 更新主 package.json
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        if command -v node >/dev/null 2>&1; then
            node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('$PROJECT_ROOT/package.json', 'utf8'));
            pkg.version = '$version';
            fs.writeFileSync('$PROJECT_ROOT/package.json', JSON.stringify(pkg, null, 2) + '\n');
            "
        else
            sed -i.bak "s/\"version\": \".*\"/\"version\": \"$version\"/" "$PROJECT_ROOT/package.json"
            rm -f "$PROJECT_ROOT/package.json.bak"
        fi
        success "已更新 package.json"
    fi
    
    # 更新后端 package.json
    if [ -f "$PROJECT_ROOT/backend/package.json" ]; then
        if command -v node >/dev/null 2>&1; then
            node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('$PROJECT_ROOT/backend/package.json', 'utf8'));
            pkg.version = '$version';
            fs.writeFileSync('$PROJECT_ROOT/backend/package.json', JSON.stringify(pkg, null, 2) + '\n');
            "
        else
            sed -i.bak "s/\"version\": \".*\"/\"version\": \"$version\"/" "$PROJECT_ROOT/backend/package.json"
            rm -f "$PROJECT_ROOT/backend/package.json.bak"
        fi
        success "已更新 backend/package.json"
    fi
    
    # 更新 DEB 包版本
    if [ -f "$PROJECT_ROOT/packaging/deb/DEBIAN/control" ]; then
        sed -i.bak "s/^Version:.*/Version: $version/" "$PROJECT_ROOT/packaging/deb/DEBIAN/control"
        rm -f "$PROJECT_ROOT/packaging/deb/DEBIAN/control.bak"
        success "已更新 DEB 包版本"
    fi
    
    # 更新 RPM 包版本
    if [ -f "$PROJECT_ROOT/packaging/rpm/cloudcups.spec" ]; then
        sed -i.bak "s/^Version:.*/Version:        $version/" "$PROJECT_ROOT/packaging/rpm/cloudcups.spec"
        rm -f "$PROJECT_ROOT/packaging/rpm/cloudcups.spec.bak"
        success "已更新 RPM 包版本"
    fi
}

# 创建简单的changelog条目
create_changelog_entry() {
    local version=$1
    local date=$(date '+%Y-%m-%d')
    
    cat << EOF

## [$version] - $date

### 新增
- 请添加新功能描述

### 修改  
- 请添加功能改进描述

### 修复
- 请添加Bug修复描述

EOF
}

# 更新CHANGELOG
update_changelog() {
    local version=$1
    local changelog_file="$PROJECT_ROOT/CHANGELOG.md"
    
    info "更新 CHANGELOG.md"
    
    if [ ! -f "$changelog_file" ]; then
        cat > "$changelog_file" << 'EOF'
# Changelog

本文档记录了 CloudCups 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。
EOF
    fi
    
    # 创建新条目并插入到现有内容前
    local temp_file=$(mktemp)
    {
        head -6 "$changelog_file"  # 保留文件头
        create_changelog_entry "$version"  # 插入新条目
        tail -n +7 "$changelog_file"  # 添加剩余内容
    } > "$temp_file"
    
    mv "$temp_file" "$changelog_file"
    success "已更新 CHANGELOG.md"
    warning "请编辑 CHANGELOG.md 添加具体的变更内容"
}

# 创建Git标签
create_tag() {
    local version=$1
    local tag="v$version"
    
    info "准备创建Git标签: $tag"
    
    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        error "当前目录不是Git仓库"
    fi
    
    # 检查标签是否已存在
    if git tag -l | grep -q "^$tag$"; then
        error "标签 $tag 已存在"
    fi
    
    # 提交变更
    git add -A
    if ! git diff --cached --quiet; then
        git commit -m "chore: bump version to $version"
        success "已提交版本变更"
    fi
    
    # 创建标签
    git tag -a "$tag" -m "Release $version"
    success "已创建Git标签: $tag"
    
    info "推送到远程仓库:"
    echo "  git push origin main --tags"
}

# 计算新版本号
calc_version() {
    local current=$1
    local type=$2
    
    IFS='.' read -r major minor patch <<< "$current"
    
    case $type in
        "patch")
            echo "$major.$minor.$((patch + 1))"
            ;;
        "minor")
            echo "$major.$((minor + 1)).0"
            ;;
        "major")
            echo "$((major + 1)).0.0"
            ;;
    esac
}

# 主函数
main() {
    echo "🚀 CloudCups 版本发布工具"
    echo "=========================="
    
    # 获取当前版本
    current_version=$(get_version)
    info "当前版本: $current_version"
    
    # 计算建议版本
    patch_version=$(calc_version "$current_version" "patch")
    minor_version=$(calc_version "$current_version" "minor") 
    major_version=$(calc_version "$current_version" "major")
    
    echo ""
    echo "请选择发布类型:"
    echo "1) 补丁版本 (patch): $current_version → $patch_version"
    echo "2) 次要版本 (minor): $current_version → $minor_version"  
    echo "3) 主要版本 (major): $current_version → $major_version"
    echo "4) 自定义版本"
    echo "5) 只更新CHANGELOG"
    echo ""
    
    read -p "请选择 (1-5): " choice
    
    case $choice in
        1) new_version=$patch_version ;;
        2) new_version=$minor_version ;;  
        3) new_version=$major_version ;;
        4) 
            read -p "请输入新版本号 (格式: x.y.z): " new_version
            if ! validate_version "$new_version"; then
                error "版本号格式无效"
            fi
            ;;
        5)
            update_changelog "$current_version"
            success "已更新CHANGELOG"
            exit 0
            ;;
        *)
            error "无效选择"
            ;;
    esac
    
    info "准备发布版本: $new_version"
    echo ""
    
    # 确认发布
    read -p "确认发布版本 $new_version？(y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        error "已取消发布"
    fi
    
    # 执行发布步骤
    update_versions "$new_version"
    update_changelog "$new_version"
    create_tag "$new_version"
    
    echo ""
    success "🎉 版本 $new_version 发布准备完成！"
    echo ""
    info "下一步操作:"
    echo "1. 编辑 CHANGELOG.md 添加具体变更内容"
    echo "2. 运行: git push origin main --tags" 
    echo "3. GitHub Actions 将自动构建和发布安装包"
    echo ""
}

# 运行主函数
main "$@"