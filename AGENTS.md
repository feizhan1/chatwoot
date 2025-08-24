# Chatwoot 开发指南

## 构建 / 测试 / 代码检查

- **初始化**: `bundle install && pnpm install`
- **运行开发环境**: `pnpm dev` 或 `overmind start -f ./Procfile.dev`
- **JS/Vue 代码检查**: `pnpm eslint` / `pnpm eslint:fix`
- **Ruby 代码检查**: `bundle exec rubocop -a`
- **JS 测试**: `pnpm test` 或 `pnpm test:watch`
- **Ruby 测试**: `bundle exec rspec spec/path/to/file_spec.rb`
- **单个测试**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- **运行项目**: `overmind start -f Procfile.dev`

## 代码风格

- **Ruby**: 遵循 RuboCop 规则（最大行长度 150 字符）
- **Vue/JS**: 使用 ESLint（Airbnb base + Vue 3 推荐）
- **Vue 组件**: 使用 PascalCase
- **事件**: 使用 camelCase
- **国际化**: 模板中不使用裸字符串；使用 i18n
- **错误处理**: 使用自定义异常（`lib/custom_exceptions/`）
- **模型**: 验证存在性/唯一性，添加适当的索引
- **类型安全**: Vue 中使用 PropTypes，Rails 中使用强参数
- **命名**: 使用清晰、描述性的名称，保持一致的命名规范
- **Vue API**: 始终使用组合式 API，在顶部使用 `<script setup>`

## 样式

- **仅使用 Tailwind**:  
  - 不要写自定义 CSS  
  - 不要使用作用域 CSS  
  - 不要使用内联样式  
  - 始终使用 Tailwind 工具类  
- **颜色**: 参考 `tailwind.config.js` 中的颜色定义

## 通用指南

- 专注于 MVP：最少的代码变更，仅考虑正常路径
- 避免不必要的防御性编程
- 将复杂任务分解为小的、可测试的单元
- 确认后再迭代
- 除非明确要求，否则避免编写测试规范
- 删除死代码/不可达代码/未使用代码
- 不要为同一逻辑编写多个版本或备份 — 选择最佳方法并实现
- 不要在提交信息中引用 Claude

## 项目特定

- **翻译**:
  - 仅更新 `en.yml` 和 `en.json`
  - 其他语言由社区处理
  - 后端国际化 → `en.yml`，前端国际化 → `en.json`
- **前端**:
  - 对消息气泡使用 `components-next/`（其余部分正在弃用）

## Ruby 最佳实践

- 使用紧凑的 `module/class` 定义；避免嵌套样式

## 企业版说明

- Chatwoot 在 `enterprise/` 下有一个企业版覆盖层，用于扩展/覆盖 OSS 代码。
- 当您添加或修改核心功能时，始终检查 `enterprise/` 中的相应文件，保持行为兼容。
- 遵循此处记录的企业版开发实践：
  - https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38

影响核心逻辑或公共 API 的任何变更的实用检查清单
- 编辑前在两个目录树中搜索相关文件（例如，`rg -n "FooService|ControllerName|ModelName" app enterprise`）。
- 如果添加新的端点、服务或模型，考虑企业版是否需要：
  - 覆盖（例如，`enterprise/app/...`），或
  - 扩展点（例如，`prepend_mod_with`、钩子、配置）以避免硬分叉。
- 避免在 OSS 中硬编码实例或计划特定的行为；优先使用企业版使用的配置、功能标志或扩展点。
- 保持 OSS 和企业版之间的请求/响应契约稳定；引入新 API 时更新两套路由/控制器。
- 重命名/移动共享代码时，在 `enterprise/` 中镜像更改以防止漂移。
- 测试：在 `spec/enterprise` 下添加企业版特定的测试规范，在适用的地方镜像 OSS 测试规范布局。
