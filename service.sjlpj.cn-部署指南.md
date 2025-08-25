# service.sjlpj.cn Chatwoot 域名部署指南

## 📋 部署概况

- **当前访问**: http://115.175.225.110:30000
- **目标域名**: https://service.sjlpj.cn
- **部署方式**: Docker + Nginx 反向代理 + SSL

## 🚀 快速部署（推荐）

### 方法一：自动化脚本部署

```bash
# 1. 在服务器 115.175.225.110 上执行
sudo ./scripts/deploy-domain.sh service.sjlpj.cn admin@service.sjlpj.cn

# 脚本会自动完成所有配置
```

### 方法二：手动步骤部署

## 📋 手动部署步骤

### 步骤 1: 配置域名解析

在您的域名服务商处添加 DNS A 记录：

```
类型: A
主机记录: service
域名: service.sjlpj.cn
记录值: 115.175.225.110
TTL: 600
```

**验证解析是否生效**：
```bash
dig service.sjlpj.cn
# 应该返回 115.175.225.110
```

### 步骤 2: 停止当前服务

```bash
# 在服务器上进入项目目录
cd /path/to/chatwoot

# 停止当前的 IP 访问服务
docker-compose -f docker-compose.production.yaml down
```

### 步骤 3: 安装 SSL 证书工具

```bash
# 安装 certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### 步骤 4: 启动域名服务

```bash
# 使用专用的域名配置启动服务
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn up -d

# 等待服务启动
sleep 30
```

### 步骤 5: 申请 SSL 证书

```bash
# 申请 Let's Encrypt 免费 SSL 证书
sudo certbot --nginx \
    --non-interactive \
    --agree-tos \
    --email admin@service.sjlpj.cn \
    --domains service.sjlpj.cn \
    --redirect
```

### 步骤 6: 配置证书文件

```bash
# 创建证书目录并复制证书
sudo mkdir -p docker/letsencrypt
sudo cp -r /etc/letsencrypt/* docker/letsencrypt/

# 更新证书文件权限
sudo chown -R $(whoami):$(whoami) docker/letsencrypt
```

### 步骤 7: 更新 nginx 配置

```bash
# nginx 配置文件已更新为 service.sjlpj.cn
# 启用 SSL 配置行
sed -i 's/# ssl_certificate/ssl_certificate/g' docker/nginx.conf
```

### 步骤 8: 重启服务

```bash
# 重启所有服务以应用新配置
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn restart

# 检查服务状态
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn ps
```

### 步骤 9: 设置自动续期

```bash
# 添加证书自动续期任务
echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f $(pwd)/docker-compose.domain.yaml restart nginx" | sudo crontab -
```

## ✅ 验证部署

### 检查网站访问

```bash
# 检查 HTTPS 访问
curl -I https://service.sjlpj.cn

# 检查 HTTP 重定向
curl -I http://service.sjlpj.cn
```

**期望结果**:
- HTTPS 返回 200 状态码
- HTTP 自动重定向到 HTTPS (301/302)

### 检查服务状态

```bash
# 查看所有容器状态
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn ps

# 查看服务日志
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn logs -f nginx
```

## 🗂️ 配置文件说明

### 主要配置文件

1. **`.env.service.sjlpj.cn`** - 域名专用环境配置
   - `FRONTEND_URL=https://service.sjlpj.cn`
   - `HELPCENTER_URL=https://service.sjlpj.cn`
   - `FORCE_SSL=true`

2. **`docker-compose.domain.yaml`** - 包含 nginx 的容器编排
   - nginx 容器处理 SSL 和反向代理
   - rails 容器只监听本地端口

3. **`docker/nginx.conf`** - nginx 反向代理配置
   - 已配置 service.sjlpj.cn 域名
   - SSL 配置和安全headers

## 🔧 服务管理命令

### 常用操作

```bash
# 查看服务状态
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn ps

# 查看日志
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn logs -f

# 重启服务
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn restart

# 停止服务
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn down

# 更新镜像并重启
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn pull
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn up -d
```

### 特定服务操作

```bash
# 重启 nginx
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn restart nginx

# 查看 nginx 日志
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn logs -f nginx

# 重启 chatwoot 应用
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn restart rails
```

## 🔒 SSL 证书管理

### 查看证书状态

```bash
# 查看证书信息
sudo certbot certificates

# 测试证书续期
sudo certbot renew --dry-run
```

### 手动续期

```bash
# 手动续期证书
sudo certbot renew

# 重启 nginx 应用新证书
docker-compose -f docker-compose.domain.yaml restart nginx
```

## 🚨 故障排除

### 常见问题

#### 1. 域名无法访问

```bash
# 检查域名解析
dig service.sjlpj.cn

# 检查防火墙
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

#### 2. SSL 证书问题

```bash
# 检查证书状态
sudo certbot certificates

# 重新申请证书
sudo certbot delete --cert-name service.sjlpj.cn
sudo certbot --nginx -d service.sjlpj.cn
```

#### 3. 服务启动失败

```bash
# 查看详细错误日志
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn logs

# 检查配置文件语法
nginx -t -c docker/nginx.conf

# 检查环境变量
cat .env.service.sjlpj.cn
```

## 🔄 回滚到 IP 访问

如需回滚到原始的 IP 访问：

```bash
# 停止域名服务
docker-compose -f docker-compose.domain.yaml --env-file .env.service.sjlpj.cn down

# 启动原始 IP 服务
docker-compose -f docker-compose.production.yaml up -d

# 现在可以通过 http://115.175.225.110:30000 访问
```

## 🎯 部署完成检查清单

- [ ] 域名解析已配置并生效
- [ ] SSL 证书申请成功
- [ ] https://service.sjlpj.cn 可以正常访问
- [ ] HTTP 自动重定向到 HTTPS
- [ ] 所有服务容器运行正常
- [ ] SSL 证书自动续期已设置
- [ ] 防火墙规则已配置 (80, 443 端口开放)

## 🌟 部署后效果

✅ **访问地址**: https://service.sjlpj.cn
✅ **自动 HTTPS**: HTTP 自动跳转到 HTTPS
✅ **SSL 安全**: Let's Encrypt 免费证书
✅ **自动续期**: 证书自动续期，无需手动维护
✅ **性能优化**: nginx 反向代理，静态文件缓存

---

部署完成后，您的 Chatwoot 系统将通过 `https://service.sjlpj.cn` 提供安全、稳定的服务！