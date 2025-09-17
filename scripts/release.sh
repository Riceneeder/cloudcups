#!/bin/bash
# 版本发布脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印彩色消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 函数：获取当前版本
get_current_version() {
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        grep '"version"' "$PROJECT_ROOT/package.json" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/'
    else
        echo "0.0.0"
    fi
}

# 函数：验证版本格式
validate_version() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# 函数：比较版本
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# 函数：更新版本号
update_version() {
    local new_version=$1
    
    print_info "更新版本号到 $new_version..."
    
    # 更新主 package.json
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        sed -i.bak "s/\"version\": \".*\"/\"version\": \"$new_version\"/" "$PROJECT_ROOT/package.json"
        rm -f "$PROJECT_ROOT/package.json.bak"
        print_success "已更新 package.json"
    fi
    
    # 更新后端 package.json
    if [ -f "$PROJECT_ROOT/backend/package.json" ]; then
        sed -i.bak "s/\"version\": \".*\"/\"version\": \"$new_version\"/" "$PROJECT_ROOT/backend/package.json"
        rm -f "$PROJECT_ROOT/backend/package.json.bak"
        print_success "已更新 backend/package.json"
    fi
    
    # 更新 DEB 包版本
    if [ -f "$PROJECT_ROOT/packaging/deb/DEBIAN/control" ]; then
        sed -i.bak "s/^Version:.*/Version: $new_version/" "$PROJECT_ROOT/packaging/deb/DEBIAN/control"
        rm -f "$PROJECT_ROOT/packaging/deb/DEBIAN/control.bak"
        print_success "已更新 DEB 包版本"
    fi
    
    # 更新 RPM 包版本
    if [ -f "$PROJECT_ROOT/packaging/rpm/cloudcups.spec" ]; then
        sed -i.bak "s/^Version:.*/Version:        $new_version/" "$PROJECT_ROOT/packaging/rpm/cloudcups.spec"
        rm -f "$PROJECT_ROOT/packaging/rpm/cloudcups.spec.bak"
        print_success "已更新 RPM 包版本"
    fi
}

# 函数：生成changelog条目
generate_changelog_entry() {
    local version=$1
    local date=$(date '+%Y-%m-%d')
    
    cat << EOF

## [$version] - $date

### 新增
- 新功能描述

### 修改
- 功能改进描述

### 修复
- Bug修复描述

### 已知问题
- 待解决问题描述

EOF
}

# 函数：创建或更新CHANGELOG
update_changelog() {
    local version=$1
    local changelog_file="$PROJECT_ROOT/CHANGELOG.md"
    
    if [ ! -f "$changelog_file" ]; then
        print_info "创建 CHANGELOG.md 文件..."
        cat > "$changelog_file" << EOF
# Changelog

本文档记录了 CloudCups 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

$(generate_changelog_entry "$version")
EOF
    else
        print_info "更新 CHANGELOG.md 文件..."
        # 创建新的changelog条目
        local temp_entry=$(mktemp)
        generate_changelog_entry "$version" > "$temp_entry"
        
        # 在第一个 ## 标题前插入新的版本条目
        local temp_file=$(mktemp)
        {
            # 添加文件头部直到第一个 ##
            awk '/^## / { exit } { print }' "$changelog_file"
            # 插入新版本条目
            cat "$temp_entry"
            # 添加剩余内容
            awk '/^## / { found=1 } found { print }' "$changelog_file"
        } > "$temp_file"
        
        mv "$temp_file" "$changelog_file"
        rm -f "$temp_entry"
    fi
    
    print_success "已更新 CHANGELOG.md"
    print_warning "请编辑 CHANGELOG.md 添加具体的变更内容"
}

# 函数：创建git tag
create_git_tag() {
    local version=$1
    local tag="v$version"
    
    print_info "检查Git状态..."
    
    # 检查是否在git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是Git仓库"
        return 1
    fi
    
    # 检查是否有未提交的变更
    if ! git diff-index --quiet HEAD --; then
        print_warning "存在未提交的变更，是否继续？(y/N)"
        read -r response
        if [[ ! $response =~ ^[Yy]$ ]]; then
            print_error "已取消发布"
            return 1
        fi
    fi
    
    # 检查tag是否已存在
    if git tag -l | grep -q "^$tag$"; then
        print_error "标签 $tag 已存在"
        return 1
    fi
    
    # 提交版本变更
    git add -A
    git commit -m "chore: bump version to $version" || true
    
    # 创建标签
    git tag -a "$tag" -m "Release $version"
    
    print_success "已创建Git标签: $tag"
    print_info "推送到远程仓库: git push origin main --tags"
}

# 主逻辑
main() {
    echo "🚀 CloudCups 版本发布工具"
    echo "=========================="
    
    local current_version
    current_version=$(get_current_version)
    print_info "当前版本: $current_version"
    
    echo ""
    echo "请选择发布类型:"
    echo "1) 补丁版本 (patch: $current_version → $(echo $current_version | awk -F. '{print $1"."$2"."($3+1)}')"
    echo "2) 次要版本 (minor: $current_version → $(echo $current_version | awk -F. '{print $1"."($2+1)".0"}')"
    echo "3) 主要版本 (major: $current_version → $(echo $current_version | awk -F. '{print ($1+1)".0.0"}')"
    echo "4) 自定义版本"
    echo "5) 只更新CHANGELOG"
    echo ""
    read -p "请选择 (1-5): " choice
    
    local new_version
    case $choice in
        1)
            new_version=$(echo $current_version | awk -F. '{print $1"."$2"."($3+1)}')
            ;;
        2)
            new_version=$(echo $current_version | awk -F. '{print $1"."($2+1)".0"}')
            ;;
        3)
            new_version=$(echo $current_version | awk -F. '{print ($1+1)".0.0"}')
            ;;
        4)
            read -p "请输入新版本号 (格式: x.y.z): " new_version
            if ! validate_version "$new_version"; then
                print_error "版本号格式无效"
                exit 1
            fi
            if ! version_gt "$new_version" "$current_version"; then
                print_error "新版本号必须大于当前版本"
                exit 1
            fi
            ;;
        5)
            update_changelog "$current_version"
            print_success "已更新CHANGELOG"
            exit 0
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac
    
    print_info "准备发布版本: $new_version"
    
    # 确认发布
    echo ""
    read -p "确认发布版本 $new_version？(y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_error "已取消发布"
        exit 1
    fi
    
    # 执行发布流程
    update_version "$new_version"
    update_changelog "$new_version"
    create_git_tag "$new_version"
    
    echo ""
    print_success "🎉 版本 $new_version 发布准备完成！"
    echo ""
    print_info "下一步操作:"
    echo "1. 编辑 CHANGELOG.md 添加具体变更内容"
    echo "2. 运行: git push origin main --tags"
    echo "3. GitHub Actions 将自动构建和发布安装包"
    echo ""
}

# 运行主函数
main "$@"