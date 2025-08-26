#!/bin/bash

# Chatwoot 备份状态检查脚本

# 配置
S3_BUCKET="tvc-chatwoot-public"  # 修改为你的存储桶
AWS_REGION="us-east-1"
STATUS_LOG="/var/log/chatwoot-backup-status.log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查今天是否有备份
check_today_backup() {
    local today=$(date +%Y%m%d)
    log "🔍 检查今天 ($today) 的备份状态..."
    
    # 检查 S3 中今天的备份文件
    local backup_files=$(aws s3 ls "s3://$S3_BUCKET/chatwoot-backups/" --region "$AWS_REGION" | grep "chatwoot-backup-$today")
    
    if [ -n "$backup_files" ]; then
        log "${GREEN}✅ 今天的备份存在${NC}"
        echo "$backup_files" | while read -r line; do
            local size=$(echo "$line" | awk '{print $3}')
            local filename=$(echo "$line" | awk '{print $4}')
            log "   📁 $filename (大小: $size bytes)"
        done
        return 0
    else
        log "${RED}❌ 今天没有找到备份文件${NC}"
        return 1
    fi
}

# 检查最近的备份状态
check_recent_status() {
    log "📋 检查最近的备份状态日志..."
    
    if [ -f "$STATUS_LOG" ]; then
        log "最近5次备份状态:"
        tail -5 "$STATUS_LOG" | while read -r line; do
            if [[ "$line" == *"SUCCESS"* ]]; then
                echo -e "   ${GREEN}$line${NC}"
            elif [[ "$line" == *"FAILED"* ]]; then
                echo -e "   ${RED}$line${NC}"
            else
                echo "   $line"
            fi
        done
    else
        log "${YELLOW}⚠️  状态日志文件不存在: $STATUS_LOG${NC}"
    fi
}

# 检查 S3 中最新的几个备份
check_latest_backups() {
    log "📂 S3 中最新的5个备份文件:"
    
    aws s3 ls "s3://$S3_BUCKET/chatwoot-backups/" --region "$AWS_REGION" | \
    sort -k1,2 | tail -5 | while read -r line; do
        local date=$(echo "$line" | awk '{print $1 " " $2}')
        local size=$(echo "$line" | awk '{print $3}')
        local filename=$(echo "$line" | awk '{print $4}')
        
        # 检查文件是否是今天的
        local file_date=$(echo "$filename" | grep -o '[0-9]\{8\}')
        local today=$(date +%Y%m%d)
        
        if [ "$file_date" = "$today" ]; then
            log "   ${GREEN}📁 $filename${NC} ($date, $size bytes)"
        else
            log "   📁 $filename ($date, $size bytes)"
        fi
    done
}

# 生成备份报告
generate_report() {
    local today=$(date '+%Y-%m-%d')
    local report_file="/tmp/backup-report-$today.txt"
    
    {
        echo "Chatwoot 备份状态报告"
        echo "======================"
        echo "生成时间: $(date)"
        echo "检查日期: $today"
        echo ""
        
        # 今天备份状态
        if check_today_backup >/dev/null 2>&1; then
            echo "✅ 今天备份: 成功"
        else
            echo "❌ 今天备份: 失败或未找到"
        fi
        
        echo ""
        echo "最新备份文件:"
        aws s3 ls "s3://$S3_BUCKET/chatwoot-backups/" --region "$AWS_REGION" | sort -k1,2 | tail -3
        
        echo ""
        echo "最近备份状态:"
        if [ -f "$STATUS_LOG" ]; then
            tail -3 "$STATUS_LOG"
        else
            echo "状态日志不存在"
        fi
        
    } > "$report_file"
    
    log "📄 报告已生成: $report_file"
    echo "$report_file"
}

# 主函数
main() {
    log "=== Chatwoot 备份状态检查 ==="
    
    # 检查 AWS 配置
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log "${RED}❌ AWS 凭证配置错误${NC}"
        exit 1
    fi
    
    # 检查存储桶配置
    if [ "$S3_BUCKET" = "your-backup-bucket" ]; then
        log "${RED}❌ 请先修改脚本中的 S3_BUCKET 配置${NC}"
        exit 1
    fi
    
    check_today_backup
    today_status=$?
    
    echo ""
    check_recent_status
    
    echo ""
    check_latest_backups
    
    echo ""
    log "=== 检查完成 ==="
    
    # 根据今天备份状态设置退出码
    exit $today_status
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        "report")
            generate_report
            ;;
        "today")
            check_today_backup
            ;;
        *)
            main
            ;;
    esac
fi