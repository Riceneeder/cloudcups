# CloudCups Linux 发行版安装包

这个目录包含了为不同 Linux 发行版构建 CloudCups 安装包的所有必要文件。

## 支持的发行版

- **DEB 包**: Ubuntu, Debian, Linux Mint 等基于 Debian 的发行版
- **RPM 包**: RHEL, CentOS, Fedora, openSUSE 等基于 RPM 的发行版

## 快速开始

### 一键构建所有包

```bash
./build-packages.sh
```

这个脚本会：
1. 检查系统环境和必要工具
2. 提供交互式菜单选择构建选项
3. 自动构建所需的安装包

### 单独构建特定包

#### 构建 DEB 包 (Ubuntu/Debian)

```bash
./build-deb.sh
```

#### 构建 RPM 包 (RHEL/CentOS/Fedora)

```bash
./build-rpm.sh
```

## 安装要求

### 构建环境要求

- **所有系统**: `bun` (JavaScript 运行时和包管理器)
- **DEB 包构建**: `dpkg-deb` (通常在 Debian/Ubuntu 系统上预装)
- **RPM 包构建**: `rpmbuild` (需要安装 `rpm-build` 包)

### 目标系统要求

安装 CloudCups 的系统需要：
- `cups` (打印系统)
- `cups-client` (CUPS 客户端工具)
- `systemd` (服务管理)

## 安装包内容

### 文件结构

```
/opt/cloudcups/
├── cloudcups          # 主可执行文件
├── static/            # Web 界面静态文件
└── logs/              # 日志目录
```

### 系统服务

- **服务名称**: `cloudcups.service`
- **服务文件位置**: `/lib/systemd/system/cloudcups.service`
- **默认端口**: 3000
- **Web 界面**: http://localhost:3000

## 安装过程

### 自动化安装步骤

安装包会自动执行以下操作：

1. **创建系统用户**: 创建专用的 `cloudcups` 用户来运行服务
2. **安装文件**: 将程序文件复制到 `/opt/cloudcups/`
3. **设置权限**: 正确设置文件和目录权限
4. **安装服务**: 安装 systemd 服务文件
5. **启用服务**: 设置服务开机自启动
6. **启动服务**: 立即启动 CloudCups 服务

### 手动安装方法

#### Ubuntu/Debian 系统

```bash
# 安装 DEB 包
sudo dpkg -i cloudcups_1.0.0_amd64.deb

# 如果有依赖问题，修复依赖
sudo apt-get install -f
```

#### RHEL/CentOS/Fedora 系统

```bash
# 使用 rpm 安装
sudo rpm -ivh cloudcups-1.0.0-1.*.x86_64.rpm

# 或使用 dnf/yum 安装
sudo dnf install cloudcups-1.0.0-1.*.x86_64.rpm
```

## 卸载方法

### Ubuntu/Debian 系统

```bash
# 卸载包但保留配置
sudo dpkg -r cloudcups

# 完全卸载包括配置
sudo dpkg -P cloudcups
```

### RHEL/CentOS/Fedora 系统

```bash
# 卸载包
sudo rpm -e cloudcups
```

## 服务管理

### 基本命令

```bash
# 查看服务状态
systemctl status cloudcups

# 启动服务
sudo systemctl start cloudcups

# 停止服务
sudo systemctl stop cloudcups

# 重启服务
sudo systemctl restart cloudcups

# 查看服务日志
journalctl -u cloudcups -f

# 查看最近的日志
journalctl -u cloudcups --since "1 hour ago"
```

### 开机自启动

```bash
# 启用开机自启动
sudo systemctl enable cloudcups

# 禁用开机自启动
sudo systemctl disable cloudcups
```

## 配置选项

### 环境变量

服务支持以下环境变量（在 `/lib/systemd/system/cloudcups.service` 中配置）：

- `NODE_ENV`: 运行环境 (默认: production)
- `PORT`: 服务端口 (默认: 3000)

### 修改配置

1. 编辑服务文件：
   ```bash
   sudo systemctl edit cloudcups
   ```

2. 添加自定义配置：
   ```ini
   [Service]
   Environment=PORT=8080
   ```

3. 重新加载并重启服务：
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart cloudcups
   ```

## 故障排除

### 常见问题

1. **服务启动失败**
   ```bash
   # 查看详细错误信息
   journalctl -u cloudcups --no-pager
   
   # 检查 CUPS 服务状态
   systemctl status cups
   ```

2. **端口冲突**
   ```bash
   # 检查端口占用
   sudo netstat -tulpn | grep :3000
   
   # 修改服务端口（见上面的配置选项）
   ```

3. **权限问题**
   ```bash
   # 重新设置权限
   sudo chown -R cloudcups:cloudcups /opt/cloudcups
   sudo chmod +x /opt/cloudcups/cloudcups
   ```

### 日志位置

- **系统日志**: `journalctl -u cloudcups`
- **应用日志**: `/opt/cloudcups/logs/`

## 开发信息

### 构建脚本结构

```
packaging/
├── build-packages.sh      # 主构建脚本
├── build-deb.sh          # DEB 包构建脚本
├── build-rpm.sh          # RPM 包构建脚本
├── deb/                  # DEB 包构建目录
│   └── DEBIAN/
│       ├── control       # 包信息
│       ├── postinst      # 安装后脚本
│       ├── prerm         # 卸载前脚本
│       └── postrm        # 卸载后脚本
└── rpm/
    └── cloudcups.spec    # RPM 规格文件
```

### 版本管理

要更新版本号，需要修改以下文件：
- `packaging/deb/DEBIAN/control` (Version 字段)
- `packaging/rpm/cloudcups.spec` (Version 字段)
- `backend/package.json` (version 字段)

## 贡献指南

如果要为新的 Linux 发行版添加支持，请：

1. 在 `packaging/` 目录下创建相应的构建脚本
2. 更新 `build-packages.sh` 脚本添加新选项
3. 更新此 README 文件

## 许可证

本项目采用 MIT 许可证。详见项目根目录的 LICENSE 文件。