#!/bin/bash

# Chatwoot 备份功能测试脚本

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 测试环境变量配置
test_environment() {
    log "=== 测试环境变量配置 ==="
    
    # 加载环境变量
    if [ -f /opt/chatwoot-backup/.env.backup ]; then
        set -a
        source /opt/chatwoot-backup/.env.backup
        set +a
        log "✓ 环境变量文件加载成功"
    else
        log "✗ 环境变量文件不存在: /opt/chatwoot-backup/.env.backup"
        return 1
    fi
    
    # 检查必需的环境变量
    local required_vars=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "S3_BUCKET")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log "✗ 必需的环境变量未设置: $var"
            return 1
        else
            log "✓ $var 已设置"
        fi
    done
}

# 测试数据库连接
test_database_connection() {
    log "=== 测试数据库连接 ==="
    
    # 设置数据库连接参数
    export PGPASSWORD="${DB_PASSWORD:-421124}"
    local host="${DB_HOST:-127.0.0.1}"
    local port="${DB_PORT:-5432}"
    local dbname="${DB_NAME:-chatwoot}"
    local user="${DB_USER:-postgres}"
    
    # 测试连接
    if psql -h "$host" -p "$port" -U "$user" -d "$dbname" -c "SELECT version();" > /dev/null 2>&1; then
        log "✓ 数据库连接成功"
        
        # 获取数据库大小
        local db_size=$(psql -h "$host" -p "$port" -U "$user" -d "$dbname" -t -c "SELECT pg_size_pretty(pg_database_size('$dbname'));" | xargs)
        log "  数据库大小: $db_size"
        
        # 获取表数量
        local table_count=$(psql -h "$host" -p "$port" -U "$user" -d "$dbname" -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
        log "  表数量: $table_count"
        
    else
        log "✗ 数据库连接失败"
        return 1
    fi
}

# 测试 AWS CLI 配置
test_aws_cli() {
    log "=== 测试 AWS CLI 配置 ==="
    
    # 检查 AWS CLI 是否安装
    if ! command -v aws &> /dev/null; then
        log "✗ AWS CLI 未安装"
        return 1
    else
        log "✓ AWS CLI 已安装: $(aws --version 2>&1 | head -1)"
    fi
    
    # 测试 AWS 凭证
    if aws sts get-caller-identity > /dev/null 2>&1; then
        log "✓ AWS 凭证验证成功"
        
        # 显示账户信息
        local account_info=$(aws sts get-caller-identity --output text --query '[Account,Arn]')
        log "  AWS 账户: $account_info"
    else
        log "✗ AWS 凭证验证失败"
        return 1
    fi
    
    # 测试 S3 访问
    if aws s3 ls "s3://$S3_BUCKET" > /dev/null 2>&1; then
        log "✓ S3 存储桶访问成功: $S3_BUCKET"
    else
        log "✗ S3 存储桶访问失败: $S3_BUCKET"
        log "  请检查存储桶是否存在以及权限配置"
        return 1
    fi
}

# 执行测试备份
test_backup_execution() {
    log "=== 执行测试备份 ==="
    
    # 创建测试标记文件
    local test_marker="/tmp/chatwoot-backup-test-$(date +%s)"
    touch "$test_marker"
    
    log "开始执行测试备份..."
    
    # 执行备份脚本
    if /opt/chatwoot-backup/scripts/backup-to-s3.sh; then
        log "✓ 备份脚本执行成功"
        
        # 检查最新的备份文件
        local latest_backup=$(aws s3 ls "s3://$S3_BUCKET/$S3_PREFIX/" --recursive | sort | tail -1 | awk '{print $4}')
        if [ -n "$latest_backup" ]; then
            log "✓ 最新备份文件: $latest_backup"
            
            # 获取文件大小
            local file_size=$(aws s3 ls "s3://$S3_BUCKET/$latest_backup" | awk '{print $3}')
            log "  备份文件大小: $file_size bytes"
        else
            log "✗ 未找到备份文件"
            return 1
        fi
    else
        log "✗ 备份脚本执行失败"
        return 1
    fi
    
    # 清理测试标记文件
    rm -f "$test_marker"
}

# 测试日志配置
test_logging() {
    log "=== 测试日志配置 ==="
    
    local log_file="/var/log/chatwoot-backup.log"
    
    # 检查日志文件是否存在
    if [ -f "$log_file" ]; then
        log "✓ 日志文件存在: $log_file"
        
        # 显示最后几行日志
        log "最近的日志条目:"
        tail -5 "$log_file" | while read -r line; do
            log "  $line"
        done
    else
        log "✗ 日志文件不存在: $log_file"
    fi
    
    # 检查日志轮转配置
    if [ -f "/etc/logrotate.d/chatwoot-backup" ]; then
        log "✓ 日志轮转配置存在"
    else
        log "✗ 日志轮转配置不存在"
    fi
}

# 测试 cron 任务
test_cron_job() {
    log "=== 测试定时任务配置 ==="
    
    # 检查 cron 服务状态
    if systemctl is-active --quiet crond; then
        log "✓ crond 服务运行正常"
    else
        log "✗ crond 服务未运行"
        return 1
    fi
    
    # 检查 crontab 中的备份任务
    if crontab -l 2>/dev/null | grep -q "chatwoot.*backup"; then
        log "✓ 定时任务已配置"
        
        # 显示相关的 cron 任务
        log "当前的备份定时任务:"
        crontab -l | grep -A1 -B1 "chatwoot" | while read -r line; do
            log "  $line"
        done
    else
        log "✗ 未找到备份定时任务"
        return 1
    fi
}

# 生成测试报告
generate_test_report() {
    log "=== 生成测试报告 ==="
    
    local report_file="/tmp/chatwoot-backup-test-report-$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
Chatwoot 数据库备份系统测试报告
=====================================
测试时间: $(date)
服务器: $(hostname)
操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

测试结果:
- 环境变量配置: $([[ $env_test == 0 ]] && echo "通过" || echo "失败")
- 数据库连接: $([[ $db_test == 0 ]] && echo "通过" || echo "失败")
- AWS CLI 配置: $([[ $aws_test == 0 ]] && echo "通过" || echo "失败")
- 备份执行: $([[ $backup_test == 0 ]] && echo "通过" || echo "失败")
- 日志配置: $([[ $log_test == 0 ]] && echo "通过" || echo "失败")
- 定时任务: $([[ $cron_test == 0 ]] && echo "通过" || echo "失败")

总体评估: $([[ $overall_result == 0 ]] && echo "所有测试通过，备份系统可以正常使用" || echo "存在问题，请检查失败的测试项")

详细日志请查看: /var/log/chatwoot-backup.log
EOF
    
    log "测试报告已生成: $report_file"
    cat "$report_file"
}

# 主函数
main() {
    log "=== 开始 Chatwoot 备份系统测试 ==="
    
    # 检查是否以 root 身份运行
    if [ "$EUID" -ne 0 ]; then
        log "ERROR: 请以 root 身份运行此脚本"
        exit 1
    fi
    
    # 执行各项测试
    local env_test=1 db_test=1 aws_test=1 backup_test=1 log_test=1 cron_test=1
    
    test_environment && env_test=0
    test_database_connection && db_test=0
    test_aws_cli && aws_test=0
    test_backup_execution && backup_test=0
    test_logging && log_test=0
    test_cron_job && cron_test=0
    
    # 计算总体结果
    local overall_result=0
    [[ $env_test != 0 ]] && overall_result=1
    [[ $db_test != 0 ]] && overall_result=1
    [[ $aws_test != 0 ]] && overall_result=1
    [[ $backup_test != 0 ]] && overall_result=1
    [[ $log_test != 0 ]] && overall_result=1
    [[ $cron_test != 0 ]] && overall_result=1
    
    # 生成测试报告
    generate_test_report
    
    log "=== 测试完成 ==="
    
    if [ $overall_result -eq 0 ]; then
        log "🎉 所有测试通过！备份系统可以正常使用"
        exit 0
    else
        log "❌ 存在问题，请检查失败的测试项"
        exit 1
    fi
}

main "$@"