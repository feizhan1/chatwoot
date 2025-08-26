#!/bin/bash

# 安装 Chatwoot 数据库备份定时任务

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 创建 cron 任务脚本
create_cron_wrapper() {
    log "创建 cron 任务包装脚本..."
    
    cat > /opt/chatwoot-backup/scripts/cron-backup.sh << 'EOF'
#!/bin/bash

# Cron 任务包装脚本 - 加载环境变量并执行备份

# 设置完整的 PATH
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

# 加载环境变量
if [ -f /opt/chatwoot-backup/.env.backup ]; then
    set -a
    source /opt/chatwoot-backup/.env.backup
    set +a
fi

# 执行备份脚本
/opt/chatwoot-backup/scripts/backup-to-s3.sh >> /var/log/chatwoot-backup.log 2>&1
EOF
    
    chmod +x /opt/chatwoot-backup/scripts/cron-backup.sh
    log "Cron 包装脚本创建完成"
}

# 安装定时任务
install_cron_job() {
    log "安装定时任务..."
    
    # 备份现有的 crontab
    crontab -l > /tmp/crontab.backup 2>/dev/null || echo "# 空的 crontab" > /tmp/crontab.backup
    
    # 检查是否已存在备份任务
    if grep -q "chatwoot.*backup" /tmp/crontab.backup; then
        log "检测到已存在的备份任务，先删除旧任务..."
        grep -v "chatwoot.*backup" /tmp/crontab.backup > /tmp/crontab.new
        cp /tmp/crontab.new /tmp/crontab.backup
    fi
    
    # 添加新的备份任务 (每天凌晨0点执行)
    echo "# Chatwoot 数据库每日备份到 S3 (每天凌晨0点)" >> /tmp/crontab.backup
    echo "0 0 * * * /opt/chatwoot-backup/scripts/cron-backup.sh" >> /tmp/crontab.backup
    
    # 安装新的 crontab
    crontab /tmp/crontab.backup
    
    # 清理临时文件
    rm -f /tmp/crontab.backup /tmp/crontab.new
    
    log "定时任务安装完成"
}

# 验证 cron 服务状态
verify_cron_service() {
    log "验证 cron 服务状态..."
    
    if systemctl is-active --quiet crond; then
        log "crond 服务运行正常"
    else
        log "启动 crond 服务..."
        systemctl enable crond
        systemctl start crond
    fi
}

# 显示当前的 crontab
show_current_crontab() {
    log "当前的 crontab 配置:"
    crontab -l | grep -A1 -B1 "chatwoot" || log "未找到相关任务"
}

# 主函数
main() {
    log "=== 安装 Chatwoot 备份定时任务 ==="
    
    # 检查是否以 root 身份运行
    if [ "$EUID" -ne 0 ]; then
        log "ERROR: 请以 root 身份运行此脚本"
        exit 1
    fi
    
    create_cron_wrapper
    verify_cron_service
    install_cron_job
    show_current_crontab
    
    log "=== 定时任务安装完成 ==="
    log ""
    log "备份任务已设置为每天凌晨0点自动执行"
    log "日志文件: /var/log/chatwoot-backup.log"
    log ""
    log "可用的管理命令:"
    log "- 手动执行备份: systemctl start chatwoot-backup"
    log "- 查看定时任务: crontab -l"
    log "- 查看备份日志: tail -f /var/log/chatwoot-backup.log"
}

main "$@"