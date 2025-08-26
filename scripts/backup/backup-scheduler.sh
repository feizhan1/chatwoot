#!/bin/bash

# 非 root 用户的自定义备份调度器
# 当无法使用系统 cron 时的替代方案

LOG_FILE="/app/logs/backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SCHEDULER] $1" | tee -a "$LOG_FILE"
}

# 计算距离下次备份的秒数
calculate_next_backup_time() {
    local current_time=$(date +%s)
    local current_hour=$(date +%H)
    local current_minute=$(date +%M)
    local current_second=$(date +%S)
    
    # 计算到今天 0 点的秒数
    local seconds_since_midnight=$((current_hour * 3600 + current_minute * 60 + current_second))
    
    # 计算到明天 0 点的秒数
    local seconds_to_tomorrow=$((86400 - seconds_since_midnight))
    
    echo $seconds_to_tomorrow
}

# 执行备份
run_scheduled_backup() {
    log "执行定时备份..."
    
    if /app/scripts/backup-to-s3.sh >> "$LOG_FILE" 2>&1; then
        log "备份完成"
    else
        log "ERROR: 备份失败，退出码: $?"
    fi
}

# 主循环
main() {
    log "=== 备份调度器启动 ==="
    log "备份时间: 每天 00:00"
    
    while true; do
        # 计算下次备份时间
        local sleep_seconds=$(calculate_next_backup_time)
        local next_backup_time=$(date -d "+${sleep_seconds} seconds" '+%Y-%m-%d %H:%M:%S')
        
        log "下次备份时间: $next_backup_time (${sleep_seconds} 秒后)"
        
        # 等待到备份时间
        sleep "$sleep_seconds"
        
        # 执行备份
        run_scheduled_backup
        
        # 防止在同一分钟内重复执行，额外等待 60 秒
        sleep 60
    done
}

# 捕获信号
trap 'log "调度器收到退出信号"; exit 0' SIGTERM SIGINT

# 运行主函数
main "$@"