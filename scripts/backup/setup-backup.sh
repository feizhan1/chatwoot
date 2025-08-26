#!/bin/bash

# Chatwoot S3 备份设置脚本
# 用于初始化备份环境和安装依赖

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 安装 AWS CLI (如果未安装)
install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log "安装 AWS CLI..."
        
        # CentOS 7 安装方法
        if command -v yum &> /dev/null; then
            # 安装 Python3 和 pip (如果未安装)
            yum install -y python3 python3-pip
            pip3 install awscli --user
            
            # 添加到 PATH
            echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
            export PATH=$PATH:$HOME/.local/bin
        else
            log "请手动安装 AWS CLI"
            exit 1
        fi
        
        log "AWS CLI 安装完成"
    else
        log "AWS CLI 已安装: $(aws --version)"
    fi
}

# 安装 PostgreSQL 客户端工具
install_postgres_client() {
    if ! command -v pg_dump &> /dev/null; then
        log "安装 PostgreSQL 客户端..."
        
        if command -v yum &> /dev/null; then
            yum install -y postgresql
        else
            log "请手动安装 PostgreSQL 客户端 (pg_dump)"
            exit 1
        fi
        
        log "PostgreSQL 客户端安装完成"
    else
        log "PostgreSQL 客户端已安装: $(pg_dump --version)"
    fi
}

# 创建必要的目录
create_directories() {
    log "创建备份相关目录..."
    
    # 备份脚本目录
    mkdir -p /opt/chatwoot-backup/scripts
    mkdir -p /opt/chatwoot-backup/logs
    
    # 临时备份目录
    mkdir -p /tmp/chatwoot-backups
    
    # 日志目录
    mkdir -p /var/log/chatwoot
    
    log "目录创建完成"
}

# 复制备份脚本到系统目录
install_backup_script() {
    log "安装备份脚本..."
    
    # 复制脚本文件
    cp "$(dirname "$0")/backup-to-s3.sh" /opt/chatwoot-backup/scripts/
    chmod +x /opt/chatwoot-backup/scripts/backup-to-s3.sh
    
    # 创建符号链接到 /usr/local/bin
    ln -sf /opt/chatwoot-backup/scripts/backup-to-s3.sh /usr/local/bin/chatwoot-backup
    
    log "备份脚本安装完成"
}

# 配置环境变量
configure_environment() {
    log "配置环境变量..."
    
    # 复制环境变量模板
    if [ -f "$(dirname "$0")/../.env.backup" ]; then
        cp "$(dirname "$0")/../.env.backup" /opt/chatwoot-backup/
        log "环境变量模板已复制到 /opt/chatwoot-backup/.env.backup"
        log "请编辑该文件设置您的 AWS 凭证"
    fi
    
    # 创建加载环境变量的脚本
    cat > /opt/chatwoot-backup/scripts/load-env.sh << 'EOF'
#!/bin/bash
# 加载备份环境变量
if [ -f /opt/chatwoot-backup/.env.backup ]; then
    set -a
    source /opt/chatwoot-backup/.env.backup
    set +a
fi
EOF
    
    chmod +x /opt/chatwoot-backup/scripts/load-env.sh
    
    log "环境变量配置完成"
}

# 设置日志轮转
setup_log_rotation() {
    log "配置日志轮转..."
    
    cat > /etc/logrotate.d/chatwoot-backup << 'EOF'
/var/log/chatwoot-backup.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    create 0644 root root
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF
    
    log "日志轮转配置完成"
}

# 创建 systemd 服务 (可选，用于手动触发备份)
create_systemd_service() {
    log "创建 systemd 服务..."
    
    cat > /etc/systemd/system/chatwoot-backup.service << 'EOF'
[Unit]
Description=Chatwoot Database Backup to S3
After=network.target

[Service]
Type=oneshot
User=root
ExecStartPre=/opt/chatwoot-backup/scripts/load-env.sh
ExecStart=/opt/chatwoot-backup/scripts/backup-to-s3.sh
StandardOutput=append:/var/log/chatwoot-backup.log
StandardError=append:/var/log/chatwoot-backup.log

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    log "systemd 服务创建完成"
}

# 主函数
main() {
    log "=== 开始设置 Chatwoot S3 备份系统 ==="
    
    # 检查是否以 root 身份运行
    if [ "$EUID" -ne 0 ]; then
        log "ERROR: 请以 root 身份运行此脚本"
        exit 1
    fi
    
    install_aws_cli
    install_postgres_client
    create_directories
    install_backup_script
    configure_environment
    setup_log_rotation
    create_systemd_service
    
    log "=== 备份系统设置完成 ==="
    log ""
    log "接下来请执行以下步骤:"
    log "1. 编辑 /opt/chatwoot-backup/.env.backup 设置 AWS 凭证"
    log "2. 测试备份: systemctl start chatwoot-backup"
    log "3. 设置定时任务: crontab -e"
    log "   添加行: 0 0 * * * /opt/chatwoot-backup/scripts/load-env.sh && /opt/chatwoot-backup/scripts/backup-to-s3.sh"
}

main "$@"