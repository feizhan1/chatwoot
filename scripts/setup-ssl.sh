#!/bin/bash

# SSL 证书配置脚本
# 使用方法: ./setup-ssl.sh yourdomain.com

set -e

DOMAIN=${1:-"yourdomain.com"}
EMAIL="admin@${DOMAIN}"  # 证书管理员邮箱

echo "开始为域名 ${DOMAIN} 配置 SSL 证书..."

# 检查域名参数
if [ -z "$1" ]; then
    echo "错误: 请提供域名参数"
    echo "使用方法: $0 <域名>"
    echo "示例: $0 yourdomain.com"
    exit 1
fi

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行此脚本"
    exit 1
fi

# 安装必要软件
echo "安装 certbot..."
apt update
apt install -y certbot python3-certbot-nginx

# 创建证书存储目录
mkdir -p docker/letsencrypt

# 临时启动 nginx 用于证书验证
echo "启动临时 nginx 服务..."
docker-compose -f docker-compose.domain.yaml up -d nginx

# 等待 nginx 启动
sleep 10

# 申请 SSL 证书
echo "申请 SSL 证书..."
certbot --nginx \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} \
    --domains ${DOMAIN},www.${DOMAIN} \
    --redirect

# 复制证书到 docker 目录
echo "复制证书文件..."
cp -r /etc/letsencrypt/* docker/letsencrypt/

# 更新 nginx 配置文件中的域名
echo "更新 nginx 配置..."
sed -i "s/yourdomain\.com/${DOMAIN}/g" docker/nginx.conf

# 取消注释 SSL 配置行
sed -i 's/# ssl_certificate/ssl_certificate/g' docker/nginx.conf

# 重启服务
echo "重启服务..."
docker-compose -f docker-compose.domain.yaml down
docker-compose -f docker-compose.domain.yaml up -d

# 设置自动续期
echo "设置证书自动续期..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f $(pwd)/docker-compose.domain.yaml restart nginx") | crontab -

echo "SSL 证书配置完成!"
echo "现在可以通过 https://${DOMAIN} 访问 Chatwoot"
echo ""
echo "下一步:"
echo "1. 更新 .env.production 文件中的域名配置"
echo "2. 重启所有服务"