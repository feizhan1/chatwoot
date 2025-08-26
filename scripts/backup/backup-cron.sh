#!/bin/bash

# Cron 任务专用的备份脚本包装器

# 设置完整的 PATH
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

# 设置日志
LOG_FILE="/app/logs/backup.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CRON] $1" >> "$LOG_FILE"
}

# 主函数
main() {
    log "=== 开始定时备份任务 ==="
    
    # 执行备份脚本
    if /app/scripts/backup-to-s3.sh >> "$LOG_FILE" 2>&1; then
        log "定时备份任务完成"
    else
        log "ERROR: 定时备份任务失败，退出码: $?"
    fi
    
    log "=== 定时备份任务结束 ==="
}

# 执行主函数
main "$@"