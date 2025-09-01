#!/bin/bash

# Chatwoot 备份和状态检查包装脚本
# 执行数据库备份，然后检查备份状态并发送邮件通知

set -e

# AWS 凭证将通过环境变量传入

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== 开始 Chatwoot 备份和检查流程 ==="

# 1. 执行数据库备份
log "步骤 1: 开始数据库备份..."
if ./scripts/simple-backup.sh; then
    log "✅ 数据库备份完成"
    backup_success=true
else
    log "❌ 数据库备份失败"
    backup_success=false
fi

log "步骤 2: 开始备份状态检查和邮件通知..."

# 2. 执行状态检查（无论备份是否成功都要检查）
if ./scripts/check-backup-status.sh; then
    log "✅ 备份状态检查完成，邮件通知已发送"
else
    log "⚠️  备份状态检查完成，但可能有异常"
fi

log "=== Chatwoot 备份和检查流程完成 ==="

# 根据备份结果返回退出码
if [ "$backup_success" = true ]; then
    exit 0
else
    exit 1
fi