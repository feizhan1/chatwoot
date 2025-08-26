#!/bin/bash

# Chatwoot PostgreSQL 数据库备份到 AWS S3 脚本
# 每天 0 点自动执行，用于异地容灾备份

set -e  # 遇到错误立即退出

# 配置变量 (从环境变量读取，如果未设置则使用默认值)
DB_HOST=${DB_HOST:-"127.0.0.1"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"chatwoot"}
DB_USER=${DB_USER:-"postgres"}
DB_PASSWORD=${DB_PASSWORD:-"421124"}

# AWS S3 配置 (必须在环境变量中设置)
S3_BUCKET=${S3_BUCKET}
S3_PREFIX=${S3_PREFIX:-"chatwoot-backups"}
AWS_REGION=${AWS_REGION:-"us-east-1"}

# 备份目录
BACKUP_DIR="/tmp/chatwoot-backups"
LOG_FILE="/var/log/chatwoot-backup.log"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查必需的环境变量
check_env() {
    if [ -z "$S3_BUCKET" ]; then
        log "ERROR: S3_BUCKET 环境变量未设置"
        exit 1
    fi
    
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        log "ERROR: AWS 凭证未设置 (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
        exit 1
    fi
}

# 检查依赖工具
check_dependencies() {
    if ! command -v pg_dump &> /dev/null; then
        log "ERROR: pg_dump 未安装"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log "ERROR: AWS CLI 未安装"
        exit 1
    fi
}

# 清理旧的本地备份文件 (保留最近7天)
cleanup_old_backups() {
    log "清理超过7天的本地备份文件..."
    find "$BACKUP_DIR" -name "chatwoot-backup-*.sql.gz" -mtime +7 -delete
    log "本地旧备份清理完成"
}

# 创建数据库备份
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_filename="chatwoot-backup-${timestamp}.sql"
    local backup_path="$BACKUP_DIR/$backup_filename"
    local compressed_path="${backup_path}.gz"
    
    log "开始备份数据库: $DB_NAME"
    
    # 设置 PostgreSQL 密码环境变量
    export PGPASSWORD="$DB_PASSWORD"
    
    # 创建数据库备份
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --verbose --no-owner --no-privileges --clean --if-exists \
        --exclude-table-data="audits" \
        --exclude-table-data="active_storage_blobs" \
        > "$backup_path" 2>>"$LOG_FILE"; then
        
        log "数据库备份创建成功: $backup_filename"
    else
        log "ERROR: 数据库备份失败"
        exit 1
    fi
    
    # 压缩备份文件
    log "压缩备份文件..."
    if gzip "$backup_path"; then
        log "备份文件压缩完成: ${backup_filename}.gz"
        echo "$compressed_path"
    else
        log "ERROR: 备份文件压缩失败"
        exit 1
    fi
}

# 上传到 S3
upload_to_s3() {
    local backup_file="$1"
    local filename=$(basename "$backup_file")
    local s3_key="$S3_PREFIX/$(date +%Y/%m)/$filename"
    
    log "开始上传备份到 S3: s3://$S3_BUCKET/$s3_key"
    
    if aws s3 cp "$backup_file" "s3://$S3_BUCKET/$s3_key" \
        --region "$AWS_REGION" \
        --storage-class STANDARD_IA \
        --metadata "backup-date=$(date -Iseconds),db-name=$DB_NAME" \
        2>>"$LOG_FILE"; then
        
        log "S3 上传成功: s3://$S3_BUCKET/$s3_key"
        
        # 删除本地备份文件（节省磁盘空间）
        rm -f "$backup_file"
        log "本地备份文件已删除: $filename"
    else
        log "ERROR: S3 上传失败"
        exit 1
    fi
}

# 清理 S3 旧备份 (保留最近30天)
cleanup_s3_backups() {
    log "清理 S3 超过30天的备份..."
    
    # 计算30天前的日期
    cutoff_date=$(date -d '30 days ago' '+%Y-%m-%d')
    
    # 列出并删除超过30天的备份
    aws s3 ls "s3://$S3_BUCKET/$S3_PREFIX/" --recursive --region "$AWS_REGION" | \
    while read -r line; do
        # 提取文件日期和路径
        file_date=$(echo "$line" | awk '{print $1}')
        file_path=$(echo "$line" | awk '{print $4}')
        
        # 比较日期并删除旧文件
        if [[ "$file_date" < "$cutoff_date" ]]; then
            aws s3 rm "s3://$S3_BUCKET/$file_path" --region "$AWS_REGION"
            log "已删除旧的 S3 备份: $file_path"
        fi
    done
    
    log "S3 旧备份清理完成"
}

# 发送备份状态通知 (可选)
send_notification() {
    local status="$1"
    local message="$2"
    
    # 可以在这里添加邮件、Slack、钉钉等通知
    # 示例：发送到系统日志
    logger "Chatwoot备份: $status - $message"
}

# 主函数
main() {
    log "=== 开始 Chatwoot 数据库备份任务 ==="
    
    # 检查环境和依赖
    check_env
    check_dependencies
    
    # 清理旧的本地备份
    cleanup_old_backups
    
    # 创建备份
    backup_file=$(create_backup)
    
    # 上传到 S3
    upload_to_s3 "$backup_file"
    
    # 清理 S3 旧备份
    cleanup_s3_backups
    
    log "=== 备份任务完成 ==="
    send_notification "SUCCESS" "数据库备份成功完成"
}

# 错误处理
trap 'log "ERROR: 备份过程中发生错误，退出状态: $?"; send_notification "FAILED" "数据库备份失败"; exit 1' ERR

# 执行主函数
main "$@"