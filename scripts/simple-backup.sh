#!/bin/bash

# 超简单的 Chatwoot 数据库备份脚本
# 只需要配置 AWS 凭证，自动备份到 S3

set -e

# 配置区域 (根据需要修改)
S3_BUCKET="tvc-chatwoot-public"
AWS_REGION="us-east-1"

# 数据库配置 (Docker 环境，通常不需要修改)
DB_CONTAINER="chatwoot_postgres_1"  # Docker 容器名称
DB_NAME="chatwoot"
DB_USER="postgres"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查 AWS 凭证
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    log "错误: 请设置 AWS_ACCESS_KEY_ID 和 AWS_SECRET_ACCESS_KEY 环境变量"
    log "示例: export AWS_ACCESS_KEY_ID=your_key"
    log "      export AWS_SECRET_ACCESS_KEY=your_secret"
    exit 1
fi

# 检查 S3 存储桶
if [ "$S3_BUCKET" = "your-backup-bucket" ]; then
    log "错误: 请修改脚本中的 S3_BUCKET 配置"
    exit 1
fi

# 创建备份
log "开始备份数据库..."
timestamp=$(date +%Y%m%d_%H%M%S)
backup_file="/tmp/chatwoot-backup-${timestamp}.sql.gz"

# 通过 Docker 导出数据库并压缩
log "正在连接数据库容器: $DB_CONTAINER"
if ! docker exec "$DB_CONTAINER" \
    pg_dump -U "$DB_USER" -d "$DB_NAME" --no-owner --no-privileges --clean > "/tmp/backup.sql"; then
    log "错误: 数据库导出失败"
    exit 1
fi

# 检查导出文件大小
backup_size=$(wc -c < "/tmp/backup.sql")
log "数据库导出完成，文件大小: $backup_size bytes"

if [ "$backup_size" -lt 1000 ]; then
    log "警告: 备份文件太小，可能有问题"
    log "备份文件内容预览:"
    head -20 "/tmp/backup.sql"
fi

# 压缩文件
gzip < "/tmp/backup.sql" > "$backup_file"
rm -f "/tmp/backup.sql"

log "备份文件创建完成: $backup_file"

# 上传到 S3
log "上传到 S3..."
/root/.local/bin/aws s3 cp "$backup_file" "s3://$S3_BUCKET/chatwoot-backups/" --region "$AWS_REGION"

# 清理本地文件
rm -f "$backup_file"

# 验证 S3 上传是否成功
if /root/.local/bin/aws s3 ls "s3://$S3_BUCKET/chatwoot-backups/$(basename "$backup_file")" --region "$AWS_REGION" >/dev/null 2>&1; then
    log "✅ 备份成功! 文件已上传到 s3://$S3_BUCKET/chatwoot-backups/$(basename "$backup_file")"
    
    # 写入成功日志
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: Backup completed - $(basename "$backup_file")" >> /var/log/chatwoot-backup-status.log
else
    log "❌ 备份失败! S3 上传验证失败"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILED: Backup upload failed - $(basename "$backup_file")" >> /var/log/chatwoot-backup-status.log
    exit 1
fi

# 清理超过30天的旧备份
log "清理旧备份..."
/root/.local/bin/aws s3 ls "s3://$S3_BUCKET/chatwoot-backups/" | \
while read -r line; do
    file_date=$(echo "$line" | awk '{print $1}')
    file_name=$(echo "$line" | awk '{print $4}')
    
    if [[ -n "$file_date" && -n "$file_name" ]]; then
        if [[ "$file_date" < $(date -d '30 days ago' '+%Y-%m-%d') ]]; then
            /root/.local/bin/aws s3 rm "s3://$S3_BUCKET/chatwoot-backups/$file_name" --region "$AWS_REGION"
            log "删除旧备份: $file_name"
        fi
    fi
done

log "备份任务全部完成!"