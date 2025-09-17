# Changelog

本文档记录了 CloudCups 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。


## [1.0.0] - 2025-09-17

### 新增
- 新功能描述

### 修改
- 功能改进描述

### 修复
- Bug修复描述

### 已知问题
- 待解决问题描述

## [1.0.0] - 2024-09-17

### 新增
- 🚀 基于 CUPS 的云打印服务
- 🌐 Web 界面管理打印任务
- 📊 实时打印状态监控
- 📋 打印队列管理
- 📦 支持 DEB 和 RPM 安装包
- 🔧 systemd 服务集成和开机自启动
- 🤖 GitHub Actions 自动化构建和发布
- 📚 完整的安装和使用文档

### 技术栈
- **后端**: Bun + Elysia + node-cups
- **前端**: Vue.js + Vite
- **打包**: 单文件可执行程序
- **部署**: systemd 服务

### 系统要求
- **运行时**: CUPS 打印系统
- **支持系统**: Ubuntu/Debian (DEB), RHEL/CentOS/Fedora (RPM)
- **最低版本**: libc6 >= 2.31

### 安装方法

#### Ubuntu/Debian
```bash
sudo dpkg -i cloudcups_1.0.0_amd64.deb
sudo apt-get install -f  # 如果有依赖问题
```

#### RHEL/CentOS/Fedora
```bash
sudo dnf install cloudcups-1.0.0-1.*.x86_64.rpm
```

#### 服务管理
```bash
systemctl status cloudcups    # 查看状态
systemctl restart cloudcups   # 重启服务
journalctl -u cloudcups -f    # 查看日志
```

### 访问方式
- **Web 界面**: http://localhost:3000
- **默认端口**: 3000
