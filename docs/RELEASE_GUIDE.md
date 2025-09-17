# CloudCups 发布脚本使用指南

## 📋 概述

`./scripts/release.sh` 是CloudCups项目的版本发布管理工具，用于自动化版本升级、更新文件和创建Git标签的过程。

## 🚀 快速开始

### 基本使用

```bash
# 在项目根目录运行
./scripts/release.sh
```

### 可选：使用简化版本

如果遇到问题，可以使用简化版本：

```bash
./scripts/release-simple.sh
```

## 📝 使用步骤详解

### 1. 运行发布脚本

```bash
cd /Users/ganzhengkun/Documents/GitHub/cloudcups
./scripts/release.sh
```

### 2. 选择发布类型

脚本会显示当前版本并提供以下选项：

```
🚀 CloudCups 版本发布工具
==========================
ℹ️  当前版本: 0.1.0

请选择发布类型:
1) 补丁版本 (patch): 0.1.0 → 0.1.1
2) 次要版本 (minor): 0.1.0 → 0.2.0  
3) 主要版本 (major): 0.1.0 → 1.0.0
4) 自定义版本
5) 只更新CHANGELOG

请选择 (1-5): 
```

#### 版本类型说明：

- **补丁版本 (patch)**: 用于Bug修复，第三位数字+1
- **次要版本 (minor)**: 用于新功能添加，第二位数字+1，第三位重置为0
- **主要版本 (major)**: 用于重大更改，第一位数字+1，后两位重置为0
- **自定义版本**: 手动输入版本号（必须遵循x.y.z格式）
- **只更新CHANGELOG**: 仅更新变更日志，不升级版本

### 3. 确认发布

选择版本类型后，脚本会要求确认：

```
ℹ️  准备发布版本: 1.0.0

确认发布版本 1.0.0？(y/N): y
```

输入 `y` 确认，或 `N` 取消。

### 4. 自动化处理

确认后，脚本会自动执行：

1. **更新版本号** - 更新以下文件的版本：
   - `package.json`
   - `backend/package.json`  
   - `packaging/deb/DEBIAN/control`
   - `packaging/rpm/cloudcups.spec`

2. **更新CHANGELOG** - 在 `CHANGELOG.md` 中添加新版本条目

3. **创建Git标签** - 提交变更并创建版本标签

### 5. 完成后步骤

脚本执行完成后，需要手动完成：

1. **编辑CHANGELOG.md** - 添加具体的变更内容
2. **推送到GitHub** - 运行 `git push origin main --tags`
3. **自动发布** - GitHub Actions将自动构建和发布

## 📖 示例操作

### 示例1：发布补丁版本

```bash
$ ./scripts/release.sh

🚀 CloudCups 版本发布工具
==========================
ℹ️  当前版本: 0.1.0

请选择发布类型:
1) 补丁版本 (patch): 0.1.0 → 0.1.1
2) 次要版本 (minor): 0.1.0 → 0.2.0
3) 主要版本 (major): 0.1.0 → 1.0.0
4) 自定义版本
5) 只更新CHANGELOG

请选择 (1-5): 1
ℹ️  准备发布版本: 0.1.1

确认发布版本 0.1.1？(y/N): y
ℹ️  更新版本号到 0.1.1...
✅ 已更新 package.json
✅ 已更新 backend/package.json
✅ 已更新 DEB 包版本
✅ 已更新 RPM 包版本
✅ 已更新 CHANGELOG.md
⚠️  请编辑 CHANGELOG.md 添加具体的变更内容
ℹ️  检查Git状态...
✅ 已创建Git标签: v0.1.1

🎉 版本 0.1.1 发布准备完成！

ℹ️  下一步操作:
1. 编辑 CHANGELOG.md 添加具体变更内容
2. 运行: git push origin main --tags
3. GitHub Actions 将自动构建和发布安装包
```

### 示例2：自定义版本

```bash
请选择 (1-5): 4
请输入新版本号 (格式: x.y.z): 2.0.0
ℹ️  准备发布版本: 2.0.0
```

## 🔧 故障排除

### 常见问题

#### 1. 脚本执行权限问题

```bash
# 设置执行权限
chmod +x ./scripts/release.sh
```

#### 2. 版本号格式错误

```
❌ 版本号格式无效
```

**解决方案**: 确保版本号格式为 `x.y.z`，例如 `1.0.0`、`2.1.3`

#### 3. Git标签已存在

```
❌ 标签 v1.0.0 已存在
```

**解决方案**: 
- 选择不同的版本号，或
- 删除现有标签：`git tag -d v1.0.0`

#### 4. 不在Git仓库中

```
❌ 当前目录不是Git仓库
```

**解决方案**: 确保在CloudCups项目根目录中运行脚本

#### 5. package.json缺少版本字段

如果主 `package.json` 缺少 `version` 字段，脚本会无法读取当前版本。

**解决方案**: 手动添加版本字段：

```json
{
  "name": "cloudcups",
  "version": "0.1.0",
  "private": true,
  ...
}
```

### 手动修复步骤

如果脚本出现问题，可以手动执行以下步骤：

1. **手动更新版本号**：
   ```bash
   # 编辑 package.json
   vim package.json
   
   # 编辑其他版本文件
   vim backend/package.json
   vim packaging/deb/DEBIAN/control
   vim packaging/rpm/cloudcups.spec
   ```

2. **手动更新CHANGELOG**：
   ```bash
   vim CHANGELOG.md
   ```

3. **手动创建标签**：
   ```bash
   git add -A
   git commit -m "chore: bump version to 1.0.0"
   git tag -a v1.0.0 -m "Release 1.0.0"
   ```

4. **推送到GitHub**：
   ```bash
   git push origin main --tags
   ```

## 🎯 最佳实践

### 发布前检查

1. **确保代码质量**：
   - 运行测试：`bun test`
   - 检查构建：`./build.sh`
   - 检查代码风格

2. **确认变更内容**：
   - 查看 `git diff` 确认所有变更
   - 确保没有敏感信息

3. **选择合适的版本类型**：
   - Bug修复 → patch版本
   - 新功能 → minor版本  
   - 重大变更 → major版本

### 发布后检查

1. **验证GitHub Actions**：
   - 检查构建状态
   - 确认包文件正确生成

2. **测试安装包**：
   - 下载生成的DEB/RPM包
   - 在测试环境中安装验证

3. **更新文档**：
   - 更新README中的版本信息
   - 更新用户文档

## 📚 相关文档

- [GitHub Actions使用指南](../.github/ACTIONS.md)
- [打包指南](../PACKAGING.md)
- [语义化版本](https://semver.org/lang/zh-CN/)
- [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)