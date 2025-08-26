# Chatwoot 数据库备份脚本

本目录包含 Chatwoot 数据库自动备份到 AWS S3 的完整解决方案。

## 📂 文件结构

```
scripts/backup/
├── README.md                   # 本说明文件
├── backup-to-s3.sh            # 核心备份脚本
├── setup-backup.sh            # 传统方式安装脚本
├── install-cron.sh            # 传统方式定时任务安装
├── test-backup.sh             # 备份功能测试脚本
├── backup-entrypoint.sh       # Docker 容器入口脚本
├── backup-cron.sh             # Docker 容器 cron 包装器
└── backup-scheduler.sh        # Docker 容器自定义调度器
```

## 🚀 使用方式

### Docker 方式 (推荐)

1. 配置 `.env.production` 中的 AWS S3 设置
2. 运行 `docker-compose -f docker-compose.production.yaml up -d`
3. 备份服务将自动每日 0 点执行备份

### 传统方式

1. 运行 `sudo ./scripts/backup/setup-backup.sh`
2. 配置 AWS 凭证
3. 运行 `sudo ./scripts/backup/install-cron.sh`

## 📋 核心功能

- ✅ PostgreSQL 数据库完整备份
- ✅ 自动压缩和加密传输到 S3
- ✅ 本地和 S3 的旧备份自动清理
- ✅ 详细日志记录和错误处理
- ✅ 支持 Docker 和传统两种部署方式
- ✅ 完整的测试和验证功能

## 🔧 配置说明

### 环境变量

在 `.env.production` 中配置：

```bash
# AWS 凭证
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1

# 备份配置
S3_BACKUP_BUCKET=your-backup-bucket
S3_BACKUP_PREFIX=chatwoot-backups
BACKUP_RETENTION_DAYS=30
LOCAL_CLEANUP_DAYS=7
```

### S3 存储桶权限

确保 AWS 用户具有以下权限：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-backup-bucket",
                "arn:aws:s3:::your-backup-bucket/*"
            ]
        }
    ]
}
```

## 📊 监控和管理

### 查看备份状态

```bash
# Docker 方式
docker-compose -f docker-compose.production.yaml logs -f backup

# 传统方式
tail -f /var/log/chatwoot-backup.log
```

### 手动执行备份

```bash
# Docker 方式
docker-compose -f docker-compose.production.yaml exec backup /app/scripts/backup-to-s3.sh

# 传统方式
sudo /opt/chatwoot-backup/scripts/backup-to-s3.sh
```

### 测试备份功能

```bash
# Docker 方式
docker-compose -f docker-compose.production.yaml exec backup /app/scripts/backup-entrypoint.sh test

# 传统方式
sudo ./scripts/backup/test-backup.sh
```

## 🔄 数据恢复

从 S3 恢复数据库：

```bash
# 1. 下载备份文件
aws s3 cp s3://your-backup-bucket/chatwoot-backups/YYYY/MM/backup.sql.gz /tmp/

# 2. 解压
gunzip /tmp/backup.sql.gz

# 3. 停止应用服务
docker-compose -f docker-compose.production.yaml stop rails sidekiq

# 4. 恢复数据库
docker-compose -f docker-compose.production.yaml exec postgres psql -U postgres -d chatwoot < /tmp/backup.sql

# 5. 重启应用服务
docker-compose -f docker-compose.production.yaml start rails sidekiq
```

## ⚠️ 注意事项

1. 确保 S3 存储桶已创建且具有适当权限
2. 备份过程中会排除 `audits` 和 `active_storage_blobs` 表数据以减小备份大小
3. 本地备份文件会在上传成功后自动删除以节省磁盘空间
4. S3 中的备份按年/月目录结构组织
5. 自动清理策略：本地保留 7 天，S3 保留 30 天

## 🆘 故障排除

### 常见问题

1. **AWS 凭证错误**: 检查 `AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY`
2. **S3 权限不足**: 确保用户具有所需的 S3 操作权限
3. **数据库连接失败**: 检查数据库服务是否正常运行
4. **磁盘空间不足**: 清理 `/tmp/chatwoot-backups` 目录

### 日志位置

- Docker 方式: `docker logs chatwoot_backup_1`
- 传统方式: `/var/log/chatwoot-backup.log`