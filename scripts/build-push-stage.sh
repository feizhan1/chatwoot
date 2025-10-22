#!/bin/bash

# Chatwoot 自定义镜像构建和推送脚本
# 用于在本地构建镜像并推送到 Docker Hub

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

# 检查是否在项目根目录
if [ ! -f "docker/Dockerfile" ]; then
    log_error "请在项目根目录执行此脚本"
    exit 1
fi

# 加载 .env.build 配置
if [ -f ".env.build" ]; then
    log_info "加载 .env.build 配置..."
    export $(cat .env.build | grep -v '^#' | xargs)
else
    log_error "未找到 .env.build 文件"
    log_error "请复制 .env.build.example 为 .env.build 并配置"
    exit 1
fi

# 验证必要的配置
if [ -z "$DOCKER_USERNAME" ]; then
    log_error "DOCKER_USERNAME 未配置"
    exit 1
fi

if [ -z "$DOCKER_REPOSITORY" ]; then
    log_error "DOCKER_REPOSITORY 未配置"
    exit 1
fi

# 构建镜像名称
DOCKER_IMAGE="${DOCKER_USERNAME}/${DOCKER_REPOSITORY}"
DOCKER_TAG="${DOCKER_TAG:-latest}"

log_info "=========================================="
log_info "Chatwoot 镜像构建配置"
log_info "=========================================="
log_info "镜像名称: ${DOCKER_IMAGE}"
log_info "主标签: ${DOCKER_TAG}"
log_info "工作目录: $(pwd)"
log_info "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    log_error "Docker 未运行，请启动 Docker"
    exit 1
fi

# 检查 Docker Hub 登录状态
log_step "检查 Docker Hub 登录状态..."
if ! docker info | grep -q "Username: $DOCKER_USERNAME" 2>/dev/null; then
    log_warn "未登录 Docker Hub 或用户名不匹配"
    log_info "正在登录 Docker Hub..."
    docker login
fi

# 获取 Git 信息
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

log_info "Git 分支: ${GIT_BRANCH}"
log_info "Git 提交: ${GIT_COMMIT}"

# 构建镜像标签列表
IMAGE_TAGS=("${DOCKER_IMAGE}:${DOCKER_TAG}")

# 添加 Git commit hash 标签
if [ "${PUSH_GIT_TAG}" = "true" ] && [ "$GIT_COMMIT" != "unknown" ]; then
    IMAGE_TAGS+=("${DOCKER_IMAGE}:git-${GIT_COMMIT}")
fi

# 添加版本标签
if [ -n "$VERSION_TAG" ]; then
    IMAGE_TAGS+=("${DOCKER_IMAGE}:${VERSION_TAG}")
fi

# 显示所有标签
log_info "将构建以下标签:"
for tag in "${IMAGE_TAGS[@]}"; do
    echo "  - $tag"
done

# 启用 BuildKit
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}

# 构建参数
BUILD_ARGS=(
    "--build-arg" "RAILS_ENV=${RAILS_ENV:-production}"
    "--build-arg" "NODE_ENV=${NODE_ENV:-production}"
    "--build-arg" "RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES:-true}"
    "--build-arg" "BUNDLE_WITHOUT=${BUNDLE_WITHOUT:-development:test}"
)

# 如果启用缓存
if [ "${USE_CACHE}" = "true" ]; then
    BUILD_ARGS+=("--cache-from" "${DOCKER_IMAGE}:${DOCKER_TAG}")
fi

# 如果指定了平台
if [ -n "$DOCKER_PLATFORM" ]; then
    BUILD_ARGS+=("--platform" "$DOCKER_PLATFORM")
fi

# 添加所有标签到构建命令
for tag in "${IMAGE_TAGS[@]}"; do
    BUILD_ARGS+=("-t" "$tag")
done

# 构建镜像
log_step "开始构建镜像..."
log_info "构建命令: docker build ${BUILD_ARGS[*]} -f docker/Dockerfile ."

if docker build "${BUILD_ARGS[@]}" -f docker/Dockerfile .; then
    log_info "镜像构建成功！"
else
    log_error "镜像构建失败！"
    exit 1
fi

# 显示镜像信息
log_step "查看镜像信息..."
docker images | grep "${DOCKER_REPOSITORY}" | head -5

# 推送镜像
log_step "推送镜像到 Docker Hub..."
for tag in "${IMAGE_TAGS[@]}"; do
    log_info "推送: $tag"
    if docker push "$tag"; then
        log_info "✓ 推送成功: $tag"
    else
        log_error "✗ 推送失败: $tag"
        exit 1
    fi
done

# 清理本地构建缓存（可选）
read -p "$(echo -e ${YELLOW}是否清理构建缓存？[y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "清理构建缓存..."
    docker builder prune -f
fi

echo ""
log_info "=========================================="
log_info "✅ 构建和推送完成！"
log_info "=========================================="
echo ""
log_info "镜像已推送到 Docker Hub:"
for tag in "${IMAGE_TAGS[@]}"; do
    echo "  - $tag"
done
echo ""
log_info "下一步："
echo "  1. 在服务器上拉取镜像:"
echo "     docker pull ${IMAGE_TAGS[0]}"
echo ""
echo "  2. 更新 docker-compose.stage.build.yaml 中的镜像标签（如需要）"
echo ""
echo "  3. 在服务器上部署:"
echo "     docker-compose -f docker-compose.stage.build.yaml pull"
echo "     docker-compose -f docker-compose.stage.build.yaml up -d"
echo ""
log_info "查看镜像详情: https://hub.docker.com/r/${DOCKER_IMAGE}"
echo ""
