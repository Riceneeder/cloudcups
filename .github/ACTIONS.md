# GitHub Actions CI/CD 使用指南

本文档说明如何使用GitHub Actions自动构建和发布CloudCups的Linux安装包。

## 🚀 概述

CloudCups项目配置了完整的CI/CD流程，包括：

- **自动构建**: 每次push到main分支或PR时自动构建DEB和RPM包
- **自动发布**: 创建Git标签时自动发布到GitHub Releases
- **多格式支持**: 同时构建DEB包（Ubuntu/Debian）和RPM包（RHEL/CentOS/Fedora）

## 📁 工作流文件

### `.github/workflows/build.yml`
- **触发条件**: push到main/develop分支，或PR到main分支
- **功能**: 构建和测试安装包
- **产物**: 保存构建的DEB和RPM包作为artifacts

### `.github/workflows/release.yml`
- **触发条件**: 推送标签（v*）或手动触发
- **功能**: 创建GitHub Release并上传安装包
- **产物**: 公开的发布页面和下载链接

## 🔄 发布流程

### 1. 本地准备发布

使用项目提供的发布脚本：

```bash
# 运行发布脚本
./scripts/release.sh
```

发布脚本会：
- 显示当前版本
- 提供版本升级选项（patch/minor/major/custom）
- 自动更新所有相关文件的版本号
- 更新或创建CHANGELOG.md
- 创建Git标签

### 2. 推送到GitHub

```bash
# 推送代码和标签
git push origin main --tags
```

### 3. 自动化流程

推送标签后，GitHub Actions会自动：
1. 创建GitHub Release
2. 构建DEB和RPM包
3. 上传包文件到Release
4. 更新README中的下载链接

## 🛠️ 工作流配置

### 环境要求

工作流在Ubuntu Latest环境中运行，需要：

- **Bun**: JavaScript运行时和包管理器
- **系统依赖**: cups, cups-client, dpkg-dev, rpm
- **权限**: GITHUB_TOKEN用于创建Release

### 构建矩阵

使用矩阵构建策略同时构建多种包格式：

```yaml
strategy:
  matrix:
    package-type: [deb, rpm]
```

### 版本管理

版本号从Git标签中提取，并自动更新到：
- `package.json`
- `backend/package.json`
- `packaging/deb/DEBIAN/control`
- `packaging/rpm/cloudcups.spec`

## 🎯 手动触发发布

除了标签触发，还支持手动触发发布：

1. 进入GitHub仓库的Actions页面
2. 选择"Release"工作流
3. 点击"Run workflow"
4. 输入版本号（如v1.0.1）
5. 点击"Run workflow"

## 📦 发布产物

每次成功发布会生成：

- `cloudcups_X.Y.Z_amd64.deb` - Debian/Ubuntu安装包
- `cloudcups-X.Y.Z-1.*.x86_64.rpm` - RHEL/CentOS/Fedora安装包

## 🔍 监控构建

### 查看构建状态

1. 进入GitHub仓库
2. 点击"Actions"标签
3. 查看工作流运行状态

### 构建失败排查

常见问题：

1. **依赖安装失败**
   - 检查system dependencies安装步骤
   - 确认包管理器可用

2. **构建脚本权限**
   - 确认脚本有执行权限
   - 检查chmod命令是否正确执行

3. **版本号格式错误**
   - 确认标签格式为`vX.Y.Z`
   - 检查版本号更新脚本

4. **Token权限不足**
   - 确认GITHUB_TOKEN有足够权限
   - 检查仓库设置中的Actions权限

### 查看构建日志

1. 进入失败的工作流运行
2. 展开具体的构建步骤
3. 查看详细错误信息

## 🔧 自定义配置

### 修改构建环境

编辑`.github/workflows/build.yml`：

```yaml
runs-on: ubuntu-latest  # 可改为其他环境
```

### 添加新的包格式

1. 创建新的构建脚本
2. 更新构建矩阵：
   ```yaml
   strategy:
     matrix:
       package-type: [deb, rpm, new-format]
   ```

### 修改发布条件

编辑`.github/workflows/release.yml`：

```yaml
on:
  push:
    tags:
      - 'v*'      # 标签模式
    branches:
      - 'release/*'  # 分支模式
```

## 📋 最佳实践

### 版本管理

1. **遵循语义化版本**: 使用`MAJOR.MINOR.PATCH`格式
2. **编写详细的CHANGELOG**: 记录每个版本的变更
3. **测试发布**: 在fork仓库中测试工作流

### 构建优化

1. **缓存依赖**: 使用GitHub Actions的缓存功能
2. **并行构建**: 利用矩阵策略加速构建
3. **构建验证**: 在构建后验证包文件

### 发布策略

1. **预发布测试**: 使用draft release测试
2. **分阶段发布**: 先发布beta版本
3. **回滚计划**: 保留旧版本的发布

## 🆘 故障排除

### 常见错误

**Error: Resource not accessible by integration**
- 解决方案: 检查GITHUB_TOKEN权限设置

**Error: Tag already exists**
- 解决方案: 使用新的版本号或删除旧标签

**Error: Package build failed**
- 解决方案: 检查构建依赖和脚本权限

### 获取帮助

1. 查看GitHub Actions文档
2. 检查工作流语法
3. 参考类似项目的配置
4. 在GitHub Issues中寻求帮助

## 📚 相关文档

- [GitHub Actions文档](https://docs.github.com/en/actions)
- [工作流语法](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [发布管理](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [CloudCups打包指南](../PACKAGING.md)