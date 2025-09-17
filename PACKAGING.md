# CloudCups Linux 发行版打包指南

本文档说明如何为 CloudCups 项目创建 Linux 发行版安装包，包括 DEB 和 RPM 格式。

## 📦 打包概述

CloudCups 现在支持以下 Linux 发行版的原生安装包：

- **DEB 包**: 适用于 Ubuntu、Debian、Linux Mint 等基于 Debian 的发行版
- **RPM 包**: 适用于 RHEL、CentOS、Fedora、openSUSE 等基于 RPM 的发行版

## 🚀 快速开始

### 使用一键构建脚本

```bash
cd packaging
./build-packages.sh
```

这个交互式脚本会：
1. 检查系统环境和构建工具
2. 提供菜单选择构建选项
3. 自动构建所需的安装包

### 构建特定格式的包

```bash
# 只构建 DEB 包
./packaging/build-deb.sh

# 只构建 RPM 包
./packaging/build-rpm.sh
```

## 📋 构建要求

### 开发环境

- **Bun**: JavaScript 运行时和包管理器
- **DEB 构建**: `dpkg-deb` (通常在 Debian/Ubuntu 上预装)
- **RPM 构建**: `rpmbuild` (需要安装 `rpm-build` 包)

### 安装环境要求

目标 Linux 系统需要：
- `cups` 和 `cups-client` (CUPS 打印系统)
- `systemd` (服务管理)
- `libc6 >= 2.31` (DEB 包要求)

## 🏗️ 打包结构

### 目录结构

```
packaging/
├── build-packages.sh          # 主构建脚本 (交互式)
├── build-deb.sh              # DEB 包构建脚本
├── build-rpm.sh              # RPM 包构建脚本
├── install.sh                # 手动安装脚本
├── uninstall.sh              # 手动卸载脚本
├── README.md                 # 详细说明文档
├── deb/                      # DEB 包构建目录
│   ├── DEBIAN/
│   │   ├── control           # 包信息和依赖
│   │   ├── postinst          # 安装后脚本
│   │   ├── prerm             # 卸载前脚本
│   │   └── postrm            # 卸载后脚本
│   ├── opt/cloudcups/        # 程序安装目录
│   └── lib/systemd/system/   # systemd 服务文件
└── rpm/
    └── cloudcups.spec        # RPM 规格文件
```

### 安装包内容

打包后的程序将安装到：
- **程序目录**: `/opt/cloudcups/`
- **可执行文件**: `/opt/cloudcups/cloudcups`
- **Web 静态文件**: `/opt/cloudcups/static/`
- **日志目录**: `/opt/cloudcups/logs/`
- **服务文件**: `/lib/systemd/system/cloudcups.service`

## 🔧 安装包功能

### 自动化安装流程

1. **用户管理**: 创建专用的 `cloudcups` 系统用户
2. **文件部署**: 复制程序文件到 `/opt/cloudcups/`
3. **权限设置**: 设置正确的文件和目录权限
4. **服务注册**: 安装和启用 systemd 服务
5. **自动启动**: 设置开机自启动并立即启动服务

### 服务管理

安装后，CloudCups 作为系统服务运行：

```bash
# 服务状态
systemctl status cloudcups

# 启动/停止/重启
sudo systemctl start cloudcups
sudo systemctl stop cloudcups
sudo systemctl restart cloudcups

# 开机自启动
sudo systemctl enable cloudcups
sudo systemctl disable cloudcups

# 查看日志
journalctl -u cloudcups -f
```

### Web 界面

- **访问地址**: http://localhost:3000
- **默认端口**: 3000 (可在服务文件中修改)

## 📦 安装方法

### DEB 包安装 (Ubuntu/Debian)

```bash
# 下载并安装
sudo dpkg -i cloudcups_1.0.0_amd64.deb

# 如果有依赖问题，修复依赖
sudo apt-get install -f
```

### RPM 包安装 (RHEL/CentOS/Fedora)

```bash
# 使用 rpm 安装
sudo rpm -ivh cloudcups-1.0.0-1.*.x86_64.rpm

# 或使用 dnf/yum 安装 (推荐)
sudo dnf install cloudcups-1.0.0-1.*.x86_64.rpm
```

### 手动安装

如果不想使用包管理器：

```bash
# 使用项目提供的安装脚本
sudo ./packaging/install.sh
```

## 🗑️ 卸载方法

### 使用包管理器

```bash
# DEB 包卸载
sudo dpkg -r cloudcups          # 保留配置文件
sudo dpkg -P cloudcups          # 完全卸载

# RPM 包卸载
sudo rpm -e cloudcups
```

### 手动卸载

```bash
sudo ./packaging/uninstall.sh
```

## 🔍 故障排除

### 常见问题

1. **构建失败**: 检查是否安装了所需的构建工具
2. **服务启动失败**: 检查 CUPS 服务是否正常运行
3. **端口冲突**: 修改服务配置文件中的端口设置
4. **权限问题**: 确保 `cloudcups` 用户有正确的权限

### 调试信息

```bash
# 查看服务状态
systemctl status cloudcups

# 查看详细日志
journalctl -u cloudcups --no-pager

# 检查端口占用
sudo netstat -tulpn | grep :3000

# 检查文件权限
ls -la /opt/cloudcups/
```

## 🔄 版本管理

更新版本时需要修改：

1. `packaging/deb/DEBIAN/control` - Version 字段
2. `packaging/rpm/cloudcups.spec` - Version 字段  
3. `backend/package.json` - version 字段

## 📝 自定义配置

### 环境变量

可以在 `/lib/systemd/system/cloudcups.service` 中修改：

```ini
[Service]
Environment=PORT=8080
Environment=NODE_ENV=production
```

### 修改配置后

```bash
sudo systemctl daemon-reload
sudo systemctl restart cloudcups
```

## 🤝 贡献

如果要添加对新 Linux 发行版的支持：

1. 在 `packaging/` 目录下创建相应的构建脚本
2. 更新 `build-packages.sh` 脚本
3. 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证。详见 LICENSE 文件。