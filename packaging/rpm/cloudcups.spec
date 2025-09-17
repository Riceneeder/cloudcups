Name:           cloudcups
Version:        1.0.0
Release:        1%{?dist}
Summary:        CloudCups 云打印服务

License:        MIT
URL:            https://github.com/Riceneeder/cloudcups
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       cups cups-client systemd

%description
CloudCups 是一个基于 CUPS 的云打印解决方案，提供 Web 界面来管理和监控打印任务。

主要功能：
- Web 界面管理打印任务
- 实时打印状态监控
- 打印队列管理
- 支持多种打印机类型

%prep
%setup -q

%build
# 项目已经是预编译的

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/cloudcups
mkdir -p $RPM_BUILD_ROOT/opt/cloudcups/logs
mkdir -p $RPM_BUILD_ROOT%{_unitdir}

# 安装主程序
install -m 755 cloudcups $RPM_BUILD_ROOT/opt/cloudcups/
cp -r static $RPM_BUILD_ROOT/opt/cloudcups/

# 安装 systemd 服务文件
install -m 644 cloudcups.service $RPM_BUILD_ROOT%{_unitdir}/

%files
%defattr(-,cloudcups,cloudcups,-)
/opt/cloudcups/cloudcups
/opt/cloudcups/static
%dir /opt/cloudcups/logs
%{_unitdir}/cloudcups.service

%pre
# 创建 cloudcups 用户
if ! id cloudcups &>/dev/null; then
    useradd -r -s /bin/false -d /opt/cloudcups -c "CloudCups service user" cloudcups
fi

%post
# 设置权限
chown -R cloudcups:cloudcups /opt/cloudcups
chmod 755 /opt/cloudcups
chmod +x /opt/cloudcups/cloudcups

# 重新加载 systemd
systemctl daemon-reload

# 启用并启动服务
systemctl enable cloudcups.service
systemctl start cloudcups.service

echo "CloudCups 安装完成！"
echo "服务已启动并设置为开机自启动"
echo "Web 界面: http://localhost:3000"
echo "查看服务状态: systemctl status cloudcups"
echo "查看日志: journalctl -u cloudcups -f"

%preun
if [ $1 -eq 0 ]; then
    # 完全卸载时停止并禁用服务
    systemctl stop cloudcups.service 2>/dev/null || true
    systemctl disable cloudcups.service 2>/dev/null || true
fi

%postun
if [ $1 -eq 0 ]; then
    # 完全卸载时清理用户
    if id cloudcups &>/dev/null; then
        userdel cloudcups 2>/dev/null || true
    fi
    
    # 重新加载 systemd
    systemctl daemon-reload
    
    echo "CloudCups 已完全卸载"
fi

%changelog
* Tue Sep 17 2024 CloudCups Team <support@cloudcups.com> - 1.0.0-1
- 初始发布版本
- 支持 Web 界面管理打印任务
- 支持实时打印状态监控
- 支持打印队列管理