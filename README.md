# CloudCups 云打印服务

[![Bun](https://img.shields.io/badge/Bun-^1.0-black.svg)](https://bun.sh/)
[![Vue 3](https://img.shields.io/badge/Vue-3.4-green.svg)](https://vuejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.4-blue.svg)](https://www.typescriptlang.org/)

## 项目简介

CloudCups 是一个基于现代 Web 技术栈构建的云打印解决方案，提供直观的 Web 界面用于文件上传、打印参数配置和打印任务管理。项目采用前后端分离架构，支持单文件可执行程序部署。

### 核心特性

- 🚀 **高性能运行时**：基于 Bun 构建的高性能后端服务
- 🎨 **现代化界面**：Vue 3 + Element Plus 构建的响应式 Web 界面
- 📁 **多格式支持**：支持 PDF、Word、图片等多种文件格式打印
- ⚙️ **灵活配置**：支持双面打印、彩色/黑白、纸张规格等多种打印选项
- 📊 **实时日志**：内置日志系统，支持实时查看打印任务状态
- 📦 **一键部署**：支持编译为单文件可执行程序，无需额外依赖

## 技术栈

### 后端
- **运行时**：[Bun](https://bun.sh/) - 高性能 JavaScript 运行时
- **Web 框架**：[Elysia.js](https://elysiajs.com/) - 轻量级 TypeScript Web 框架
- **打印接口**：[node-cups](https://www.npmjs.com/package/node-cups) - CUPS 打印系统接口
- **日志系统**：自研文件日志系统，支持日志轮转和实时查看

### 前端
- **框架**：[Vue 3](https://vuejs.org/) - 渐进式 JavaScript 框架
- **UI 组件**：[Element Plus](https://element-plus.org/) - Vue 3 UI 组件库
- **状态管理**：[Pinia](https://pinia.vuejs.org/) - Vue 状态管理库
- **构建工具**：[Vite](https://vitejs.dev/) - 下一代前端构建工具
- **HTTP 客户端**：[Axios](https://axios-http.com/) - Promise 风格的 HTTP 库

### 系统依赖
- **打印系统**：CUPS (Common Unix Printing System)
- **操作系统**：Linux / macOS / Windows (WSL)

## 快速开始

### 环境要求

- **Node.js/Bun**：建议使用 Bun >= 1.0 版本
- **CUPS**：系统需安装并配置 CUPS 打印服务
- **系统**：Linux (推荐)、macOS 或 Windows (WSL)

### 1. 安装 Bun

```bash
# Linux/macOS
curl -fsSL https://bun.sh/install | bash

# 或使用 npm 安装
npm install -g bun
```

### 2. 系统依赖安装

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install cups libcups2-dev
sudo systemctl enable cups
sudo systemctl start cups
```

#### CentOS/RHEL/Fedora
```bash
sudo dnf install cups cups-devel
sudo systemctl enable cups
sudo systemctl start cups
```

#### macOS
```bash
# macOS 通常预装 CUPS，直接在系统偏好设置中添加打印机
# 如需开发依赖，安装 Xcode Command Line Tools
xcode-select --install
```

### 3. 克隆并安装项目

```bash
git clone <repository-url>
cd cloudcups
bun install
```

### 4. 开发环境运行

```bash
# 启动前端开发服务器 (端口: 5173)
bun run dev:frontend

# 新终端窗口启动后端服务器 (端口: 3000)
bun run dev:backend
```

访问 `http://localhost:5173` 即可使用 Web 打印界面。

### 5. 生产环境部署

#### 方法一：编译单文件可执行程序
```bash
# 构建并编译为单文件可执行程序
bun run compile

# 运行
./deploy/cloudcups
```

#### 方法二：分别构建前后端
```bash
# 构建前端
bun run build:frontend

# 启动后端生产服务器
bun run start
```

## 功能特性

### Web 打印界面
- 📁 **文件上传**：拖拽或点击上传 PDF、Word、图片文件
- ⚙️ **打印配置**：支持打印机选择、份数、双面打印、彩色模式等
- 📄 **纸张设置**：支持 A4、A3、Letter 等多种纸张规格
- 🔄 **方向选择**：纵向/横向打印模式
- 📖 **页面范围**：支持指定打印页面范围（如：1-3,5）

### 日志管理
- 📊 **实时日志**：Web 界面实时查看打印任务日志
- 📁 **日志轮转**：按日期自动轮转日志文件
- 🔍 **日志分级**：DEBUG、INFO、WARN、ERROR 多级日志

### 部署方式
- 📦 **单文件部署**：编译为独立可执行文件，无需额外依赖
- 🚀 **容器化**：支持 Docker 容器化部署
- 🔧 **开发模式**：热重载开发环境

## API 文档

### 获取打印机列表
```http
GET /api/printers
```

**响应**：
```json
{
  "printers": [
    {
      "name": "HP_LaserJet",
      "description": "HP LaserJet Pro",
      "state": "idle",
      "uri": "ipp://192.168.1.100:631/printers/HP_LaserJet"
    }
  ]
}
```

### 提交打印任务
```http
POST /api/print
Content-Type: multipart/form-data
```

**请求参数**：
- `file`：要打印的文件 (PDF/Word/图片)
- `options`：打印选项 JSON 字符串

**打印选项示例**：
```json
{
  "printer": "HP_LaserJet",
  "copies": 2,
  "duplex": true,
  "color": false,
  "media": "A4",
  "orientation": "portrait",
  "pageRange": "1-3,5"
}
```

**响应**：
```json
{
  "jobId": 123,
  "message": "打印任务提交成功"
}
```

### 获取日志
```http
GET /api/logs?date=2025-09-09
```

**响应**：
```json
{
  "logs": [
    {
      "timestamp": "2025-09-09T10:30:00.000Z",
      "level": "INFO",
      "message": "打印任务提交成功",
      "data": {"jobId": 123}
    }
  ]
}
```

## 打印参数说明

### PrintOptions 接口

```typescript
interface PrintOptions {
  printer: string;          // 打印机名称
  copies: number;           // 打印份数
  duplex?: boolean;         // 双面打印（可选，默认 false）
  color?: boolean;          // 彩色打印（可选，默认 false）
  media: string;            // 纸张规格（A4、A3、Letter 等）
  orientation: 'portrait' | 'landscape';  // 打印方向
  pageRange?: string;       // 页面范围（可选，如："1-3,5"）
}
```

### 支持的文件格式
- **PDF**：`.pdf`
- **Microsoft Word**：`.doc`, `.docx`
- **图片**：`.png`, `.jpg`, `.jpeg`

### 纸张规格
- A4 (210 × 297 mm)
- A3 (297 × 420 mm)
- Letter (216 × 279 mm)
- Legal (216 × 356 mm)
- 其他 CUPS 支持的标准规格

## 项目结构

```
cloudcups/
├── backend/                 # 后端服务
│   ├── server.ts           # 开发服务器入口
│   ├── server-production.ts # 生产服务器入口
│   ├── cupsManager.ts      # CUPS 打印管理
│   ├── logger.ts           # 日志系统
│   ├── logRoutes.ts        # 日志 API 路由
│   ├── types.ts            # TypeScript 类型定义
│   └── logs/               # 日志文件目录
├── frontend/               # 前端应用
│   ├── src/
│   │   ├── views/
│   │   │   ├── PrintView.vue    # 打印界面
│   │   │   └── LogView.vue      # 日志查看界面
│   │   ├── components/
│   │   │   └── FileUploader.vue # 文件上传组件
│   │   ├── stores/
│   │   │   └── print.js         # 打印状态管理
│   │   └── utils/
│   │       └── logger.ts        # 前端日志工具
│   ├── index.html          # 入口 HTML
│   └── vite.config.ts      # Vite 配置
├── deploy/                 # 部署目录
│   ├── cloudcups          # 编译后的可执行文件
│   ├── static/            # 静态资源
│   └── logs/              # 运行时日志
├── build.sh               # 构建脚本
└── package.json           # 项目配置
```

## 常见问题与解决方案

### 系统配置问题

**Q: CUPS 服务未启动？**
```bash
# 检查 CUPS 服务状态
systemctl status cups

# 启动 CUPS 服务
sudo systemctl start cups
sudo systemctl enable cups
```

**Q: 找不到打印机？**
```bash
# 检查系统打印机
lpstat -p

# 添加网络打印机
sudo lpadmin -p printer_name -E -v ipp://printer_ip:631/ipp/print
```

### 开发问题

**Q: node-cups 编译失败？**
- 确保安装了 `libcups2-dev` (Ubuntu) 或 `cups-devel` (CentOS)
- macOS 需要安装 Xcode Command Line Tools
- 如遇兼容性问题，程序会自动回退到命令行模式

**Q: 前端无法连接后端？**
- 检查后端服务是否在 3000 端口运行
- 确认防火墙设置允许相关端口访问
- 检查 CORS 配置是否正确

**Q: 文件上传失败？**
- 检查文件格式是否为支持的类型
- 确认文件大小不超过系统限制
- 检查磁盘空间是否充足

### 性能优化

**Q: 大文件打印缓慢？**
- 考虑调整 CUPS 配置的最大作业大小
- 检查网络带宽和打印机处理能力
- 对于高频使用场景，建议使用 SSD 存储

**Q: 内存占用过高？**
- 单文件部署模式内存占用较低
- 开发模式下可能因热重载占用更多内存
- 生产环境建议使用编译后的可执行文件

## 配置说明

### 环境变量

```bash
# 后端服务端口（默认：3000）
PORT=3000

# 日志级别（DEBUG|INFO|WARN|ERROR，默认：INFO）
LOG_LEVEL=INFO

# 日志目录（默认：logs）
LOG_DIR=logs

# 临时文件目录（默认：/tmp）
TEMP_DIR=/tmp
```

### CUPS 配置优化

编辑 `/etc/cups/cupsd.conf`：
```bash
# 允许网络访问
Listen *:631

# 设置访问权限
<Location />
  Order allow,deny
  Allow all
</Location>

# 增加最大作业大小 (例如：100MB)
MaxRequestSize 100m
```

重启 CUPS 服务：
```bash
sudo systemctl restart cups
```

## 开发指南

### 添加新的文件格式支持

1. 在 `backend/cupsManager.ts` 中添加文件格式检查
2. 更新 `frontend/src/components/FileUploader.vue` 的文件过滤器
3. 测试新格式的打印兼容性

### 自定义打印选项

1. 修改 `backend/types.ts` 中的 `PrintOptions` 接口
2. 更新前端打印表单组件
3. 在 `cupsManager.ts` 中实现新选项的处理逻辑

### 日志系统扩展

现有日志系统支持：
- 按日期轮转
- 多级日志（DEBUG、INFO、WARN、ERROR）
- JSON 格式结构化日志
- 实时日志查看 API

可根据需求扩展更多功能，如日志压缩、远程日志传输等。

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献指南

欢迎提交 Issues 和 Pull Requests！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启 Pull Request

## 联系方式

如有问题或建议，请通过以下方式联系：

- 🐛 Issues: [GitHub Issues](https://github.com/your-username/cloudcups/issues)
- 📖 文档: [项目 Wiki](https://github.com/your-username/cloudcups/wiki)

---

**CloudCups** - 让打印更简单，让管理更智能 🚀
