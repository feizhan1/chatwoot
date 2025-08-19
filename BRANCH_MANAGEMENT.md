# 分支管理策略文档

## 概述

本文档定义了基于开源 Chatwoot 项目的稳定版本分支管理策略。我们专注于跟踪上游的稳定版本（master 分支），确保代码库的稳定性和可维护性。

## 分支结构

### 远程仓库配置

```bash
# 查看远程仓库
git remote -v

# 预期输出：
origin    https://github.com/feizhan1/chatwoot.git (fetch)
origin    https://github.com/feizhan1/chatwoot.git (push)
upstream  https://github.com/chatwoot/chatwoot.git (fetch)
upstream  https://github.com/chatwoot/chatwoot.git (push)
```

### 分支说明

- **upstream/master**: 开源 Chatwoot 的稳定版本分支（主要跟踪目标）
- **origin/master**: 我们 fork 的主分支，与 upstream/master 保持同步
- **feature/***: 功能开发分支，基于最新的 master 创建
- **fix/***: Bug 修复分支
- **chore/***: 维护任务分支

## 日常工作流程

### 1. 初始设置（仅首次）

```bash
# 添加上游仓库（如果尚未添加）
git remote add upstream https://github.com/chatwoot/chatwoot.git

# 获取所有远程分支
git fetch --all
```

### 2. 同步稳定版本（每天/每周执行）

```bash
# 切换到主分支
git checkout master

# 从上游获取最新更新
git fetch upstream

# 检查新的提交（可选）
git log --oneline master..upstream/master

# 同步到本地 master
git pull upstream master

# 推送到 origin
git push origin master
```

### 3. 功能开发流程

#### 创建功能分支

```bash
# 确保在最新的 master 分支
git checkout master
git pull upstream master

# 创建并切换到功能分支
git checkout -b feature/your-feature-name

# 推送分支到 origin
git push -u origin feature/your-feature-name
```

#### 开发过程中

```bash
# 定期同步 master 的更新（推荐每天）
git fetch upstream
git rebase upstream/master

# 或者使用 merge（如果有冲突需要保留历史）
git merge upstream/master

# 推送更新
git push origin feature/your-feature-name --force-with-lease
```

#### 完成功能开发

```bash
# 最后一次同步 master
git checkout master
git pull upstream master
git checkout feature/your-feature-name
git rebase upstream/master

# 推送并创建 PR
git push origin feature/your-feature-name --force-with-lease

# 在 GitHub 创建 Pull Request 到 master 分支
```

### 4. Bug 修复流程

```bash
# 基于 master 创建修复分支
git checkout master
git pull upstream master
git checkout -b fix/issue-description

# 修复、测试、提交
git add .
git commit -m "fix: resolve issue with ..."

# 推送并创建 PR
git push origin fix/issue-description
```

## 分支命名规范

### 功能分支
- `feature/user-authentication` - 用户认证功能
- `feature/email-templates` - 邮件模板功能
- `feature/api-v2` - API v2 开发

### 修复分支
- `fix/login-error` - 修复登录错误
- `fix/memory-leak` - 修复内存泄漏
- `fix/ui-responsive` - 修复响应式问题

### 维护分支
- `chore/update-dependencies` - 更新依赖包
- `chore/refactor-services` - 重构服务层
- `chore/improve-tests` - 改进测试

## 重要原则

### ✅ 应该做的

1. **始终基于最新的 master**: 创建新分支前先同步 upstream/master
2. **保持分支小而专注**: 一个分支只做一件事
3. **定期同步**: 功能分支定期 rebase 到最新的 master
4. **清晰的提交信息**: 使用规范的 commit message 格式
5. **及时清理**: PR 合并后删除功能分支

### ❌ 避免的做法

1. **不要跟踪 develop 分支**: 我们只关注稳定版本
2. **不要直接修改 master**: 所有更改通过 PR 进行
3. **不要长期维护功能分支**: 避免分支存在时间过长导致冲突
4. **不要忽略冲突**: 及时解决 rebase 过程中的冲突
5. **不要跳过测试**: 确保功能分支通过所有测试

## 版本管理

### 版本跟踪

```bash
# 查看当前版本
cat VERSION_CW

# 查看版本历史
git tag --sort=-version:refname | head -10

# 检查与特定版本的差异
git diff v4.5.0..master
```

### 发布准备

```bash
# 确保与上游完全同步
git checkout master
git fetch upstream
git reset --hard upstream/master
git push origin master
```

## 故障排除

### 常见问题及解决方案

#### 推送被拒绝
```bash
# 如果遇到 "You can't push directly to master branch"
# 使用 --no-verify 跳过 pre-push 钩子
git push origin master --no-verify

# 或者修改 bin/validate_push 文件中的限制
```

#### 合并冲突
```bash
# 在 rebase 过程中解决冲突
git status  # 查看冲突文件
# 手动编辑冲突文件
git add .
git rebase --continue

# 如果需要中止 rebase
git rebase --abort
```

#### 分支落后太多
```bash
# 重新基于最新 master 创建分支
git checkout master
git pull upstream master
git checkout -b feature/your-feature-name-v2
git cherry-pick <commit-hash>  # 选择性应用之前的提交
```

## 自动化脚本

### 同步脚本 (sync-master.sh)

```bash
#!/bin/bash
set -e

echo "🔄 Syncing master branch with upstream..."

# 切换到 master 分支
git checkout master

# 获取上游更新
git fetch upstream

# 显示新的提交
echo "📋 New commits from upstream:"
git log --oneline master..upstream/master

# 确认是否继续
read -p "Continue with sync? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "❌ Sync cancelled"
    exit 1
fi

# 同步并推送
git pull upstream master
git push origin master

echo "✅ Master branch synced successfully!"
```

### 功能分支创建脚本 (create-feature.sh)

```bash
#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

FEATURE_NAME="feature/$1"

echo "🚀 Creating feature branch: $FEATURE_NAME"

# 确保在最新的 master
git checkout master
git pull upstream master

# 创建并切换到功能分支
git checkout -b "$FEATURE_NAME"

# 推送到 origin
git push -u origin "$FEATURE_NAME"

echo "✅ Feature branch $FEATURE_NAME created and pushed!"
```

## 团队协作

### Code Review 检查清单

- [ ] 代码遵循项目规范（ESLint, RuboCop）
- [ ] 包含适当的测试
- [ ] 功能分支基于最新的 master
- [ ] 提交信息清晰明确
- [ ] 没有不必要的文件更改
- [ ] 通过所有 CI 检查

### PR 模板要点

```markdown
## 功能描述
简要描述此 PR 实现的功能或修复的问题

## 更改类型
- [ ] 新功能 (feature)
- [ ] Bug 修复 (fix)  
- [ ] 重构 (refactor)
- [ ] 文档更新 (docs)
- [ ] 其他 (chore)

## 测试
- [ ] 添加了新的测试用例
- [ ] 现有测试仍然通过
- [ ] 手动测试通过

## 检查清单
- [ ] 基于最新的 master 分支
- [ ] 遵循代码规范
- [ ] 更新了相关文档
```

## 监控和维护

### 定期任务

#### 每日
- 同步 master 分支
- 检查功能分支状态

#### 每周  
- 清理已合并的功能分支
- 检查依赖包更新

#### 每月
- 评估分支管理策略效果
- 更新相关文档

---

*最后更新: 2025-08-19*  
*维护者: 开发团队*