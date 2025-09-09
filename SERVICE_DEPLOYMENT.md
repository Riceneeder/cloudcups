# CloudCups 系统服务部署指南

本指南介绍如何将 CloudCups 应用程序部署为 Linux 系统服务 (systemd)。

## 快速安装

### 自动安装 (推荐)

1. **运行安装脚本**:
   ```bash
   sudo ./install-service.sh
   ```
   
   这将自动完成以下操作：
   - 构建程序
   - 创建安装目录 `/opt/cloudcups`
   - 复制程序文件
   - 安装 systemd 服务
   - 设置正确的权限

2. **验证安装**:
   ```bash
   sudo systemctl status cloudcups
   ```

### 手动安装

如果您希望手动安装，请按照以下步骤：

1. **构建程序**:
   ```bash
   ./build.sh
   ```

2. **创建安装目录**:
   ```bash
   sudo mkdir -p /opt/cloudcups/logs
   ```

3. **复制程序文件**:
   ```bash
   sudo cp cloudcups /opt/cloudcups/
   sudo cp -r dist/static /opt/cloudcups/
   ```

4. **设置权限**:
   ```bash
   sudo chmod +x /opt/cloudcups/cloudcups
   sudo chown -R root:root /opt/cloudcups
   ```

5. **安装服务文件**:
   ```bash
   sudo cp cloudcups.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

6. **启用并启动服务**:
   ```bash
   sudo systemctl enable cloudcups
   sudo systemctl start cloudcups
   ```

## 服务管理

### 基本命令

- **启动服务**: `sudo systemctl start cloudcups`
- **停止服务**: `sudo systemctl stop cloudcups`
- **重启服务**: `sudo systemctl restart cloudcups`
- **查看状态**: `sudo systemctl status cloudcups`
- **启用开机自启**: `sudo systemctl enable cloudcups`
- **禁用开机自启**: `sudo systemctl disable cloudcups`

### 日志查看

- **查看实时日志**: `sudo journalctl -u cloudcups -f`
- **查看最近日志**: `sudo journalctl -u cloudcups -n 50`
- **查看错误日志**: `sudo journalctl -u cloudcups -p err`

## 配置说明

### 服务配置文件

服务配置文件位于 `/etc/systemd/system/cloudcups.service`，主要配置项：

- **用户和组**: 运行在 `root` 用户和 `root` 组下
- **工作目录**: `/opt/cloudcups`
- **端口**: 默认 3000 (可通过环境变量修改)
- **日志**: 输出到 systemd journal

### 环境变量

可以在服务文件中修改以下环境变量：

```ini
Environment=NODE_ENV=production
Environment=PORT=3000
```

### 安全设置

服务配置了以下安全限制：

- `NoNewPrivileges=true`: 禁止获取新权限
- `ProtectSystem=strict`: 保护系统目录
- `ProtectHome=true`: 保护用户主目录
- `ReadWritePaths=/opt/cloudcups/logs`: 仅允许写入日志目录

## 故障排除

### 常见问题

1. **服务启动失败**:
   ```bash
   sudo journalctl -u cloudcups -n 20
   ```
   检查错误日志获取详细信息。

2. **权限问题**:
   root 用户运行，一般不会有权限问题。如果需要访问特定 CUPS 功能，可以检查：
   ```bash
   systemctl status cups
   ```

3. **端口占用**:
   检查端口是否被占用：
   ```bash
   sudo netstat -tlnp | grep :3000
   ```

4. **文件权限错误**:
   重新设置权限：
   ```bash
   sudo chown -R root:root /opt/cloudcups
   sudo chmod +x /opt/cloudcups/cloudcups
   ```

### 服务状态检查

```bash
# 检查服务状态
sudo systemctl status cloudcups

# 检查服务是否在监听端口
sudo ss -tlnp | grep :3000

# 检查进程
ps aux | grep cloudcups
```

## 卸载服务

运行卸载脚本：
```bash
sudo ./uninstall-service.sh
```

或手动卸载：

1. **停止并禁用服务**:
   ```bash
   sudo systemctl stop cloudcups
   sudo systemctl disable cloudcups
   ```

2. **删除服务文件**:
   ```bash
   sudo rm /etc/systemd/system/cloudcups.service
   sudo systemctl daemon-reload
   ```

3. **删除程序文件** (可选):
   ```bash
   sudo rm -rf /opt/cloudcups
   ```

## 网络访问

服务启动后，可以通过以下地址访问：

- 本地访问: `http://localhost:3000`
- 网络访问: `http://服务器IP:3000`

确保防火墙允许 3000 端口的访问：
```bash
sudo ufw allow 3000
```

## 系统要求

- Linux 操作系统 (支持 systemd)
- CUPS 打印系统已安装
- Bun 运行时 (用于构建)
- 管理员权限 (用于安装服务)

## 注意事项

1. 服务运行在 `root` 用户下，具有完整的系统权限
2. 日志文件会写入 `/opt/cloudcups/logs` 目录
3. 静态文件位于 `/opt/cloudcups/static` 目录
4. 服务配置了自动重启，在异常退出时会自动重新启动
