# Keycloak Auth Manager

Keycloak Passkey 认证管理 Web 控制台，一键为网站添加 OAuth2 认证保护。

## 功能

- 一键创建 Keycloak Client
- 自动创建 oauth2-proxy 容器
- 自动配置 Nginx 反向代理认证
- 支持多域名管理
- 支持 Passkey (WebAuthn) 无密码认证

## 依赖

- Keycloak 26.x (已配置 Passkey 认证)
- oauth2-proxy v7.6.0
- 1Panel + OpenResty (Nginx)
- Docker
- Python 3.6+ + Flask

## 一键部署

```bash
# 克隆项目
git clone https://gitee.com/singkong/keycloak-auth-manager.git

# 进入目录
cd keycloak-auth-manager

# 一键部署（交互式配置）
bash install.sh
```

部署时会交互式询问：
- Keycloak 服务地址
- Keycloak Admin 用户名/密码
- Web 控制台端口
- Nginx 网站目录

## 部署后

- 访问地址: `http://服务器IP:8088`
- systemd 服务，开机自启
- 日志: `/opt/keycloak-auth-manager/app.log`

## 服务管理

```bash
systemctl status keycloak-auth-manager   # 查看状态
systemctl restart keycloak-auth-manager  # 重启
systemctl stop keycloak-auth-manager     # 停止
journalctl -u keycloak-auth-manager -f   # 日志
```

## 使用方法

1. 先在 1Panel 创建网站（配置反向代理）
2. 访问 Web 控制台
3. 输入域名，点击"添加认证"
4. 自动完成所有配置

## 卸载

```bash
cd keycloak-auth-manager
bash uninstall.sh
```

## 注意事项

- 用户需在 Keycloak 注册 Passkey
- 支持无 email 用户 (USER_ID_CLAIM=preferred_username)
- data.json 包含敏感信息，不提交 Git

## License

MIT
