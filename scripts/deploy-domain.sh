#!/bin/bash

# Chatwoot 域名部署脚本
# 用法: ./deploy-domain.sh yourdomain.com your-email@example.com

set -e

DOMAIN=${1}
EMAIL=${2:-"admin@${DOMAIN}"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ -z "$1" ]; then
    print_error "请提供域名参数"
    echo "使用方法: $0 <域名> [邮箱]"
    echo "示例: $0 yourdomain.com admin@yourdomain.com"
    exit 1
fi

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    print_error "请以 root 用户运行此脚本"
    exit 1
fi

print_info "开始为域名 ${DOMAIN} 配置 Chatwoot..."
print_info "管理员邮箱: ${EMAIL}"

# 步骤 1: 检查域名解析
print_info "步骤 1: 检查域名解析..."
SERVER_IP=$(curl -s http://ipinfo.io/ip)
DOMAIN_IP=$(dig +short ${DOMAIN})

if [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
    print_warning "域名 ${DOMAIN} 解析的 IP (${DOMAIN_IP}) 与服务器 IP (${SERVER_IP}) 不匹配"
    print_warning "请先在域名服务商处设置 A 记录: ${DOMAIN} -> ${SERVER_IP}"
    read -p "域名解析配置完成后，按 Enter 继续..."
fi

# 步骤 2: 安装必要软件
print_info "步骤 2: 安装必要软件..."
apt update
apt install -y certbot python3-certbot-nginx

# 步骤 3: 停止当前服务
print_info "步骤 3: 停止当前服务..."
cd "$PROJECT_DIR"
docker-compose -f docker-compose.production.yaml down

# 步骤 4: 更新 nginx 配置
print_info "步骤 4: 更新 nginx 配置..."
sed -i "s/yourdomain\.com/${DOMAIN}/g" docker/nginx.conf

# 步骤 5: 创建域名环境配置
print_info "步骤 5: 创建域名环境配置..."
if [ ! -f .env.domain ]; then
    cp .env.domain.example .env.domain
    sed -i "s/yourdomain\.com/${DOMAIN}/g" .env.domain
    print_info "已创建 .env.domain 文件，请根据需要修改配置"
else
    print_warning ".env.domain 文件已存在，跳过创建"
fi

# 步骤 6: 启动服务（临时 HTTP 模式）
print_info "步骤 6: 启动服务进行 SSL 证书申请..."
# 临时启用 HTTP 模式的 nginx 配置
cp docker/nginx.conf docker/nginx.conf.backup
sed -i '/listen 443/,/^}/d' docker/nginx.conf
sed -i 's/return 301/#return 301/g' docker/nginx.conf

# 使用域名环境配置启动服务
docker-compose -f docker-compose.domain.yaml --env-file .env.domain up -d

# 等待服务启动
print_info "等待服务启动..."
sleep 30

# 步骤 7: 申请 SSL 证书
print_info "步骤 7: 申请 SSL 证书..."
certbot --nginx \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} \
    --domains ${DOMAIN},www.${DOMAIN} \
    --redirect

# 步骤 8: 复制证书并更新配置
print_info "步骤 8: 配置 SSL..."
mkdir -p docker/letsencrypt
cp -r /etc/letsencrypt/* docker/letsencrypt/

# 恢复完整的 nginx 配置
cp docker/nginx.conf.backup docker/nginx.conf
sed -i "s/yourdomain\.com/${DOMAIN}/g" docker/nginx.conf
sed -i 's/# ssl_certificate/ssl_certificate/g' docker/nginx.conf

# 步骤 9: 重启服务
print_info "步骤 9: 重启服务..."
docker-compose -f docker-compose.domain.yaml --env-file .env.domain down
docker-compose -f docker-compose.domain.yaml --env-file .env.domain up -d

# 步骤 10: 设置自动续期
print_info "步骤 10: 设置证书自动续期..."
CRON_CMD="0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f ${PROJECT_DIR}/docker-compose.domain.yaml restart nginx"
(crontab -l 2>/dev/null | grep -v "certbot renew"; echo "${CRON_CMD}") | crontab -

# 步骤 11: 验证部署
print_info "步骤 11: 验证部署..."
sleep 30

if curl -s -o /dev/null -w "%{http_code}" https://${DOMAIN} | grep -q "200\|301\|302"; then
    print_info "✅ 部署成功!"
    echo ""
    echo "🎉 Chatwoot 现在可以通过以下地址访问:"
    echo "   https://${DOMAIN}"
    echo "   https://www.${DOMAIN}"
    echo ""
    echo "📋 配置文件:"
    echo "   - 环境配置: .env.domain"
    echo "   - Docker Compose: docker-compose.domain.yaml"
    echo "   - Nginx 配置: docker/nginx.conf"
    echo ""
    echo "🔧 管理命令:"
    echo "   - 查看日志: docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs -f"
    echo "   - 重启服务: docker-compose -f docker-compose.domain.yaml --env-file .env.domain restart"
    echo "   - 停止服务: docker-compose -f docker-compose.domain.yaml --env-file .env.domain down"
    echo ""
    echo "🔒 SSL 证书自动续期已设置完成"
else
    print_error "❌ 部署失败，请检查配置"
    print_info "查看详细日志: docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs"
fi

print_info "域名配置完成!"