# Chatwoot 域名配置指南

本指南将帮助您将 Chatwoot 从 IP 访问配置为域名访问，并自动配置 SSL 证书。

## 前提条件

1. 您已有一个域名
2. 服务器已部署 Chatwoot 并可通过 IP 访问
3. 服务器有 root 权限

## 快速配置（推荐）

### 自动化脚本部署

1. **配置域名解析**
   在您的域名服务商处添加 A 记录：
   ```
   类型: A
   主机记录: @
   记录值: 115.175.225.110
   TTL: 600
   ```

2. **运行自动部署脚本**
   ```bash
   # 在服务器上进入项目目录
   cd /path/to/chatwoot
   
   # 运行域名配置脚本（替换为您的实际域名）
   sudo ./scripts/deploy-domain.sh yourdomain.com admin@yourdomain.com
   ```

3. **等待完成**
   脚本会自动完成以下操作：
   - 安装 certbot
   - 配置 nginx 反向代理
   - 申请 SSL 证书
   - 更新环境配置
   - 重启服务

## 手动配置步骤

如果您希望手动配置，请按以下步骤操作：

### 步骤 1: 域名解析
在域名服务商处设置 A 记录指向服务器 IP `115.175.225.110`

### 步骤 2: 复制并修改环境配置
```bash
# 复制域名环境配置模板
cp .env.domain.example .env.domain

# 编辑配置文件，将 yourdomain.com 替换为您的域名
sed -i 's/yourdomain\.com/您的域名.com/g' .env.domain
```

### 步骤 3: 更新 nginx 配置
```bash
# 更新 nginx 配置中的域名
sed -i 's/yourdomain\.com/您的域名.com/g' docker/nginx.conf
```

### 步骤 4: 使用新的 docker-compose 配置
```bash
# 停止当前服务
docker-compose -f docker-compose.production.yaml down

# 使用域名配置启动服务
docker-compose -f docker-compose.domain.yaml --env-file .env.domain up -d
```

### 步骤 5: 配置 SSL 证书
```bash
# 安装 certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# 申请 SSL 证书
sudo certbot --nginx --domains 您的域名.com,www.您的域名.com
```

## 配置文件说明

### 主要配置文件

1. **`.env.domain`** - 域名环境变量配置
   - `FRONTEND_URL=https://yourdomain.com`
   - `HELPCENTER_URL=https://yourdomain.com`
   - `FORCE_SSL=true`

2. **`docker-compose.domain.yaml`** - 包含 nginx 的 Docker Compose 配置

3. **`docker/nginx.conf`** - nginx 反向代理配置

### 端口配置变化

- **原配置**: Chatwoot 直接暴露在 30000 端口
- **新配置**: nginx 处理 80/443 端口，反向代理到内部 30000 端口

## 服务管理命令

### 查看服务状态
```bash
docker-compose -f docker-compose.domain.yaml --env-file .env.domain ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs -f

# 查看特定服务日志
docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs -f nginx
docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs -f rails
```

### 重启服务
```bash
# 重启所有服务
docker-compose -f docker-compose.domain.yaml --env-file .env.domain restart

# 重启特定服务
docker-compose -f docker-compose.domain.yaml --env-file .env.domain restart nginx
```

### 停止服务
```bash
docker-compose -f docker-compose.domain.yaml --env-file .env.domain down
```

## SSL 证书管理

### 自动续期
自动部署脚本已配置 SSL 证书自动续期：
```bash
# 查看当前 crontab
crontab -l

# 手动测试续期
sudo certbot renew --dry-run
```

### 手动续期
```bash
sudo certbot renew
docker-compose -f docker-compose.domain.yaml restart nginx
```

## 故障排除

### 1. 域名无法访问
检查：
- 域名解析是否生效：`dig yourdomain.com`
- nginx 配置是否正确
- 防火墙是否开放 80/443 端口

### 2. SSL 证书申请失败
检查：
- 域名解析是否指向正确 IP
- 80 端口是否被其他服务占用
- 域名是否可以公网访问

### 3. 服务启动失败
```bash
# 查看详细错误日志
docker-compose -f docker-compose.domain.yaml --env-file .env.domain logs

# 检查配置文件语法
nginx -t -c docker/nginx.conf
```

## 回滚到 IP 访问

如果需要回滚到原来的 IP 访问方式：
```bash
# 停止域名配置的服务
docker-compose -f docker-compose.domain.yaml --env-file .env.domain down

# 启动原始配置
docker-compose -f docker-compose.production.yaml up -d
```

## 安全建议

1. **定期更新证书**: 已自动配置，无需手动操作
2. **配置防火墙**: 只开放必要端口 (80, 443, 22)
3. **备份配置**: 定期备份环境配置文件
4. **监控日志**: 定期查看 nginx 和应用日志

## 联系支持

如果在配置过程中遇到问题，请：
1. 查看详细错误日志
2. 检查域名解析状态
3. 确认服务器网络连接正常

---

配置完成后，您就可以通过 `https://yourdomain.com` 访问 Chatwoot 了！