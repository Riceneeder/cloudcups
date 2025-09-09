# CloudCups 贡献指南

感谢您对 CloudCups 项目的关注！我们欢迎任何形式的贡献，包括但不限于：

- 🐛 报告错误
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 修复代码问题
- ✨ 实现新功能

## 开始之前

在开始贡献之前，请确保您已经：

1. 阅读了项目的 [README](README.md)
2. 检查了现有的 [Issues](https://github.com/your-username/cloudcups/issues) 以避免重复工作
3. 了解项目的技术栈和架构

## 开发环境设置

### 1. Fork 并克隆仓库

```bash
# Fork 仓库到您的 GitHub 账户
# 然后克隆到本地
git clone https://github.com/your-username/cloudcups.git
cd cloudcups
```

### 2. 安装依赖

```bash
# 安装 Bun（如果还没有安装）
curl -fsSL https://bun.sh/install | bash

# 安装项目依赖
bun install
```

### 3. 设置开发环境

```bash
# 安装系统依赖（Ubuntu/Debian）
sudo apt-get install cups libcups2-dev

# 启动 CUPS 服务
sudo systemctl start cups
sudo systemctl enable cups
```

### 4. 运行开发服务器

```bash
# 启动前端开发服务器
bun run dev:frontend

# 在新终端启动后端服务器
bun run dev:backend
```

## 提交代码规范

### 分支命名

使用以下格式创建分支：

- `feature/功能名称` - 新功能
- `fix/问题描述` - 错误修复
- `docs/文档更新` - 文档改进
- `refactor/重构描述` - 代码重构
- `test/测试描述` - 测试相关

示例：
```bash
git checkout -b feature/add-print-preview
git checkout -b fix/file-upload-error
git checkout -b docs/api-documentation
```

### 提交信息格式

请使用以下格式编写提交信息：

```
<类型>(<范围>): <简短描述>

<详细描述>（可选）

<相关 Issue>（可选）
```

**类型：**
- `feat`: 新功能
- `fix`: 错误修复
- `docs`: 文档更新
- `style`: 代码格式（不影响代码逻辑）
- `refactor`: 重构（既不是新功能也不是修复）
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

**示例：**
```
feat(frontend): 添加打印预览功能

- 在文件上传后显示预览界面
- 支持 PDF 和图片格式预览
- 添加预览缩放功能

Closes #123
```

### 代码风格

#### TypeScript/JavaScript
- 使用 2 个空格缩进
- 使用分号结尾
- 使用单引号
- 变量名使用 camelCase
- 常量使用 UPPER_SNAKE_CASE
- 类名使用 PascalCase

#### Vue 组件
- 组件名使用 PascalCase
- Props 使用 camelCase
- 事件名使用 kebab-case
- 使用 Composition API

#### CSS/SCSS
- 使用 2 个空格缩进
- 类名使用 kebab-case
- 避免使用 !important

### 测试

在提交代码前，请确保：

```bash
# 检查前端构建
bun run build:frontend

# 检查后端构建
bun run build:backend

# 运行单元测试（如果有）
bun test
```

## Pull Request 流程

### 1. 准备工作

```bash
# 确保您的分支是最新的
git checkout main
git pull origin main

# 创建新分支
git checkout -b feature/your-feature-name
```

### 2. 开发和提交

```bash
# 进行您的更改
# ...

# 添加文件
git add .

# 提交更改
git commit -m "feat: 添加新功能描述"
```

### 3. 推送和创建 PR

```bash
# 推送到您的 fork
git push origin feature/your-feature-name
```

然后在 GitHub 上创建 Pull Request。

### 4. PR 描述模板

请使用以下模板描述您的 PR：

```markdown
## 更改类型
- [ ] 新功能
- [ ] 错误修复
- [ ] 文档更新
- [ ] 代码重构
- [ ] 性能优化
- [ ] 其他

## 更改描述
简要描述您的更改内容...

## 测试
- [ ] 已在本地测试
- [ ] 已添加相关测试用例
- [ ] 所有现有测试通过

## 截图（如适用）
<!-- 如果是 UI 相关更改，请提供截图 -->

## 相关 Issue
Closes #issue_number

## 检查清单
- [ ] 代码遵循项目编码规范
- [ ] 自测通过
- [ ] 已更新相关文档
- [ ] PR 标题和描述清晰明了
```

## 报告问题

如果您发现了错误或有功能建议，请：

1. 搜索现有 Issues 确保问题未被报告
2. 使用 Issue 模板创建新 Issue
3. 提供详细的重现步骤和环境信息

### Bug 报告模板

```markdown
## 环境信息
- OS: [e.g. Ubuntu 20.04]
- Bun 版本: [e.g. 1.0.0]
- CUPS 版本: [e.g. 2.3.3]

## 问题描述
简要描述遇到的问题...

## 重现步骤
1. 执行 '...'
2. 点击 '....'
3. 滚动到 '....'
4. 看到错误

## 期望行为
描述您期望发生的行为...

## 实际行为
描述实际发生的行为...

## 截图
如果适用，添加截图来解释您的问题。

## 附加信息
添加任何其他相关信息...
```

## 社区准则

- 保持友善和尊重
- 建设性地参与讨论
- 帮助新贡献者
- 遵循项目的编码标准
- 耐心等待代码审查

## 获得帮助

如果您在贡献过程中遇到问题：

- 查看项目 [Wiki](https://github.com/your-username/cloudcups/wiki)
- 在 [Discussions](https://github.com/your-username/cloudcups/discussions) 中提问
- 查看现有的 [Issues](https://github.com/your-username/cloudcups/issues)

感谢您的贡献！🎉
