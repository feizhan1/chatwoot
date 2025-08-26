#!/bin/bash

# Chatwoot 备份服务入口脚本

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BACKUP-SERVICE] $1"
}

# 等待数据库服务启动
wait_for_database() {
    log "等待数据库服务启动..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if pg_isready -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${DB_USER:-postgres}" >/dev/null 2>&1; then
            log "数据库服务已就绪"
            break
        fi
        
        log "尝试 $attempt/$max_attempts: 等待数据库服务..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log "ERROR: 数据库服务启动超时"
        exit 1
    fi
}

# 验证环境变量
validate_environment() {
    log "验证环境变量..."
    
    local required_vars=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "S3_BUCKET")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        log "ERROR: 以下必需的环境变量未设置: ${missing_vars[*]}"
        log "请在 .env.backup 中设置这些变量"
        exit 1
    fi
    
    log "环境变量验证通过"
}

# 设置 cron 任务
setup_cron() {
    log "设置定时备份任务..."
    
    # 创建 crontab 文件
    cat > /tmp/backup-crontab << EOF
# Chatwoot 数据库自动备份 (每天凌晨 0 点)
0 0 * * * /app/scripts/backup-cron.sh >> /app/logs/backup.log 2>&1

# 每小时检查一次备份服务健康状态
0 * * * * echo "\$(date): Backup service is running" >> /app/logs/health.log

EOF

    # 安装 crontab (以 root 身份)
    if [ "$(id -u)" -eq 0 ]; then
        crontab /tmp/backup-crontab
        log "Crontab 安装完成 (root 用户)"
    else
        # 非 root 用户，创建自定义的调度器
        log "非 root 用户，使用自定义调度器"
    fi
    
    # 清理临时文件
    rm -f /tmp/backup-crontab
}

# 启动 cron 守护进程
start_cron() {
    log "启动备份调度服务..."
    
    if [ "$(id -u)" -eq 0 ]; then
        # 以 root 身份启动 crond
        exec crond -f -d 8
    else
        # 非 root 用户，使用自定义的调度循环
        exec /app/scripts/backup-scheduler.sh
    fi
}

# 执行一次性备份
run_backup() {
    log "执行一次性备份..."
    exec /app/scripts/backup-to-s3.sh
}

# 主函数
main() {
    local command="${1:-cron}"
    
    log "=== Chatwoot 备份服务启动 ==="
    log "模式: $command"
    log "用户: $(whoami) ($(id))"
    
    # 验证环境变量
    validate_environment
    
    # 等待数据库
    wait_for_database
    
    case "$command" in
        "cron")
            setup_cron
            start_cron
            ;;
        "backup")
            run_backup
            ;;
        "test")
            log "运行备份测试..."
            /app/scripts/backup-to-s3.sh
            ;;
        *)
            log "未知命令: $command"
            log "支持的命令: cron, backup, test"
            exit 1
            ;;
    esac
}

# 捕获信号，优雅关闭
trap 'log "收到退出信号，正在关闭备份服务..."; exit 0' SIGTERM SIGINT

# 运行主函数
main "$@"