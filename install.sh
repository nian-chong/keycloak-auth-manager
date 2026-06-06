#!/bin/bash
# Keycloak Auth Manager 一键部署脚本（交互式配置）
# 用法: bash install.sh

set -e

INSTALL_DIR="/opt/keycloak-auth-manager"
SERVICE_NAME="keycloak-auth-manager"

echo ""
echo "=========================================="
echo "  Keycloak Auth Manager 一键部署"
echo "=========================================="
echo ""

# 交互式配置
echo "请输入配置信息（直接回车使用默认值）:"
echo ""

# Keycloak URL
read -p "Keycloak 服务地址 [https://au.abab.pw]: " KEYCLOAK_URL
KEYCLOAK_URL=${KEYCLOAK_URL:-https://au.abab.pw}

# Keycloak Admin 用户名
read -p "Keycloak Admin 用户名 [admin]: " KEYCLOAK_ADMIN
KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN:-admin}

# Keycloak Admin 密码
read -p "Keycloak Admin 密码 [keycloak2026]: " KEYCLOAK_PASSWORD
KEYCLOAK_PASSWORD=${KEYCLOAK_PASSWORD:-keycloak2026}

# Web 控制台端口
read -p "Web 控制台端口 [8088]: " WEB_PORT
WEB_PORT=${WEB_PORT:-8088}

# Nginx 网站目录
read -p "1Panel/OpenResty 网站目录 [/opt/1panel/apps/openresty/openresty/www/sites]: " NGINX_SITES_DIR
NGINX_SITES_DIR=${NGINX_SITES_DIR:-/opt/1panel/apps/openresty/openresty/www/sites}

# Keycloak 容器名称
read -p "Keycloak 容器名称 [keycloak]: " KEYCLOAK_CONTAINER
KEYCLOAK_CONTAINER=${KEYCLOAK_CONTAINER:-keycloak}

echo ""
echo "配置信息确认:"
echo "  Keycloak URL: $KEYCLOAK_URL"
echo "  Keycloak Admin: $KEYCLOAK_ADMIN"
echo "  Keycloak 容器: $KEYCLOAK_CONTAINER"
echo "  Web 端口: $WEB_PORT"
echo "  Nginx 目录: $NGINX_SITES_DIR"
echo ""

read -p "确认部署? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "取消部署"
    exit 0
fi

echo ""
echo "=== 开始部署 ==="

# 检查是否在项目目录
if [ ! -f "app.py" ]; then
    echo "错误: 请在项目目录运行此脚本"
    exit 1
fi

# 安装依赖
echo "安装 Python 依赖..."
pip3 install flask -q 2>/dev/null || pip install flask -q

# 创建安装目录
echo "创建安装目录: $INSTALL_DIR"
mkdir -p $INSTALL_DIR

# 复制文件
echo "复制项目文件..."
cp app.py $INSTALL_DIR/
cp -r static $INSTALL_DIR/
cp -r templates $INSTALL_DIR/
cp -r nginx-auth $INSTALL_DIR/

# 创建配置文件
echo "创建配置文件..."
cat > $INSTALL_DIR/config.json << CONFIG
{
    "keycloak_url": "$KEYCLOAK_URL",
    "keycloak_admin": "$KEYCLOAK_ADMIN",
    "keycloak_password": "$KEYCLOAK_PASSWORD",
    "keycloak_container": "$KEYCLOAK_CONTAINER",
    "web_port": $WEB_PORT,
    "nginx_sites_dir": "$NGINX_SITES_DIR"
}
CONFIG

# 创建空数据文件
echo '{}' > $INSTALL_DIR/data.json

# 修改 app.py 使用配置文件
echo "更新 app.py 配置..."
sed -i "s|http://localhost:8080|http://localhost:8080|g" $INSTALL_DIR/app.py

# 创建 systemd 服务
echo "创建 systemd 服务..."
cat > /etc/systemd/system/$SERVICE_NAME.service << SERVICE
[Unit]
Description=Keycloak Auth Manager Web Console
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/app.py
Restart=always
RestartSec=5
StandardOutput=append:$INSTALL_DIR/app.log
StandardError=append:$INSTALL_DIR/app.log

[Install]
WantedBy=multi-user.target
SERVICE

# 启动服务
echo "启动服务..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# 等待服务启动
sleep 3

# 检查状态
echo ""
echo "=== 服务状态 ==="
systemctl status $SERVICE_NAME --no-pager || true

echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "访问地址: http://服务器IP:$WEB_PORT"
echo "日志文件: $INSTALL_DIR/app.log"
echo "配置文件: $INSTALL_DIR/config.json"
echo "数据文件: $INSTALL_DIR/data.json"
echo ""
echo "管理命令:"
echo "  systemctl status $SERVICE_NAME"
echo "  systemctl restart $SERVICE_NAME"
echo "  systemctl stop $SERVICE_NAME"
echo ""
