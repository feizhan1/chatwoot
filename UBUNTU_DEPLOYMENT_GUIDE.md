# Chatwoot Ubuntu 生产环境部署指南

## 📋 准备工作

### 需要传输到 Ubuntu 服务器的文件：
- `docker-compose.production.yaml`
- `.env.production`
- `BRANCH_MANAGEMENT.md` (可选)

### Ubuntu 服务器要求：
- Ubuntu 18.04+ 或 Ubuntu 20.04+ 推荐
- 至少 2GB RAM, 20GB 存储空间
- 网络连接正常

---

## 🔧 第一步：Ubuntu 服务器环境准备

### 1.1 更新系统
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 安装 Docker
```bash
# 安装必要的包
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker 仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER
```

### 1.3 安装 Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 1.4 验证安装
```bash
# 重新登录或运行：
newgrp docker

# 验证 Docker
docker --version
docker-compose --version
```

---

## 📁 第二步：文件传输和项目设置

### 2.1 创建项目目录
```bash
mkdir -p ~/chatwoot-production
cd ~/chatwoot-production
```

### 2.2 传输配置文件

**方法1：使用 scp 命令（从本地传输到服务器）**
```bash
# 在本地 Mac 执行，将文件传输到 Ubuntu 服务器
scp /Users/feizhan/code/zhen_zhi/chatwoot/docker-compose.production.yaml docker39@115.175.225.110:~/chatwoot-production/
scp /Users/feizhan/code/zhen_zhi/chatwoot/.env.production docker39@115.175.225.110:~/chatwoot-production/
```

**方法2：手动创建文件（在 Ubuntu 服务器上）**
```bash
# 创建 docker-compose.production.yaml
nano docker-compose.production.yaml
# 然后复制粘贴内容

# 创建 .env.production
nano .env.production
# 然后复制粘贴内容
```

### 2.3 验证文件
```bash
ls -la ~/chatwoot-production/
# 应该看到:
# docker-compose.production.yaml
# .env.production
```

---

## 🚀 第三步：部署 Chatwoot

### 3.1 启动服务
```bash
cd ~/chatwoot-production

# 拉取最新镜像
docker-compose -f docker-compose.production.yaml pull

# 启动服务（后台运行）
docker-compose -f docker-compose.production.yaml up -d
```

### 3.2 检查服务状态
```bash
# 查看容器状态
docker-compose -f docker-compose.production.yaml ps

# 查看日志
docker-compose -f docker-compose.production.yaml logs -f rails
docker-compose -f docker-compose.production.yaml logs -f sidekiq
docker-compose -f docker-compose.production.yaml logs -f postgres
docker-compose -f docker-compose.production.yaml logs -f redis
```

### 3.3 数据库初始化
```bash
# 创建数据库
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:create

# 运行数据库迁移
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:migrate

# 预编译资产文件
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails assets:precompile
```

---

## 👤 第四步：创建管理员账户

### 4.1 创建超级管理员
```bash
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails c

# 在 Rails 控制台中执行:
account = Account.create!(name: "Tvcmall")
user = User.create!(name: "Admin", email: "1529212832@qq.com", password: "admin123456Zf/", password_confirmation: "admin123456Zf/")
AccountUser.create!(account: account, user: user, role: "administrator")
exit
```

---

## 🔧 第五步：系统配置和优化

### 5.1 防火墙配置
```bash
# 允许 3000 端口
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status
```

### 5.2 创建系统服务（自动启动）
```bash
sudo nano /etc/systemd/system/chatwoot.service
```

添加以下内容：
```ini
[Unit]
Description=Chatwoot
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/docker39/chatwoot-production
ExecStart=/usr/local/bin/docker-compose -f docker-compose.production.yaml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.production.yaml down
TimeoutStartSec=0
User=docker39

[Install]
WantedBy=multi-user.target
```

**注意：将 `docker39` 替换为您的实际用户名**

```bash
# 启用服务
sudo systemctl daemon-reload
sudo systemctl enable chatwoot
sudo systemctl start chatwoot
```

---

## 🌐 第六步：访问和测试

### 6.1 访问应用
打开浏览器访问：`http://115.175.225.110:3000`

### 6.2 管理员登录
- 邮箱：`admin@tvcmall.com`
- 密码：`admin123456`

---

## 📊 第七步：监控和维护

### 7.1 常用运维命令
```bash
# 查看服务状态
docker-compose -f docker-compose.production.yaml ps

# 重启服务
docker-compose -f docker-compose.production.yaml restart

# 停止服务
docker-compose -f docker-compose.production.yaml stop

# 查看日志
docker-compose -f docker-compose.production.yaml logs -f [service_name]

# 进入容器
docker-compose -f docker-compose.production.yaml exec rails bash
docker-compose -f docker-compose.production.yaml exec postgres psql -U postgres -d chatwoot
```

### 7.2 备份数据库
```bash
# 备份
docker-compose -f docker-compose.production.yaml exec postgres pg_dump -U postgres chatwoot > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复
docker-compose -f docker-compose.production.yaml exec -T postgres psql -U postgres chatwoot < backup_file.sql
```

### 7.3 更新 Chatwoot
```bash
cd ~/chatwoot-production

# 拉取最新镜像
docker-compose -f docker-compose.production.yaml pull

# 停止服务
docker-compose -f docker-compose.production.yaml down

# 启动新版本
docker-compose -f docker-compose.production.yaml up -d

# 运行迁移（如果有）
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:migrate
```

---

## ⚠️ 故障排查

### 8.1 常见问题

**问题1：容器无法启动**
```bash
# 检查日志
docker-compose -f docker-compose.production.yaml logs

# 检查磁盘空间
df -h
```

**问题2：数据库连接失败**
```bash
# 检查 PostgreSQL 容器
docker-compose -f docker-compose.production.yaml exec postgres pg_isready -U postgres

# 检查网络连接
docker network ls
```

**问题3：邮件发送失败**
- 检查 `.env.production` 中的 SMTP 配置
- 确认 QQ 邮箱授权码正确
- 查看 Rails 日志中的邮件发送错误

**问题4：无法访问 Web 界面**
```bash
# 检查防火墙
sudo ufw status

# 检查端口监听
netstat -tlnp | grep 3000

# 检查 Rails 服务
docker-compose -f docker-compose.production.yaml logs rails
```

---

## 🔒 安全建议

1. **定期更新**：定期更新 Docker 镜像和系统包
2. **备份数据**：定期备份数据库和上传文件
3. **监控日志**：定期检查应用日志
4. **防火墙**：只开放必要的端口
5. **密码安全**：使用强密码，定期更换
6. **SSL证书**：生产环境建议配置 HTTPS

---

## 📞 支持

如果遇到问题，可以：
1. 查看容器日志定位问题
2. 检查 Chatwoot 官方文档
3. 查看本地 `BRANCH_MANAGEMENT.md` 文件
4. 检查系统资源使用情况

---

**部署完成！** 🎉

您的 Chatwoot 生产环境现在应该在 `http://115.175.225.110:30000` 正常运行了。