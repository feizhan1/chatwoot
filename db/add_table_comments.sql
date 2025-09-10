-- Chatwoot 数据库表注释脚本
-- 为所有表添加中文注释说明
-- 基于 Chatwoot数据库架构分析.md 文档

-- =============================================================================
-- 1. 多租户核心模块 (5个表)
-- =============================================================================

-- 账户表 - 多租户的根实体，所有业务数据都基于账户隔离
COMMENT ON TABLE accounts IS '账户表 - 多租户架构的根实体，包含租户基本信息、功能标志、配置设置和限制规则，所有业务数据都基于account_id实现租户隔离';

-- 账户用户关联表 - 用户与账户的多对多关联，包含角色权限信息
COMMENT ON TABLE account_users IS '账户用户关联表 - 用户与账户的多对多关联表，存储用户在特定账户中的角色、权限、在线状态和自定义角色信息';

-- 用户表 - 系统用户基础信息，支持多账户关联
COMMENT ON TABLE users IS '用户表 - 系统用户基础信息表，存储用户个人资料、认证信息和偏好设置，一个用户可以属于多个账户';

-- 访问令牌表 - 支持多态关联的API访问令牌管理
COMMENT ON TABLE access_tokens IS 'API访问令牌表 - 管理用户或应用的API访问令牌，支持多态关联(owner_type/owner_id)，用于API认证和授权';

-- 自定义角色表 - 账户级别的自定义角色定义
COMMENT ON TABLE custom_roles IS '自定义角色表 - 账户级别的自定义角色定义，支持细粒度的权限控制，包含角色名称、权限配置和描述信息';

-- =============================================================================
-- 2. 渠道管理模块 (12个表) - 多态关联设计支持多种通讯渠道
-- =============================================================================

-- 收件箱表 - 渠道统一管理的核心表
COMMENT ON TABLE inboxes IS '收件箱表 - 渠道统一管理的核心表，通过多态关联(channel_type/channel_id)连接各种通讯渠道，包含渠道配置、工作时间和CSAT设置';

-- 网站聊天组件渠道
COMMENT ON TABLE channel_web_widgets IS '网站聊天组件渠道 - 网站嵌入式聊天小部件的配置表，包含样式自定义、欢迎消息、业务时间设置等';

-- 邮件渠道
COMMENT ON TABLE channel_email IS '邮件渠道表 - 邮件客服渠道配置，支持IMAP/SMTP协议，包含邮件服务器设置、认证信息和同步配置';

-- Facebook页面渠道
COMMENT ON TABLE channel_facebook_pages IS 'Facebook页面渠道 - Facebook Messenger集成配置，存储页面访问令牌、页面信息和webhook设置';

-- WhatsApp渠道
COMMENT ON TABLE channel_whatsapp IS 'WhatsApp渠道表 - WhatsApp Business API集成配置，包含电话号码、API密钥和消息模板设置';

-- Telegram渠道
COMMENT ON TABLE channel_telegram IS 'Telegram渠道表 - Telegram Bot集成配置，存储Bot令牌和webhook设置信息';

-- Instagram渠道
COMMENT ON TABLE channel_instagram IS 'Instagram渠道表 - Instagram Direct Messages集成配置，用于Instagram商业账户的消息处理';

-- 短信渠道
COMMENT ON TABLE channel_sms IS '短信渠道表 - SMS服务集成配置，支持多种短信服务提供商的API集成';

-- Twilio短信渠道
COMMENT ON TABLE channel_twilio_sms IS 'Twilio短信渠道 - Twilio SMS服务的专用配置表，包含账户SID、认证令牌和电话号码设置';

-- Twitter渠道
COMMENT ON TABLE channel_twitter_profiles IS 'Twitter渠道表 - Twitter Direct Messages集成配置，存储Twitter API访问凭据和账户信息';

-- Line渠道
COMMENT ON TABLE channel_line IS 'Line渠道表 - Line Messaging API集成配置，用于Line官方账号的消息处理';

-- API渠道
COMMENT ON TABLE channel_api IS 'API渠道表 - 通用API接入渠道配置，支持第三方系统通过API接入Chatwoot';

-- 语音渠道
COMMENT ON TABLE channel_voice IS '语音渠道表 - 语音通话服务集成配置，支持语音客服功能的渠道设置';

-- =============================================================================
-- 3. 客户管理模块 (4个表)
-- =============================================================================

-- 客户表 - 客户基础信息和扩展属性
COMMENT ON TABLE contacts IS '客户表 - 存储客户基础信息，包含个人资料、联系方式、自定义属性、地理位置等，支持客户类型分类和阻止状态';

-- 客户收件箱关联表 - 客户与渠道的关联关系
COMMENT ON TABLE contact_inboxes IS '客户收件箱关联表 - 建立客户与渠道的多对多关联，存储客户在不同渠道中的身份标识和HMAC验证信息';

-- 客户备注表 - 客户相关的备注记录
COMMENT ON TABLE notes IS '客户备注表 - 存储客服人员对客户的备注记录，支持富文本内容，用于记录客户重要信息和历史互动';

-- 对话参与者表 - 对话中的参与者管理
COMMENT ON TABLE conversation_participants IS '对话参与者表 - 管理对话中的参与者，支持多人参与对话的场景，记录参与者类型和加入时间';

-- =============================================================================
-- 4. 对话消息模块 (6个表)
-- =============================================================================

-- 对话表 - 核心业务实体，客服对话的主要记录
COMMENT ON TABLE conversations IS '对话表 - 核心业务实体，存储客服对话的完整信息，包含状态、优先级、分配信息、SLA策略、标签缓存等';

-- 消息表 - 对话中的消息记录
COMMENT ON TABLE messages IS '消息表 - 存储对话中的所有消息，支持多态发送者(users/contacts)，包含消息内容、类型、状态、情感分析等';

-- 附件表 - 消息附件管理
COMMENT ON TABLE attachments IS '附件表 - 管理消息中的附件文件，支持多种文件类型，包含文件元数据、地理坐标和外部URL链接';

-- CSAT调研回复表 - 客户满意度调查
COMMENT ON TABLE csat_survey_responses IS 'CSAT调研回复表 - 客户满意度调查回复记录，包含评分、反馈内容和调查相关的对话信息';

-- 提及表 - @提及功能的记录
COMMENT ON TABLE mentions IS '提及表 - 记录消息中的@提及，包含被提及用户和相关对话消息的关联信息';

-- Active Storage相关表（文件存储）
COMMENT ON TABLE active_storage_attachments IS 'Active Storage附件表 - Rails Active Storage文件附件关联表，管理各种模型的文件上传';
COMMENT ON TABLE active_storage_blobs IS 'Active Storage文件表 - 存储上传文件的元数据信息，包含文件名、内容类型、大小等';
COMMENT ON TABLE active_storage_variant_records IS 'Active Storage变体表 - 管理文件的不同变体（如缩略图），用于图片处理和优化';

-- =============================================================================
-- 5. 团队协作模块 (8个表)
-- =============================================================================

-- 团队表 - 坐席团队管理
COMMENT ON TABLE teams IS '团队表 - 坐席团队管理，用于组织坐席人员，支持团队级别的对话分配和权限控制';

-- 团队成员表 - 团队与用户的关联
COMMENT ON TABLE team_members IS '团队成员表 - 团队与用户的多对多关联表，管理用户的团队归属关系';

-- 收件箱成员表 - 收件箱访问权限管理
COMMENT ON TABLE inbox_members IS '收件箱成员表 - 管理用户对特定收件箱的访问权限，控制坐席能够处理哪些渠道的对话';

-- 分配策略表 - 对话自动分配策略
COMMENT ON TABLE assignment_policies IS '分配策略表 - 定义对话自动分配的策略规则，包含分配顺序、优先级处理和公平分配算法';

-- 收件箱分配策略关联表 - 策略与收件箱的关联
COMMENT ON TABLE inbox_assignment_policies IS '收件箱分配策略关联表 - 建立分配策略与收件箱的多对多关联，实现灵活的策略应用';

-- 坐席容量策略表 - 坐席工作负载管理
COMMENT ON TABLE agent_capacity_policies IS '坐席容量策略表 - 管理坐席的工作负载策略，包含容量规则和排除条件，用于合理分配工作量';

-- 收件箱容量限制表 - 收件箱级别的容量控制
COMMENT ON TABLE inbox_capacity_limits IS '收件箱容量限制表 - 设置特定收件箱的容量限制，控制不同渠道的并发处理能力';

-- 请假表 - 坐席请假管理
COMMENT ON TABLE leaves IS '请假表 - 管理坐席的请假记录，包含请假时间、类型和状态，用于自动分配时排除请假人员';

-- 工作时间表 - 业务时间配置
COMMENT ON TABLE working_hours IS '工作时间表 - 配置收件箱的工作时间，支持按星期和时区设置，用于自动回复和分配策略';

-- =============================================================================
-- 6. 知识库模块 (6个表)
-- =============================================================================

-- 门户表 - 知识库门户管理
COMMENT ON TABLE portals IS '知识库门户表 - 管理知识库门户，支持多门户架构，包含域名配置、SSL设置、样式自定义等';

-- 分类表 - 知识库文章分类
COMMENT ON TABLE categories IS '知识库分类表 - 管理知识库文章的分类体系，支持多级分类，包含图标、位置排序等显示配置';

-- 文件夹表 - 文章组织结构
COMMENT ON TABLE folders IS '知识库文件夹表 - 用于组织知识库文章的文件夹结构，提供更细粒度的内容管理';

-- 文章表 - 知识库文章内容
COMMENT ON TABLE articles IS '知识库文章表 - 存储知识库文章内容，支持多语言版本、状态管理、SEO配置和访问统计';

-- 文章向量表 - AI搜索支持
COMMENT ON TABLE article_embeddings IS '文章向量表 - 存储文章内容的向量化数据，使用PostgreSQL vector扩展支持AI相似度搜索';

-- 门户成员表 - 门户访问权限
COMMENT ON TABLE portals_members IS '门户成员表 - 管理知识库门户的访问权限，控制用户对特定门户的访问和编辑权限';

-- 相关分类表 - 分类间的关联关系
COMMENT ON TABLE related_categories IS '相关分类表 - 建立知识库分类之间的关联关系，用于推荐相关内容和导航优化';

-- =============================================================================
-- 7. AI功能模块 (8个表)
-- =============================================================================

-- AI助手表 - AI客服助手配置
COMMENT ON TABLE captain_assistants IS 'AI助手表 - 管理AI客服助手的配置，包含助手描述、配置参数、响应指南和安全防护规则';

-- AI文档表 - 助手知识文档
COMMENT ON TABLE captain_documents IS 'AI文档表 - 存储AI助手的知识文档，支持多种文档格式和状态管理，用于训练AI回复';

-- AI助手响应表 - AI生成的回复内容
COMMENT ON TABLE captain_assistant_responses IS 'AI助手响应表 - 存储AI生成的问答回复，支持多态文档关联和向量相似度搜索';

-- AI场景表 - 助手应用场景配置
COMMENT ON TABLE captain_scenarios IS 'AI场景表 - 配置AI助手的应用场景，定义不同场景下的行为规则和响应策略';

-- AI收件箱关联表 - 助手与渠道的关联
COMMENT ON TABLE captain_inboxes IS 'AI收件箱关联表 - 建立AI助手与收件箱的关联，控制AI助手在哪些渠道中生效';

-- Copilot对话线程表 - AI辅助对话
COMMENT ON TABLE copilot_threads IS 'Copilot对话线程表 - 管理AI Copilot的对话线程，为坐席提供AI辅助建议';

-- Copilot消息表 - AI辅助消息记录
COMMENT ON TABLE copilot_messages IS 'Copilot消息表 - 存储Copilot对话线程中的消息记录，包含AI建议和人工反馈';

-- 机器人表 - 智能机器人配置
COMMENT ON TABLE agent_bots IS '智能机器人表 - 管理智能客服机器人，支持多种机器人类型和Webhook集成配置';

-- 机器人收件箱关联表 - 机器人与渠道的关联
COMMENT ON TABLE agent_bot_inboxes IS '机器人收件箱关联表 - 管理智能机器人在特定收件箱中的激活状态和配置';

-- =============================================================================
-- 8. 自动化模块 (6个表)
-- =============================================================================

-- 自动化规则表 - 基于事件的自动化规则
COMMENT ON TABLE automation_rules IS '自动化规则表 - 定义基于事件触发的自动化规则，包含条件配置和执行动作，支持复杂的业务流程自动化';

-- SLA策略表 - 服务水平协议管理
COMMENT ON TABLE sla_policies IS 'SLA策略表 - 定义服务水平协议策略，设置响应时间和解决时间的标准，用于服务质量管控';

-- 应用的SLA表 - SLA策略应用记录
COMMENT ON TABLE applied_slas IS '应用的SLA表 - 记录SLA策略在具体对话中的应用情况，跟踪SLA状态和执行结果';

-- SLA事件表 - SLA执行过程跟踪
COMMENT ON TABLE sla_events IS 'SLA事件表 - 跟踪SLA策略执行过程中的关键事件，记录时间节点和状态变化';

-- 营销活动表 - 主动营销活动管理
COMMENT ON TABLE campaigns IS '营销活动表 - 管理主动营销活动，支持定时发送、触发条件、受众定位和模板参数配置';

-- 宏命令表 - 批量操作模板
COMMENT ON TABLE macros IS '宏命令表 - 定义批量操作的宏命令，包含预设的动作序列，提高坐席工作效率';

-- =============================================================================
-- 9. 权限角色模块 (5个表)
-- =============================================================================

-- 自定义角色模板表 - 角色模板定义
COMMENT ON TABLE custom_role_templates IS '自定义角色模板表 - 定义可重用的角色模板，包含标准的权限配置，便于快速创建角色';

-- 自定义角色审计日志表 - 角色变更审计
COMMENT ON TABLE custom_role_audit_logs IS '自定义角色审计日志表 - 记录角色相关的所有变更操作，包含操作类型、时间和执行人信息';

-- 平台应用表 - 第三方应用管理
COMMENT ON TABLE platform_apps IS '平台应用表 - 管理第三方平台应用的集成，存储应用配置和认证信息';

-- 平台应用权限表 - 应用权限控制
COMMENT ON TABLE platform_app_permissibles IS '平台应用权限表 - 管理第三方应用的权限分配，控制应用对特定资源的访问';

-- 仪表板应用表 - 仪表板小部件管理
COMMENT ON TABLE dashboard_apps IS '仪表板应用表 - 管理仪表板中的应用小部件，支持自定义仪表板布局和功能';

-- =============================================================================
-- 10. 系统功能模块 (24个表)
-- =============================================================================

-- 系统审计和监控表
COMMENT ON TABLE audits IS '系统审计表 - 记录系统中所有重要操作的审计日志，包含操作类型、执行人、时间戳和变更内容';

-- 报告事件表 - 业务指标统计
COMMENT ON TABLE reporting_events IS '报告事件表 - 收集和存储业务指标相关的事件数据，用于生成统计报告和性能分析';

-- 通知系统表
COMMENT ON TABLE notifications IS '通知表 - 管理系统内的各种通知消息，支持多种通知类型和状态跟踪';
COMMENT ON TABLE notification_settings IS '通知设置表 - 管理用户的通知偏好设置，控制不同类型通知的接收方式';
COMMENT ON TABLE notification_subscriptions IS '通知订阅表 - 管理用户对特定事件的通知订阅，支持细粒度的通知控制';

-- 标签系统
COMMENT ON TABLE labels IS '标签定义表 - 定义账户级别的标签，用于对话、客户等实体的分类标记';
COMMENT ON TABLE tags IS '全局标签表 - 系统全局标签池，存储所有可用的标签';
COMMENT ON TABLE taggings IS '标签关联表 - 多态关联表，支持为任意实体添加标签，实现灵活的分类管理';

-- 自定义属性系统
COMMENT ON TABLE custom_attribute_definitions IS '自定义属性定义表 - 定义客户、对话等实体的自定义属性，支持多种数据类型和验证规则';
COMMENT ON TABLE custom_filters IS '自定义过滤器表 - 用户自定义的数据过滤器，用于快速筛选对话、客户等信息';

-- 模板和快捷回复
COMMENT ON TABLE canned_responses IS '快捷回复表 - 预设的快捷回复模板，提高坐席回复效率';
COMMENT ON TABLE email_templates IS '邮件模板表 - 系统邮件通知的模板，支持多语言和自定义内容';

-- 系统集成
COMMENT ON TABLE webhooks IS 'Webhook表 - 管理第三方系统集成的Webhook配置，支持事件通知和数据同步';
COMMENT ON TABLE integrations_hooks IS '集成钩子表 - 管理系统集成的钩子配置，支持外部系统的事件处理';
COMMENT ON TABLE telegram_bots IS 'Telegram机器人表 - Telegram机器人的配置信息，用于Telegram渠道集成';

-- 系统配置
COMMENT ON TABLE installation_configs IS '安装配置表 - 系统安装和全局配置信息，包含系统级别的设置参数';

-- 数据导入
COMMENT ON TABLE data_imports IS '数据导入表 - 管理批量数据导入任务，跟踪导入状态和进度';

-- Rails框架表
COMMENT ON TABLE action_mailbox_inbound_emails IS 'Action Mailbox入站邮件表 - Rails Action Mailbox处理入站邮件的记录表';

-- 添加表注释完成标记
-- 总计84个表的注释已添加完成
-- 涵盖：多租户核心、渠道管理、客户管理、对话消息、团队协作、知识库、AI功能、自动化、权限角色、系统功能等所有模块