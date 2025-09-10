-- Chatwoot 数据库字段注释脚本
-- 为所有表字段添加中文注释说明
-- 配合 add_table_comments.sql 使用

-- =============================================================================
-- 1. 多租户核心模块字段注释 (5个表)
-- =============================================================================

-- accounts 表字段注释
COMMENT ON COLUMN accounts.id IS '账户ID，主键，自增';
COMMENT ON COLUMN accounts.name IS '账户名称，租户显示名称';
COMMENT ON COLUMN accounts.created_at IS '创建时间';
COMMENT ON COLUMN accounts.updated_at IS '更新时间';
COMMENT ON COLUMN accounts.locale IS '语言区域设置，0=英语';
COMMENT ON COLUMN accounts.domain IS '自定义域名，可为空';
COMMENT ON COLUMN accounts.support_email IS '客服邮箱地址';
COMMENT ON COLUMN accounts.feature_flags IS '功能标志位图，控制功能开关';
COMMENT ON COLUMN accounts.auto_resolve_duration IS '自动解决对话时长(分钟)';
COMMENT ON COLUMN accounts.limits IS '账户限制配置JSON，包含用户数、对话数等限制';
COMMENT ON COLUMN accounts.custom_attributes IS '自定义属性JSON配置';
COMMENT ON COLUMN accounts.status IS '账户状态，0=激活，1=暂停';
COMMENT ON COLUMN accounts.internal_attributes IS '内部属性JSON，系统内部使用';
COMMENT ON COLUMN accounts.settings IS '账户设置JSON配置';

-- account_users 表字段注释
COMMENT ON COLUMN account_users.id IS '关联ID，主键，自增';
COMMENT ON COLUMN account_users.account_id IS '账户ID，关联accounts表';
COMMENT ON COLUMN account_users.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN account_users.role IS '用户角色，0=管理员，1=坐席';
COMMENT ON COLUMN account_users.inviter_id IS '邀请人用户ID';
COMMENT ON COLUMN account_users.created_at IS '关联创建时间';
COMMENT ON COLUMN account_users.updated_at IS '关联更新时间';
COMMENT ON COLUMN account_users.active_at IS '最后活跃时间';
COMMENT ON COLUMN account_users.availability IS '可用状态，0=在线，1=忙碌，2=离线';
COMMENT ON COLUMN account_users.auto_offline IS '自动离线标志';
COMMENT ON COLUMN account_users.custom_role_id IS '自定义角色ID，关联custom_roles表';
COMMENT ON COLUMN account_users.agent_capacity_policy_id IS '坐席容量策略ID';

-- users 表字段注释  
COMMENT ON COLUMN users.id IS '用户ID，主键，自增';
COMMENT ON COLUMN users.provider IS '认证提供商，默认email';
COMMENT ON COLUMN users.uid IS '提供商用户唯一标识';
COMMENT ON COLUMN users.encrypted_password IS '加密密码';
COMMENT ON COLUMN users.reset_password_token IS '重置密码令牌';
COMMENT ON COLUMN users.reset_password_sent_at IS '密码重置邮件发送时间';
COMMENT ON COLUMN users.remember_created_at IS '记住登录创建时间';
COMMENT ON COLUMN users.sign_in_count IS '登录次数统计';
COMMENT ON COLUMN users.current_sign_in_at IS '当前登录时间';
COMMENT ON COLUMN users.last_sign_in_at IS '上次登录时间';
COMMENT ON COLUMN users.current_sign_in_ip IS '当前登录IP地址';
COMMENT ON COLUMN users.last_sign_in_ip IS '上次登录IP地址';
COMMENT ON COLUMN users.confirmation_token IS '邮箱确认令牌';
COMMENT ON COLUMN users.confirmed_at IS '邮箱确认时间';
COMMENT ON COLUMN users.confirmation_sent_at IS '确认邮件发送时间';
COMMENT ON COLUMN users.unconfirmed_email IS '待确认的邮箱地址';
COMMENT ON COLUMN users.name IS '用户姓名';
COMMENT ON COLUMN users.display_name IS '显示名称';
COMMENT ON COLUMN users.email IS '邮箱地址';
COMMENT ON COLUMN users.tokens IS 'API令牌JSON配置';
COMMENT ON COLUMN users.created_at IS '用户创建时间';
COMMENT ON COLUMN users.updated_at IS '用户更新时间';
COMMENT ON COLUMN users.pubsub_token IS 'WebSocket订阅令牌';
COMMENT ON COLUMN users.availability IS '用户可用状态，0=在线';
COMMENT ON COLUMN users.ui_settings IS 'UI偏好设置JSON';
COMMENT ON COLUMN users.custom_attributes IS '用户自定义属性JSON';
COMMENT ON COLUMN users.type IS '用户类型，支持STI继承';
COMMENT ON COLUMN users.message_signature IS '消息签名';

-- access_tokens 表字段注释
COMMENT ON COLUMN access_tokens.id IS 'Token ID，主键，自增';
COMMENT ON COLUMN access_tokens.owner_type IS '所有者类型，多态关联';
COMMENT ON COLUMN access_tokens.owner_id IS '所有者ID，多态关联';
COMMENT ON COLUMN access_tokens.token IS 'API访问令牌';
COMMENT ON COLUMN access_tokens.created_at IS '令牌创建时间';
COMMENT ON COLUMN access_tokens.updated_at IS '令牌更新时间';

-- custom_roles 表字段注释
COMMENT ON COLUMN custom_roles.id IS '角色ID，主键，自增';
COMMENT ON COLUMN custom_roles.name IS '角色名称';
COMMENT ON COLUMN custom_roles.description IS '角色描述';
COMMENT ON COLUMN custom_roles.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN custom_roles.permissions IS '权限列表数组';
COMMENT ON COLUMN custom_roles.created_at IS '角色创建时间';
COMMENT ON COLUMN custom_roles.updated_at IS '角色更新时间';
COMMENT ON COLUMN custom_roles.parent_id IS '父角色ID，支持角色继承';
COMMENT ON COLUMN custom_roles.is_system IS '是否系统内置角色';

-- =============================================================================
-- 2. 渠道管理模块字段注释 (13个表) - 多态关联设计支持多种通讯渠道
-- =============================================================================

-- inboxes 表字段注释
COMMENT ON COLUMN inboxes.id IS '收件箱ID，主键，自增';
COMMENT ON COLUMN inboxes.channel_id IS '渠道ID，多态关联到各channel_*表';
COMMENT ON COLUMN inboxes.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN inboxes.name IS '收件箱名称';
COMMENT ON COLUMN inboxes.created_at IS '创建时间';
COMMENT ON COLUMN inboxes.updated_at IS '更新时间';
COMMENT ON COLUMN inboxes.channel_type IS '渠道类型，多态关联的类型标识';
COMMENT ON COLUMN inboxes.enable_auto_assignment IS '是否启用自动分配';
COMMENT ON COLUMN inboxes.greeting_enabled IS '是否启用问候消息';
COMMENT ON COLUMN inboxes.greeting_message IS '问候消息内容';
COMMENT ON COLUMN inboxes.email_address IS '收件箱邮箱地址';
COMMENT ON COLUMN inboxes.working_hours_enabled IS '是否启用工作时间';
COMMENT ON COLUMN inboxes.out_of_office_message IS '非工作时间自动回复消息';
COMMENT ON COLUMN inboxes.timezone IS '时区设置，默认UTC';
COMMENT ON COLUMN inboxes.enable_email_collect IS '是否启用邮箱收集';
COMMENT ON COLUMN inboxes.csat_survey_enabled IS '是否启用CSAT满意度调查';
COMMENT ON COLUMN inboxes.allow_messages_after_resolved IS '对话解决后是否允许继续发消息';
COMMENT ON COLUMN inboxes.auto_assignment_config IS '自动分配配置JSON';
COMMENT ON COLUMN inboxes.lock_to_single_conversation IS '是否锁定为单对话模式';
COMMENT ON COLUMN inboxes.portal_id IS '关联知识库门户ID';
COMMENT ON COLUMN inboxes.sender_name_type IS '发送者名称类型，0=友好名称';
COMMENT ON COLUMN inboxes.business_name IS '企业名称';
COMMENT ON COLUMN inboxes.csat_config IS 'CSAT调查配置JSON';

-- channel_web_widgets 表字段注释
COMMENT ON COLUMN channel_web_widgets.id IS '网站组件ID，主键，自增';
COMMENT ON COLUMN channel_web_widgets.website_url IS '网站URL地址';
COMMENT ON COLUMN channel_web_widgets.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_web_widgets.created_at IS '创建时间';
COMMENT ON COLUMN channel_web_widgets.updated_at IS '更新时间';
COMMENT ON COLUMN channel_web_widgets.website_token IS '网站令牌，用于验证';
COMMENT ON COLUMN channel_web_widgets.widget_color IS '组件颜色，默认#1f93ff';
COMMENT ON COLUMN channel_web_widgets.welcome_title IS '欢迎标题';
COMMENT ON COLUMN channel_web_widgets.welcome_tagline IS '欢迎副标题';
COMMENT ON COLUMN channel_web_widgets.feature_flags IS '功能标志位图';
COMMENT ON COLUMN channel_web_widgets.reply_time IS '回复时间设置，0=立即';
COMMENT ON COLUMN channel_web_widgets.hmac_token IS 'HMAC验证令牌';
COMMENT ON COLUMN channel_web_widgets.pre_chat_form_enabled IS '是否启用对话前表单';
COMMENT ON COLUMN channel_web_widgets.pre_chat_form_options IS '对话前表单配置JSON';
COMMENT ON COLUMN channel_web_widgets.hmac_mandatory IS '是否强制HMAC验证';
COMMENT ON COLUMN channel_web_widgets.continuity_via_email IS '是否通过邮件保持连续性';

-- channel_email 表字段注释
COMMENT ON COLUMN channel_email.id IS '邮件渠道ID，主键，自增';
COMMENT ON COLUMN channel_email.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_email.email IS '邮件地址';
COMMENT ON COLUMN channel_email.forward_to_email IS '转发到邮箱地址';
COMMENT ON COLUMN channel_email.created_at IS '创建时间';
COMMENT ON COLUMN channel_email.updated_at IS '更新时间';
COMMENT ON COLUMN channel_email.imap_enabled IS '是否启用IMAP';
COMMENT ON COLUMN channel_email.imap_address IS 'IMAP服务器地址';
COMMENT ON COLUMN channel_email.imap_port IS 'IMAP端口号';
COMMENT ON COLUMN channel_email.imap_login IS 'IMAP登录名';
COMMENT ON COLUMN channel_email.imap_password IS 'IMAP密码';
COMMENT ON COLUMN channel_email.imap_enable_ssl IS 'IMAP是否启用SSL';
COMMENT ON COLUMN channel_email.smtp_enabled IS '是否启用SMTP';
COMMENT ON COLUMN channel_email.smtp_address IS 'SMTP服务器地址';
COMMENT ON COLUMN channel_email.smtp_port IS 'SMTP端口号';
COMMENT ON COLUMN channel_email.smtp_login IS 'SMTP登录名';
COMMENT ON COLUMN channel_email.smtp_password IS 'SMTP密码';
COMMENT ON COLUMN channel_email.smtp_domain IS 'SMTP域名';
COMMENT ON COLUMN channel_email.smtp_enable_starttls_auto IS '是否自动启用STARTTLS';
COMMENT ON COLUMN channel_email.smtp_authentication IS 'SMTP认证方式，默认login';
COMMENT ON COLUMN channel_email.smtp_openssl_verify_mode IS 'OpenSSL验证模式';
COMMENT ON COLUMN channel_email.smtp_enable_ssl_tls IS '是否启用SSL/TLS';
COMMENT ON COLUMN channel_email.provider_config IS '邮件服务商配置JSON';
COMMENT ON COLUMN channel_email.provider IS '邮件服务商';

-- channel_facebook_pages 表字段注释
COMMENT ON COLUMN channel_facebook_pages.id IS 'Facebook页面ID，主键，自增';
COMMENT ON COLUMN channel_facebook_pages.page_id IS 'Facebook页面ID';
COMMENT ON COLUMN channel_facebook_pages.user_access_token IS '用户访问令牌';
COMMENT ON COLUMN channel_facebook_pages.page_access_token IS '页面访问令牌';
COMMENT ON COLUMN channel_facebook_pages.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_facebook_pages.created_at IS '创建时间';
COMMENT ON COLUMN channel_facebook_pages.updated_at IS '更新时间';
COMMENT ON COLUMN channel_facebook_pages.instagram_id IS '关联Instagram ID';

-- channel_whatsapp 表字段注释
COMMENT ON COLUMN channel_whatsapp.id IS 'WhatsApp渠道ID，主键，自增';
COMMENT ON COLUMN channel_whatsapp.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_whatsapp.phone_number IS '电话号码';
COMMENT ON COLUMN channel_whatsapp.provider IS '服务提供商，默认default';
COMMENT ON COLUMN channel_whatsapp.provider_config IS '提供商配置JSON';
COMMENT ON COLUMN channel_whatsapp.created_at IS '创建时间';
COMMENT ON COLUMN channel_whatsapp.updated_at IS '更新时间';
COMMENT ON COLUMN channel_whatsapp.message_templates IS '消息模板JSON配置';
COMMENT ON COLUMN channel_whatsapp.message_templates_last_updated IS '消息模板最后更新时间';

-- channel_telegram 表字段注释
COMMENT ON COLUMN channel_telegram.id IS 'Telegram渠道ID，主键，自增';
COMMENT ON COLUMN channel_telegram.bot_name IS 'Bot名称';
COMMENT ON COLUMN channel_telegram.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_telegram.bot_token IS 'Bot令牌';
COMMENT ON COLUMN channel_telegram.created_at IS '创建时间';
COMMENT ON COLUMN channel_telegram.updated_at IS '更新时间';

-- channel_instagram 表字段注释
COMMENT ON COLUMN channel_instagram.id IS 'Instagram渠道ID，主键，自增';
COMMENT ON COLUMN channel_instagram.access_token IS '访问令牌';
COMMENT ON COLUMN channel_instagram.expires_at IS '令牌过期时间';
COMMENT ON COLUMN channel_instagram.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_instagram.instagram_id IS 'Instagram账户ID';
COMMENT ON COLUMN channel_instagram.created_at IS '创建时间';
COMMENT ON COLUMN channel_instagram.updated_at IS '更新时间';

-- channel_sms 表字段注释
COMMENT ON COLUMN channel_sms.id IS '短信渠道ID，主键，自增';
COMMENT ON COLUMN channel_sms.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_sms.phone_number IS '电话号码';
COMMENT ON COLUMN channel_sms.provider IS '短信服务提供商';
COMMENT ON COLUMN channel_sms.provider_config IS '提供商配置JSON';
COMMENT ON COLUMN channel_sms.created_at IS '创建时间';
COMMENT ON COLUMN channel_sms.updated_at IS '更新时间';

-- channel_twilio_sms 表字段注释
COMMENT ON COLUMN channel_twilio_sms.id IS 'Twilio短信渠道ID，主键，自增';
COMMENT ON COLUMN channel_twilio_sms.phone_number IS '电话号码';
COMMENT ON COLUMN channel_twilio_sms.auth_token IS '认证令牌';
COMMENT ON COLUMN channel_twilio_sms.account_sid IS '账户SID';
COMMENT ON COLUMN channel_twilio_sms.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_twilio_sms.created_at IS '创建时间';
COMMENT ON COLUMN channel_twilio_sms.updated_at IS '更新时间';
COMMENT ON COLUMN channel_twilio_sms.medium IS '媒体类型，0=短信';
COMMENT ON COLUMN channel_twilio_sms.messaging_service_sid IS '消息服务SID';
COMMENT ON COLUMN channel_twilio_sms.api_key_sid IS 'API密钥SID';

-- channel_twitter_profiles 表字段注释
COMMENT ON COLUMN channel_twitter_profiles.id IS 'Twitter渠道ID，主键，自增';
COMMENT ON COLUMN channel_twitter_profiles.profile_id IS 'Twitter档案ID';
COMMENT ON COLUMN channel_twitter_profiles.twitter_access_token IS 'Twitter访问令牌';
COMMENT ON COLUMN channel_twitter_profiles.twitter_access_token_secret IS 'Twitter访问令牌密钥';
COMMENT ON COLUMN channel_twitter_profiles.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_twitter_profiles.created_at IS '创建时间';
COMMENT ON COLUMN channel_twitter_profiles.updated_at IS '更新时间';
COMMENT ON COLUMN channel_twitter_profiles.tweets_enabled IS '是否启用推文功能';

-- channel_line 表字段注释
COMMENT ON COLUMN channel_line.id IS 'Line渠道ID，主键，自增';
COMMENT ON COLUMN channel_line.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_line.line_channel_id IS 'Line频道ID';
COMMENT ON COLUMN channel_line.line_channel_secret IS 'Line频道密钥';
COMMENT ON COLUMN channel_line.line_channel_token IS 'Line频道令牌';
COMMENT ON COLUMN channel_line.created_at IS '创建时间';
COMMENT ON COLUMN channel_line.updated_at IS '更新时间';

-- channel_api 表字段注释
COMMENT ON COLUMN channel_api.id IS 'API渠道ID，主键，自增';
COMMENT ON COLUMN channel_api.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_api.webhook_url IS 'Webhook URL地址';
COMMENT ON COLUMN channel_api.created_at IS '创建时间';
COMMENT ON COLUMN channel_api.updated_at IS '更新时间';
COMMENT ON COLUMN channel_api.identifier IS '渠道标识符';
COMMENT ON COLUMN channel_api.hmac_token IS 'HMAC验证令牌';
COMMENT ON COLUMN channel_api.hmac_mandatory IS '是否强制HMAC验证';
COMMENT ON COLUMN channel_api.additional_attributes IS '额外属性JSON配置';

-- channel_voice 表字段注释
COMMENT ON COLUMN channel_voice.id IS '语音渠道ID，主键，自增';
COMMENT ON COLUMN channel_voice.phone_number IS '电话号码';
COMMENT ON COLUMN channel_voice.provider IS '语音服务提供商，默认twilio';
COMMENT ON COLUMN channel_voice.provider_config IS '提供商配置JSON';
COMMENT ON COLUMN channel_voice.account_id IS '所属账户ID';
COMMENT ON COLUMN channel_voice.additional_attributes IS '额外属性JSON配置';
COMMENT ON COLUMN channel_voice.created_at IS '创建时间';
COMMENT ON COLUMN channel_voice.updated_at IS '更新时间';

-- =============================================================================
-- 3. 客户管理模块字段注释 (4个表)
-- =============================================================================

-- contacts 表字段注释
COMMENT ON COLUMN contacts.id IS '客户ID，主键，自增';
COMMENT ON COLUMN contacts.name IS '客户姓名';
COMMENT ON COLUMN contacts.email IS '客户邮箱地址';
COMMENT ON COLUMN contacts.phone_number IS '客户电话号码';
COMMENT ON COLUMN contacts.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN contacts.created_at IS '客户创建时间';
COMMENT ON COLUMN contacts.updated_at IS '客户更新时间';
COMMENT ON COLUMN contacts.additional_attributes IS '额外属性JSON，存储扩展信息';
COMMENT ON COLUMN contacts.identifier IS '客户唯一标识符';
COMMENT ON COLUMN contacts.custom_attributes IS '自定义属性JSON配置';
COMMENT ON COLUMN contacts.last_activity_at IS '最后活跃时间';
COMMENT ON COLUMN contacts.contact_type IS '客户类型，0=普通客户';
COMMENT ON COLUMN contacts.middle_name IS '中间名';
COMMENT ON COLUMN contacts.last_name IS '姓氏';
COMMENT ON COLUMN contacts.location IS '地理位置';
COMMENT ON COLUMN contacts.country_code IS '国家代码';
COMMENT ON COLUMN contacts.blocked IS '是否被阻止，默认false';

-- contact_inboxes 表字段注释
COMMENT ON COLUMN contact_inboxes.id IS '关联ID，主键，自增';
COMMENT ON COLUMN contact_inboxes.contact_id IS '客户ID，关联contacts表';
COMMENT ON COLUMN contact_inboxes.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN contact_inboxes.source_id IS '渠道来源标识，不可为空';
COMMENT ON COLUMN contact_inboxes.created_at IS '关联创建时间';
COMMENT ON COLUMN contact_inboxes.updated_at IS '关联更新时间';
COMMENT ON COLUMN contact_inboxes.hmac_verified IS '是否通过HMAC验证';
COMMENT ON COLUMN contact_inboxes.pubsub_token IS 'WebSocket订阅令牌';

-- notes 表字段注释
COMMENT ON COLUMN notes.id IS '备注ID，主键，自增';
COMMENT ON COLUMN notes.content IS '备注内容，支持富文本';
COMMENT ON COLUMN notes.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN notes.contact_id IS '关联客户ID，关联contacts表';
COMMENT ON COLUMN notes.user_id IS '创建人用户ID，关联users表';
COMMENT ON COLUMN notes.created_at IS '备注创建时间';
COMMENT ON COLUMN notes.updated_at IS '备注更新时间';

-- conversation_participants 表字段注释
COMMENT ON COLUMN conversation_participants.id IS '参与者ID，主键，自增';
COMMENT ON COLUMN conversation_participants.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN conversation_participants.user_id IS '参与用户ID，关联users表';
COMMENT ON COLUMN conversation_participants.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN conversation_participants.created_at IS '参与时间';
COMMENT ON COLUMN conversation_participants.updated_at IS '更新时间';

-- =============================================================================
-- 4. 对话消息模块字段注释 (8个表)
-- =============================================================================

-- conversations 表字段注释
COMMENT ON COLUMN conversations.id IS '对话ID，主键，自增';
COMMENT ON COLUMN conversations.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN conversations.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN conversations.status IS '对话状态，0=打开，1=已解决，2=待处理';
COMMENT ON COLUMN conversations.assignee_id IS '分配的坐席ID，关联users表';
COMMENT ON COLUMN conversations.created_at IS '对话创建时间';
COMMENT ON COLUMN conversations.updated_at IS '对话更新时间';
COMMENT ON COLUMN conversations.contact_id IS '客户ID，关联contacts表';
COMMENT ON COLUMN conversations.display_id IS '显示ID，用户友好的序列号';
COMMENT ON COLUMN conversations.contact_last_seen_at IS '客户最后查看时间';
COMMENT ON COLUMN conversations.agent_last_seen_at IS '坐席最后查看时间';
COMMENT ON COLUMN conversations.additional_attributes IS '额外属性JSON配置';
COMMENT ON COLUMN conversations.contact_inbox_id IS '客户收件箱关联ID';
COMMENT ON COLUMN conversations.uuid IS '对话UUID，唯一标识';
COMMENT ON COLUMN conversations.identifier IS '对话标识符';
COMMENT ON COLUMN conversations.last_activity_at IS '最后活跃时间，默认当前时间';
COMMENT ON COLUMN conversations.team_id IS '分配的团队ID，关联teams表';
COMMENT ON COLUMN conversations.campaign_id IS '营销活动ID，关联campaigns表';
COMMENT ON COLUMN conversations.snoozed_until IS '暂停到指定时间';
COMMENT ON COLUMN conversations.custom_attributes IS '自定义属性JSON配置';
COMMENT ON COLUMN conversations.assignee_last_seen_at IS '分配人最后查看时间';
COMMENT ON COLUMN conversations.first_reply_created_at IS '首次回复时间';
COMMENT ON COLUMN conversations.priority IS '对话优先级';
COMMENT ON COLUMN conversations.sla_policy_id IS 'SLA策略ID，关联sla_policies表';
COMMENT ON COLUMN conversations.waiting_since IS '等待开始时间';
COMMENT ON COLUMN conversations.cached_label_list IS '缓存的标签列表';

-- messages 表字段注释
COMMENT ON COLUMN messages.id IS '消息ID，主键，自增';
COMMENT ON COLUMN messages.content IS '消息内容';
COMMENT ON COLUMN messages.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN messages.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN messages.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN messages.message_type IS '消息类型，枚举值';
COMMENT ON COLUMN messages.created_at IS '消息创建时间';
COMMENT ON COLUMN messages.updated_at IS '消息更新时间';
COMMENT ON COLUMN messages.private IS '是否私有消息，默认false';
COMMENT ON COLUMN messages.status IS '消息状态，0=默认';
COMMENT ON COLUMN messages.source_id IS '来源标识';
COMMENT ON COLUMN messages.content_type IS '内容类型，0=文本';
COMMENT ON COLUMN messages.content_attributes IS '内容属性JSON配置';
COMMENT ON COLUMN messages.sender_type IS '发送者类型，多态关联';
COMMENT ON COLUMN messages.sender_id IS '发送者ID，多态关联';
COMMENT ON COLUMN messages.external_source_ids IS '外部来源ID映射JSON';
COMMENT ON COLUMN messages.additional_attributes IS '额外属性JSON配置';
COMMENT ON COLUMN messages.processed_message_content IS '处理后的消息内容';
COMMENT ON COLUMN messages.sentiment IS '情感分析结果JSON';

-- attachments 表字段注释
COMMENT ON COLUMN attachments.id IS '附件ID，主键，自增';
COMMENT ON COLUMN attachments.file_type IS '文件类型，0=默认';
COMMENT ON COLUMN attachments.external_url IS '外部URL链接';
COMMENT ON COLUMN attachments.coordinates_lat IS '纬度坐标，默认0.0';
COMMENT ON COLUMN attachments.coordinates_long IS '经度坐标，默认0.0';
COMMENT ON COLUMN attachments.message_id IS '关联消息ID，关联messages表';
COMMENT ON COLUMN attachments.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN attachments.created_at IS '附件创建时间';
COMMENT ON COLUMN attachments.updated_at IS '附件更新时间';
COMMENT ON COLUMN attachments.fallback_title IS '备用标题';
COMMENT ON COLUMN attachments.extension IS '文件扩展名';
COMMENT ON COLUMN attachments.meta IS '附件元数据JSON';

-- csat_survey_responses 表字段注释
COMMENT ON COLUMN csat_survey_responses.id IS 'CSAT调研ID，主键，自增';
COMMENT ON COLUMN csat_survey_responses.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN csat_survey_responses.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN csat_survey_responses.message_id IS '消息ID，关联messages表';
COMMENT ON COLUMN csat_survey_responses.rating IS '评分，整数值';
COMMENT ON COLUMN csat_survey_responses.feedback_message IS '反馈消息内容';
COMMENT ON COLUMN csat_survey_responses.contact_id IS '客户ID，关联contacts表';
COMMENT ON COLUMN csat_survey_responses.assigned_agent_id IS '分配坐席ID，关联users表';
COMMENT ON COLUMN csat_survey_responses.created_at IS '调研创建时间';
COMMENT ON COLUMN csat_survey_responses.updated_at IS '调研更新时间';

-- mentions 表字段注释
COMMENT ON COLUMN mentions.id IS '提及ID，主键，自增';
COMMENT ON COLUMN mentions.user_id IS '被提及用户ID，关联users表';
COMMENT ON COLUMN mentions.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN mentions.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN mentions.mentioned_at IS '提及时间';
COMMENT ON COLUMN mentions.created_at IS '记录创建时间';
COMMENT ON COLUMN mentions.updated_at IS '记录更新时间';

-- active_storage_attachments 表字段注释
COMMENT ON COLUMN active_storage_attachments.id IS 'Active Storage附件ID，主键，自增';
COMMENT ON COLUMN active_storage_attachments.name IS '附件名称';
COMMENT ON COLUMN active_storage_attachments.record_type IS '关联记录类型，多态关联';
COMMENT ON COLUMN active_storage_attachments.record_id IS '关联记录ID，多态关联';
COMMENT ON COLUMN active_storage_attachments.blob_id IS '文件Blob ID，关联active_storage_blobs表';
COMMENT ON COLUMN active_storage_attachments.created_at IS '附件关联创建时间';

-- active_storage_blobs 表字段注释
COMMENT ON COLUMN active_storage_blobs.id IS 'Blob ID，主键，自增';
COMMENT ON COLUMN active_storage_blobs.key IS '文件唯一键';
COMMENT ON COLUMN active_storage_blobs.filename IS '文件名';
COMMENT ON COLUMN active_storage_blobs.content_type IS '文件MIME类型';
COMMENT ON COLUMN active_storage_blobs.metadata IS '文件元数据';
COMMENT ON COLUMN active_storage_blobs.byte_size IS '文件大小，字节';
COMMENT ON COLUMN active_storage_blobs.checksum IS '文件校验和';
COMMENT ON COLUMN active_storage_blobs.created_at IS '文件创建时间';
COMMENT ON COLUMN active_storage_blobs.service_name IS '存储服务名称';

-- active_storage_variant_records 表字段注释
COMMENT ON COLUMN active_storage_variant_records.id IS '变体记录ID，主键，自增';
COMMENT ON COLUMN active_storage_variant_records.blob_id IS '原始Blob ID，关联active_storage_blobs表';
COMMENT ON COLUMN active_storage_variant_records.variation_digest IS '变体摘要，用于缓存';

-- =============================================================================
-- 5. 团队协作模块字段注释 (9个表)
-- =============================================================================

-- teams 表字段注释
COMMENT ON COLUMN teams.id IS '团队ID，主键，自增';
COMMENT ON COLUMN teams.name IS '团队名称';
COMMENT ON COLUMN teams.description IS '团队描述';
COMMENT ON COLUMN teams.allow_auto_assign IS '是否允许自动分配';
COMMENT ON COLUMN teams.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN teams.created_at IS '团队创建时间';
COMMENT ON COLUMN teams.updated_at IS '团队更新时间';

-- team_members 表字段注释
COMMENT ON COLUMN team_members.id IS '团队成员ID，主键，自增';
COMMENT ON COLUMN team_members.team_id IS '团队ID，关联teams表';
COMMENT ON COLUMN team_members.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN team_members.created_at IS '成员加入时间';
COMMENT ON COLUMN team_members.updated_at IS '成员更新时间';

-- inbox_members 表字段注释
COMMENT ON COLUMN inbox_members.id IS '收件箱成员ID，主键，自增';
COMMENT ON COLUMN inbox_members.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN inbox_members.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN inbox_members.created_at IS '成员授权时间';
COMMENT ON COLUMN inbox_members.updated_at IS '授权更新时间';

-- assignment_policies 表字段注释
COMMENT ON COLUMN assignment_policies.id IS '分配策略ID，主键，自增';
COMMENT ON COLUMN assignment_policies.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN assignment_policies.name IS '策略名称';
COMMENT ON COLUMN assignment_policies.description IS '策略描述';
COMMENT ON COLUMN assignment_policies.assignment_order IS '分配顺序，0=轮询';
COMMENT ON COLUMN assignment_policies.conversation_priority IS '对话优先级，0=普通';
COMMENT ON COLUMN assignment_policies.fair_distribution_limit IS '公平分配限制，默认100';
COMMENT ON COLUMN assignment_policies.fair_distribution_window IS '公平分配时间窗口，默认3600秒';
COMMENT ON COLUMN assignment_policies.enabled IS '是否启用，默认true';
COMMENT ON COLUMN assignment_policies.created_at IS '策略创建时间';
COMMENT ON COLUMN assignment_policies.updated_at IS '策略更新时间';

-- inbox_assignment_policies 表字段注释
COMMENT ON COLUMN inbox_assignment_policies.id IS '收件箱策略关联ID，主键，自增';
COMMENT ON COLUMN inbox_assignment_policies.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN inbox_assignment_policies.assignment_policy_id IS '分配策略ID，关联assignment_policies表';
COMMENT ON COLUMN inbox_assignment_policies.created_at IS '关联创建时间';
COMMENT ON COLUMN inbox_assignment_policies.updated_at IS '关联更新时间';

-- agent_capacity_policies 表字段注释
COMMENT ON COLUMN agent_capacity_policies.id IS '坐席容量策略ID，主键，自增';
COMMENT ON COLUMN agent_capacity_policies.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN agent_capacity_policies.name IS '策略名称';
COMMENT ON COLUMN agent_capacity_policies.description IS '策略描述';
COMMENT ON COLUMN agent_capacity_policies.exclusion_rules IS '排除规则JSON配置';
COMMENT ON COLUMN agent_capacity_policies.created_at IS '策略创建时间';
COMMENT ON COLUMN agent_capacity_policies.updated_at IS '策略更新时间';

-- inbox_capacity_limits 表字段注释
COMMENT ON COLUMN inbox_capacity_limits.id IS '收件箱容量限制ID，主键，自增';
COMMENT ON COLUMN inbox_capacity_limits.agent_capacity_policy_id IS '坐席容量策略ID，关联agent_capacity_policies表';
COMMENT ON COLUMN inbox_capacity_limits.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN inbox_capacity_limits.conversation_limit IS '对话数量限制';
COMMENT ON COLUMN inbox_capacity_limits.created_at IS '限制创建时间';
COMMENT ON COLUMN inbox_capacity_limits.updated_at IS '限制更新时间';

-- leaves 表字段注释
COMMENT ON COLUMN leaves.id IS '请假记录ID，主键，自增';
COMMENT ON COLUMN leaves.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN leaves.user_id IS '请假用户ID，关联users表';
COMMENT ON COLUMN leaves.start_date IS '请假开始日期';
COMMENT ON COLUMN leaves.end_date IS '请假结束日期';
COMMENT ON COLUMN leaves.leave_type IS '请假类型，0=年假';
COMMENT ON COLUMN leaves.status IS '请假状态，0=待审批';
COMMENT ON COLUMN leaves.reason IS '请假原因';
COMMENT ON COLUMN leaves.approved_by_id IS '审批人ID，关联users表';
COMMENT ON COLUMN leaves.approved_at IS '审批时间';
COMMENT ON COLUMN leaves.created_at IS '请假申请时间';
COMMENT ON COLUMN leaves.updated_at IS '记录更新时间';

-- working_hours 表字段注释
COMMENT ON COLUMN working_hours.id IS '工作时间ID，主键，自增';
COMMENT ON COLUMN working_hours.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN working_hours.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN working_hours.day_of_week IS '星期几，0=星期日';
COMMENT ON COLUMN working_hours.closed_all_day IS '是否全天关闭';
COMMENT ON COLUMN working_hours.open_hour IS '开始营业小时';
COMMENT ON COLUMN working_hours.open_minutes IS '开始营业分钟';
COMMENT ON COLUMN working_hours.close_hour IS '结束营业小时';
COMMENT ON COLUMN working_hours.close_minutes IS '结束营业分钟';
COMMENT ON COLUMN working_hours.created_at IS '工作时间创建时间';
COMMENT ON COLUMN working_hours.updated_at IS '工作时间更新时间';
COMMENT ON COLUMN working_hours.open_all_day IS '是否全天开放';

-- =============================================================================
-- 6. 知识库模块字段注释 (7个表) - 层级结构支持AI搜索
-- =============================================================================

-- portals 表字段注释
COMMENT ON COLUMN portals.id IS '知识库门户ID，主键，自增';
COMMENT ON COLUMN portals.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN portals.name IS '门户名称';
COMMENT ON COLUMN portals.slug IS '门户URL段标识';
COMMENT ON COLUMN portals.custom_domain IS '自定义域名';
COMMENT ON COLUMN portals.color IS '门户主题颜色';
COMMENT ON COLUMN portals.homepage_link IS '主页链接';
COMMENT ON COLUMN portals.page_title IS '页面标题';
COMMENT ON COLUMN portals.header_text IS '头部文本内容';
COMMENT ON COLUMN portals.created_at IS '门户创建时间';
COMMENT ON COLUMN portals.updated_at IS '门户更新时间';
COMMENT ON COLUMN portals.config IS '门户配置JSON，包含语言设置';
COMMENT ON COLUMN portals.archived IS '是否已归档，默认false';
COMMENT ON COLUMN portals.channel_web_widget_id IS '关联网站组件ID';
COMMENT ON COLUMN portals.ssl_settings IS 'SSL设置配置JSON';

-- categories 表字段注释
COMMENT ON COLUMN categories.id IS '分类ID，主键，自增';
COMMENT ON COLUMN categories.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN categories.portal_id IS '门户ID，关联portals表';
COMMENT ON COLUMN categories.name IS '分类名称';
COMMENT ON COLUMN categories.description IS '分类描述';
COMMENT ON COLUMN categories.position IS '排序位置';
COMMENT ON COLUMN categories.created_at IS '分类创建时间';
COMMENT ON COLUMN categories.updated_at IS '分类更新时间';
COMMENT ON COLUMN categories.locale IS '语言区域，默认en';
COMMENT ON COLUMN categories.slug IS '分类URL段标识';
COMMENT ON COLUMN categories.parent_category_id IS '父分类ID，支持多级分类';
COMMENT ON COLUMN categories.associated_category_id IS '关联分类ID';
COMMENT ON COLUMN categories.icon IS '分类图标，默认空';

-- folders 表字段注释
COMMENT ON COLUMN folders.id IS '文件夹ID，主键，自增';
COMMENT ON COLUMN folders.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN folders.category_id IS '分类ID，关联categories表';
COMMENT ON COLUMN folders.name IS '文件夹名称';
COMMENT ON COLUMN folders.created_at IS '文件夹创建时间';
COMMENT ON COLUMN folders.updated_at IS '文件夹更新时间';

-- articles 表字段注释
COMMENT ON COLUMN articles.id IS '文章ID，主键，自增';
COMMENT ON COLUMN articles.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN articles.portal_id IS '门户ID，关联portals表';
COMMENT ON COLUMN articles.category_id IS '分类ID，关联categories表';
COMMENT ON COLUMN articles.folder_id IS '文件夹ID，关联folders表';
COMMENT ON COLUMN articles.title IS '文章标题';
COMMENT ON COLUMN articles.description IS '文章描述';
COMMENT ON COLUMN articles.content IS '文章内容';
COMMENT ON COLUMN articles.status IS '文章状态，枚举值';
COMMENT ON COLUMN articles.views IS '文章浏览量';
COMMENT ON COLUMN articles.created_at IS '文章创建时间';
COMMENT ON COLUMN articles.updated_at IS '文章更新时间';
COMMENT ON COLUMN articles.author_id IS '作者ID，关联users表';
COMMENT ON COLUMN articles.associated_article_id IS '关联文章ID';
COMMENT ON COLUMN articles.meta IS '文章元数据JSON配置';
COMMENT ON COLUMN articles.slug IS '文章URL段标识';
COMMENT ON COLUMN articles.position IS '文章排序位置';
COMMENT ON COLUMN articles.locale IS '语言区域，默认en';

-- article_embeddings 表字段注释
COMMENT ON COLUMN article_embeddings.id IS '文章向量ID，主键，自增';
COMMENT ON COLUMN article_embeddings.article_id IS '文章ID，关联articles表';
COMMENT ON COLUMN article_embeddings.term IS '向量化的文本内容';
COMMENT ON COLUMN article_embeddings.embedding IS '向量数据，1536维度';
COMMENT ON COLUMN article_embeddings.created_at IS '向量创建时间';
COMMENT ON COLUMN article_embeddings.updated_at IS '向量更新时间';

-- portals_members 表字段注释
COMMENT ON COLUMN portals_members.portal_id IS '门户ID，关联portals表';
COMMENT ON COLUMN portals_members.user_id IS '用户ID，关联users表';

-- related_categories 表字段注释
COMMENT ON COLUMN related_categories.id IS '相关分类ID，主键，自增';
COMMENT ON COLUMN related_categories.category_id IS '分类ID，关联categories表';
COMMENT ON COLUMN related_categories.related_category_id IS '关联的分类ID，关联categories表';
COMMENT ON COLUMN related_categories.created_at IS '关联创建时间';
COMMENT ON COLUMN related_categories.updated_at IS '关联更新时间';

-- =============================================================================
-- 7. AI功能模块字段注释 (9个表) - AI客服和智能辅助功能
-- =============================================================================

-- captain_assistants 表字段注释
COMMENT ON COLUMN captain_assistants.id IS 'AI助手ID，主键，自增';
COMMENT ON COLUMN captain_assistants.name IS 'AI助手名称';
COMMENT ON COLUMN captain_assistants.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN captain_assistants.description IS 'AI助手描述';
COMMENT ON COLUMN captain_assistants.created_at IS 'AI助手创建时间';
COMMENT ON COLUMN captain_assistants.updated_at IS 'AI助手更新时间';
COMMENT ON COLUMN captain_assistants.config IS 'AI助手配置JSON';
COMMENT ON COLUMN captain_assistants.response_guidelines IS '响应指导原则JSON数组';
COMMENT ON COLUMN captain_assistants.guardrails IS '安全防护规则JSON数组';

-- captain_documents 表字段注释
COMMENT ON COLUMN captain_documents.id IS 'AI文档ID，主键，自增';
COMMENT ON COLUMN captain_documents.name IS '文档名称';
COMMENT ON COLUMN captain_documents.external_link IS '外部文档链接';
COMMENT ON COLUMN captain_documents.content IS '文档内容';
COMMENT ON COLUMN captain_documents.assistant_id IS '关联AI助手ID，关联captain_assistants表';
COMMENT ON COLUMN captain_documents.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN captain_documents.created_at IS '文档创建时间';
COMMENT ON COLUMN captain_documents.updated_at IS '文档更新时间';
COMMENT ON COLUMN captain_documents.status IS '文档状态，0=草稿';

-- captain_assistant_responses 表字段注释
COMMENT ON COLUMN captain_assistant_responses.id IS 'AI响应ID，主键，自增';
COMMENT ON COLUMN captain_assistant_responses.question IS '问题内容';
COMMENT ON COLUMN captain_assistant_responses.answer IS 'AI回答内容';
COMMENT ON COLUMN captain_assistant_responses.embedding IS '问题向量数据，1536维度';
COMMENT ON COLUMN captain_assistant_responses.assistant_id IS '关联AI助手ID，关联captain_assistants表';
COMMENT ON COLUMN captain_assistant_responses.documentable_id IS '关联文档ID，多态关联';
COMMENT ON COLUMN captain_assistant_responses.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN captain_assistant_responses.created_at IS '响应创建时间';
COMMENT ON COLUMN captain_assistant_responses.updated_at IS '响应更新时间';
COMMENT ON COLUMN captain_assistant_responses.status IS '响应状态，1=激活';
COMMENT ON COLUMN captain_assistant_responses.documentable_type IS '关联文档类型，多态关联';

-- captain_scenarios 表字段注释
COMMENT ON COLUMN captain_scenarios.id IS 'AI场景ID，主键，自增';
COMMENT ON COLUMN captain_scenarios.title IS '场景标题';
COMMENT ON COLUMN captain_scenarios.description IS '场景描述';
COMMENT ON COLUMN captain_scenarios.instruction IS '场景指令';
COMMENT ON COLUMN captain_scenarios.tools IS '可用工具JSON数组';
COMMENT ON COLUMN captain_scenarios.enabled IS '是否启用，默认true';
COMMENT ON COLUMN captain_scenarios.assistant_id IS '关联AI助手ID，关联captain_assistants表';
COMMENT ON COLUMN captain_scenarios.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN captain_scenarios.created_at IS '场景创建时间';
COMMENT ON COLUMN captain_scenarios.updated_at IS '场景更新时间';

-- captain_inboxes 表字段注释
COMMENT ON COLUMN captain_inboxes.id IS 'AI收件箱关联ID，主键，自增';
COMMENT ON COLUMN captain_inboxes.captain_assistant_id IS 'AI助手ID，关联captain_assistants表';
COMMENT ON COLUMN captain_inboxes.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN captain_inboxes.created_at IS '关联创建时间';
COMMENT ON COLUMN captain_inboxes.updated_at IS '关联更新时间';

-- copilot_threads 表字段注释
COMMENT ON COLUMN copilot_threads.id IS 'Copilot线程ID，主键，自增';
COMMENT ON COLUMN copilot_threads.title IS '线程标题';
COMMENT ON COLUMN copilot_threads.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN copilot_threads.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN copilot_threads.created_at IS '线程创建时间';
COMMENT ON COLUMN copilot_threads.updated_at IS '线程更新时间';
COMMENT ON COLUMN copilot_threads.assistant_id IS '关联助手ID';

-- copilot_messages 表字段注释
COMMENT ON COLUMN copilot_messages.id IS 'Copilot消息ID，主键，自增';
COMMENT ON COLUMN copilot_messages.copilot_thread_id IS 'Copilot线程ID，关联copilot_threads表';
COMMENT ON COLUMN copilot_messages.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN copilot_messages.message IS '消息内容JSON';
COMMENT ON COLUMN copilot_messages.created_at IS '消息创建时间';
COMMENT ON COLUMN copilot_messages.updated_at IS '消息更新时间';
COMMENT ON COLUMN copilot_messages.message_type IS '消息类型，0=默认';

-- agent_bots 表字段注释
COMMENT ON COLUMN agent_bots.id IS '智能机器人ID，主键，自增';
COMMENT ON COLUMN agent_bots.name IS '机器人名称';
COMMENT ON COLUMN agent_bots.description IS '机器人描述';
COMMENT ON COLUMN agent_bots.outgoing_url IS '外部Webhook URL';
COMMENT ON COLUMN agent_bots.created_at IS '机器人创建时间';
COMMENT ON COLUMN agent_bots.updated_at IS '机器人更新时间';
COMMENT ON COLUMN agent_bots.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN agent_bots.bot_type IS '机器人类型，0=默认';
COMMENT ON COLUMN agent_bots.bot_config IS '机器人配置JSON';

-- agent_bot_inboxes 表字段注释
COMMENT ON COLUMN agent_bot_inboxes.id IS '机器人收件箱关联ID，主键，自增';
COMMENT ON COLUMN agent_bot_inboxes.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN agent_bot_inboxes.agent_bot_id IS '机器人ID，关联agent_bots表';
COMMENT ON COLUMN agent_bot_inboxes.status IS '激活状态，0=默认';
COMMENT ON COLUMN agent_bot_inboxes.created_at IS '关联创建时间';
COMMENT ON COLUMN agent_bot_inboxes.updated_at IS '关联更新时间';
COMMENT ON COLUMN agent_bot_inboxes.account_id IS '所属账户ID';

-- =============================================================================
-- 8. 自动化模块字段注释 (6个表) - 业务流程自动化和规则引擎
-- =============================================================================

-- automation_rules 表字段注释
COMMENT ON COLUMN automation_rules.id IS '自动化规则ID，主键，自增';
COMMENT ON COLUMN automation_rules.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN automation_rules.name IS '规则名称';
COMMENT ON COLUMN automation_rules.description IS '规则描述';
COMMENT ON COLUMN automation_rules.event_name IS '触发事件名称';
COMMENT ON COLUMN automation_rules.conditions IS '触发条件JSON配置';
COMMENT ON COLUMN automation_rules.actions IS '执行动作JSON配置';
COMMENT ON COLUMN automation_rules.created_at IS '规则创建时间';
COMMENT ON COLUMN automation_rules.updated_at IS '规则更新时间';
COMMENT ON COLUMN automation_rules.active IS '是否激活，默认true';

-- sla_policies 表字段注释
COMMENT ON COLUMN sla_policies.id IS 'SLA策略ID，主键，自增';
COMMENT ON COLUMN sla_policies.name IS 'SLA策略名称';
COMMENT ON COLUMN sla_policies.first_response_time_threshold IS '首次响应时间阈值';
COMMENT ON COLUMN sla_policies.next_response_time_threshold IS '后续响应时间阈值';
COMMENT ON COLUMN sla_policies.only_during_business_hours IS '是否仅在工作时间内生效';
COMMENT ON COLUMN sla_policies.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN sla_policies.created_at IS 'SLA策略创建时间';
COMMENT ON COLUMN sla_policies.updated_at IS 'SLA策略更新时间';
COMMENT ON COLUMN sla_policies.description IS 'SLA策略描述';
COMMENT ON COLUMN sla_policies.resolution_time_threshold IS '解决时间阈值';

-- applied_slas 表字段注释
COMMENT ON COLUMN applied_slas.id IS '应用SLA记录ID，主键，自增';
COMMENT ON COLUMN applied_slas.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN applied_slas.sla_policy_id IS 'SLA策略ID，关联sla_policies表';
COMMENT ON COLUMN applied_slas.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN applied_slas.created_at IS 'SLA应用时间';
COMMENT ON COLUMN applied_slas.updated_at IS 'SLA更新时间';
COMMENT ON COLUMN applied_slas.sla_status IS 'SLA状态，0=默认';

-- sla_events 表字段注释
COMMENT ON COLUMN sla_events.id IS 'SLA事件ID，主键，自增';
COMMENT ON COLUMN sla_events.applied_sla_id IS '应用SLA记录ID，关联applied_slas表';
COMMENT ON COLUMN sla_events.conversation_id IS '对话ID，关联conversations表';
COMMENT ON COLUMN sla_events.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN sla_events.sla_policy_id IS 'SLA策略ID，关联sla_policies表';
COMMENT ON COLUMN sla_events.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN sla_events.event_type IS '事件类型';
COMMENT ON COLUMN sla_events.meta IS '事件元数据JSON';
COMMENT ON COLUMN sla_events.created_at IS '事件创建时间';
COMMENT ON COLUMN sla_events.updated_at IS '事件更新时间';

-- campaigns 表字段注释
COMMENT ON COLUMN campaigns.id IS '营销活动ID，主键，自增';
COMMENT ON COLUMN campaigns.display_id IS '显示ID，用户友好的序列号';
COMMENT ON COLUMN campaigns.title IS '活动标题';
COMMENT ON COLUMN campaigns.description IS '活动描述';
COMMENT ON COLUMN campaigns.message IS '活动消息内容';
COMMENT ON COLUMN campaigns.sender_id IS '发送人ID';
COMMENT ON COLUMN campaigns.enabled IS '是否启用，默认true';
COMMENT ON COLUMN campaigns.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN campaigns.inbox_id IS '收件箱ID，关联inboxes表';
COMMENT ON COLUMN campaigns.trigger_rules IS '触发规则JSON配置';
COMMENT ON COLUMN campaigns.created_at IS '活动创建时间';
COMMENT ON COLUMN campaigns.updated_at IS '活动更新时间';
COMMENT ON COLUMN campaigns.campaign_type IS '活动类型，0=默认';
COMMENT ON COLUMN campaigns.campaign_status IS '活动状态，0=暂停，1=运行中，2=已完成';
COMMENT ON COLUMN campaigns.audience IS '目标受众JSON数组';
COMMENT ON COLUMN campaigns.scheduled_at IS '计划执行时间';
COMMENT ON COLUMN campaigns.trigger_only_during_business_hours IS '是否仅在工作时间触发';
COMMENT ON COLUMN campaigns.template_params IS '模板参数JSON配置';

-- macros 表字段注释
COMMENT ON COLUMN macros.id IS '宏命令ID，主键，自增';
COMMENT ON COLUMN macros.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN macros.name IS '宏命令名称';
COMMENT ON COLUMN macros.visibility IS '可见性，0=默认';
COMMENT ON COLUMN macros.created_by_id IS '创建人ID，关联users表';
COMMENT ON COLUMN macros.updated_by_id IS '更新人ID，关联users表';
COMMENT ON COLUMN macros.actions IS '宏动作JSON配置';
COMMENT ON COLUMN macros.created_at IS '宏命令创建时间';
COMMENT ON COLUMN macros.updated_at IS '宏命令更新时间';

-- =============================================================================
-- 9. 权限角色模块字段注释 (5个表) - 细粒度权限控制
-- =============================================================================

-- custom_role_templates 表字段注释
COMMENT ON COLUMN custom_role_templates.id IS '角色模板ID，主键，自增';
COMMENT ON COLUMN custom_role_templates.name IS '模板名称';
COMMENT ON COLUMN custom_role_templates.description IS '模板描述';
COMMENT ON COLUMN custom_role_templates.permissions IS '权限列表数组';
COMMENT ON COLUMN custom_role_templates.is_system IS '是否系统模板';
COMMENT ON COLUMN custom_role_templates.category IS '模板分类';
COMMENT ON COLUMN custom_role_templates.created_at IS '模板创建时间';
COMMENT ON COLUMN custom_role_templates.updated_at IS '模板更新时间';

-- custom_role_audit_logs 表字段注释
COMMENT ON COLUMN custom_role_audit_logs.id IS '角色审计日志ID，主键，自增';
COMMENT ON COLUMN custom_role_audit_logs.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN custom_role_audit_logs.custom_role_id IS '自定义角色ID，关联custom_roles表';
COMMENT ON COLUMN custom_role_audit_logs.user_id IS '操作用户ID，关联users表';
COMMENT ON COLUMN custom_role_audit_logs.target_user_id IS '目标用户ID，关联users表';
COMMENT ON COLUMN custom_role_audit_logs.action IS '操作类型';
COMMENT ON COLUMN custom_role_audit_logs.change_data IS '变更数据JSON';
COMMENT ON COLUMN custom_role_audit_logs.ip_address IS '操作IP地址';
COMMENT ON COLUMN custom_role_audit_logs.user_agent IS '用户代理字符串';
COMMENT ON COLUMN custom_role_audit_logs.created_at IS '日志创建时间';
COMMENT ON COLUMN custom_role_audit_logs.updated_at IS '日志更新时间';

-- platform_apps 表字段注释
COMMENT ON COLUMN platform_apps.id IS '平台应用ID，主键，自增';
COMMENT ON COLUMN platform_apps.name IS '应用名称';
COMMENT ON COLUMN platform_apps.created_at IS '应用创建时间';
COMMENT ON COLUMN platform_apps.updated_at IS '应用更新时间';

-- platform_app_permissibles 表字段注释
COMMENT ON COLUMN platform_app_permissibles.id IS '应用权限ID，主键，自增';
COMMENT ON COLUMN platform_app_permissibles.platform_app_id IS '平台应用ID，关联platform_apps表';
COMMENT ON COLUMN platform_app_permissibles.permissible_type IS '权限对象类型，多态关联';
COMMENT ON COLUMN platform_app_permissibles.permissible_id IS '权限对象ID，多态关联';
COMMENT ON COLUMN platform_app_permissibles.created_at IS '权限创建时间';
COMMENT ON COLUMN platform_app_permissibles.updated_at IS '权限更新时间';

-- dashboard_apps 表字段注释
COMMENT ON COLUMN dashboard_apps.id IS '仪表板应用ID，主键，自增';
COMMENT ON COLUMN dashboard_apps.title IS '应用标题';
COMMENT ON COLUMN dashboard_apps.content IS '应用内容JSON数组';
COMMENT ON COLUMN dashboard_apps.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN dashboard_apps.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN dashboard_apps.created_at IS '应用创建时间';
COMMENT ON COLUMN dashboard_apps.updated_at IS '应用更新时间';

-- =============================================================================
-- 10. 系统功能模块字段注释 (24个表) - 系统监控、通知、标签、模板等功能
-- =============================================================================

-- audits 表字段注释
COMMENT ON COLUMN audits.id IS '审计记录ID，主键，自增';
COMMENT ON COLUMN audits.auditable_id IS '被审计对象ID';
COMMENT ON COLUMN audits.auditable_type IS '被审计对象类型';
COMMENT ON COLUMN audits.associated_id IS '关联对象ID';
COMMENT ON COLUMN audits.associated_type IS '关联对象类型';
COMMENT ON COLUMN audits.user_id IS '操作用户ID';
COMMENT ON COLUMN audits.user_type IS '用户类型';
COMMENT ON COLUMN audits.username IS '用户名';
COMMENT ON COLUMN audits.action IS '操作动作';
COMMENT ON COLUMN audits.audited_changes IS '审计变更JSON';
COMMENT ON COLUMN audits.version IS '版本号，默认0';
COMMENT ON COLUMN audits.comment IS '注释';
COMMENT ON COLUMN audits.remote_address IS '远程IP地址';
COMMENT ON COLUMN audits.request_uuid IS '请求UUID';
COMMENT ON COLUMN audits.created_at IS '审计记录创建时间';

-- reporting_events 表字段注释
COMMENT ON COLUMN reporting_events.id IS '报告事件ID，主键，自增';
COMMENT ON COLUMN reporting_events.name IS '事件名称';
COMMENT ON COLUMN reporting_events.value IS '事件值';
COMMENT ON COLUMN reporting_events.account_id IS '所属账户ID';
COMMENT ON COLUMN reporting_events.inbox_id IS '收件箱ID';
COMMENT ON COLUMN reporting_events.user_id IS '用户ID';
COMMENT ON COLUMN reporting_events.conversation_id IS '对话ID';
COMMENT ON COLUMN reporting_events.created_at IS '事件创建时间';
COMMENT ON COLUMN reporting_events.updated_at IS '事件更新时间';
COMMENT ON COLUMN reporting_events.value_in_business_hours IS '工作时间内的事件值';
COMMENT ON COLUMN reporting_events.event_start_time IS '事件开始时间';
COMMENT ON COLUMN reporting_events.event_end_time IS '事件结束时间';

-- notifications 表字段注释
COMMENT ON COLUMN notifications.id IS '通知ID，主键，自增';
COMMENT ON COLUMN notifications.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN notifications.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN notifications.notification_type IS '通知类型';
COMMENT ON COLUMN notifications.primary_actor_type IS '主要参与者类型';
COMMENT ON COLUMN notifications.primary_actor_id IS '主要参与者ID';
COMMENT ON COLUMN notifications.secondary_actor_type IS '次要参与者类型';
COMMENT ON COLUMN notifications.secondary_actor_id IS '次要参与者ID';
COMMENT ON COLUMN notifications.read_at IS '已读时间';
COMMENT ON COLUMN notifications.created_at IS '通知创建时间';
COMMENT ON COLUMN notifications.updated_at IS '通知更新时间';
COMMENT ON COLUMN notifications.snoozed_until IS '暂停到指定时间';
COMMENT ON COLUMN notifications.last_activity_at IS '最后活跃时间，默认当前时间';
COMMENT ON COLUMN notifications.meta IS '通知元数据JSON';

-- notification_settings 表字段注释
COMMENT ON COLUMN notification_settings.id IS '通知设置ID，主键，自增';
COMMENT ON COLUMN notification_settings.account_id IS '账户ID';
COMMENT ON COLUMN notification_settings.user_id IS '用户ID';
COMMENT ON COLUMN notification_settings.email_flags IS '邮件通知标志位，默认0';
COMMENT ON COLUMN notification_settings.created_at IS '设置创建时间';
COMMENT ON COLUMN notification_settings.updated_at IS '设置更新时间';
COMMENT ON COLUMN notification_settings.push_flags IS '推送通知标志位，默认0';

-- notification_subscriptions 表字段注释
COMMENT ON COLUMN notification_subscriptions.id IS '通知订阅ID，主键，自增';
COMMENT ON COLUMN notification_subscriptions.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN notification_subscriptions.subscription_type IS '订阅类型';
COMMENT ON COLUMN notification_subscriptions.subscription_attributes IS '订阅属性JSON配置';
COMMENT ON COLUMN notification_subscriptions.created_at IS '订阅创建时间';
COMMENT ON COLUMN notification_subscriptions.updated_at IS '订阅更新时间';
COMMENT ON COLUMN notification_subscriptions.identifier IS '订阅标识符';

-- labels 表字段注释
COMMENT ON COLUMN labels.id IS '标签ID，主键，自增';
COMMENT ON COLUMN labels.title IS '标签标题';
COMMENT ON COLUMN labels.description IS '标签描述';
COMMENT ON COLUMN labels.color IS '标签颜色，默认#1f93ff';
COMMENT ON COLUMN labels.show_on_sidebar IS '是否在侧边栏显示';
COMMENT ON COLUMN labels.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN labels.created_at IS '标签创建时间';
COMMENT ON COLUMN labels.updated_at IS '标签更新时间';

-- tags 表字段注释
COMMENT ON COLUMN tags.id IS '全局标签ID，主键，自增';
COMMENT ON COLUMN tags.name IS '标签名称';
COMMENT ON COLUMN tags.taggings_count IS '标签使用次数，默认0';

-- taggings 表字段注释
COMMENT ON COLUMN taggings.id IS '标签关联ID，主键，自增';
COMMENT ON COLUMN taggings.tag_id IS '标签ID，关联tags表';
COMMENT ON COLUMN taggings.taggable_type IS '被标记对象类型，多态关联';
COMMENT ON COLUMN taggings.taggable_id IS '被标记对象ID，多态关联';
COMMENT ON COLUMN taggings.tagger_type IS '标记者类型，多态关联';
COMMENT ON COLUMN taggings.tagger_id IS '标记者ID，多态关联';
COMMENT ON COLUMN taggings.context IS '标记上下文';
COMMENT ON COLUMN taggings.created_at IS '标记创建时间';

-- custom_attribute_definitions 表字段注释
COMMENT ON COLUMN custom_attribute_definitions.id IS '自定义属性定义ID，主键，自增';
COMMENT ON COLUMN custom_attribute_definitions.attribute_display_name IS '属性显示名称';
COMMENT ON COLUMN custom_attribute_definitions.attribute_key IS '属性键';
COMMENT ON COLUMN custom_attribute_definitions.attribute_display_type IS '属性显示类型，0=默认';
COMMENT ON COLUMN custom_attribute_definitions.default_value IS '默认值';
COMMENT ON COLUMN custom_attribute_definitions.attribute_model IS '属性模型，0=默认';
COMMENT ON COLUMN custom_attribute_definitions.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN custom_attribute_definitions.created_at IS '定义创建时间';
COMMENT ON COLUMN custom_attribute_definitions.updated_at IS '定义更新时间';
COMMENT ON COLUMN custom_attribute_definitions.attribute_description IS '属性描述';
COMMENT ON COLUMN custom_attribute_definitions.attribute_values IS '属性值JSON数组';
COMMENT ON COLUMN custom_attribute_definitions.regex_pattern IS '正则表达式模式';
COMMENT ON COLUMN custom_attribute_definitions.regex_cue IS '正则表达式提示';

-- custom_filters 表字段注释
COMMENT ON COLUMN custom_filters.id IS '自定义过滤器ID，主键，自增';
COMMENT ON COLUMN custom_filters.name IS '过滤器名称';
COMMENT ON COLUMN custom_filters.filter_type IS '过滤器类型，0=默认';
COMMENT ON COLUMN custom_filters.query IS '查询条件JSON配置';
COMMENT ON COLUMN custom_filters.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN custom_filters.user_id IS '用户ID，关联users表';
COMMENT ON COLUMN custom_filters.created_at IS '过滤器创建时间';
COMMENT ON COLUMN custom_filters.updated_at IS '过滤器更新时间';

-- canned_responses 表字段注释
COMMENT ON COLUMN canned_responses.id IS '快捷回复ID，主键，自增';
COMMENT ON COLUMN canned_responses.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN canned_responses.short_code IS '快捷代码';
COMMENT ON COLUMN canned_responses.content IS '回复内容';
COMMENT ON COLUMN canned_responses.created_at IS '创建时间';
COMMENT ON COLUMN canned_responses.updated_at IS '更新时间';

-- email_templates 表字段注释
COMMENT ON COLUMN email_templates.id IS '邮件模板ID，主键，自增';
COMMENT ON COLUMN email_templates.name IS '模板名称';
COMMENT ON COLUMN email_templates.body IS '邮件正文';
COMMENT ON COLUMN email_templates.account_id IS '账户ID';
COMMENT ON COLUMN email_templates.template_type IS '模板类型，1=默认';
COMMENT ON COLUMN email_templates.locale IS '语言区域，0=默认';
COMMENT ON COLUMN email_templates.created_at IS '模板创建时间';
COMMENT ON COLUMN email_templates.updated_at IS '模板更新时间';

-- webhooks 表字段注释
COMMENT ON COLUMN webhooks.id IS 'Webhook ID，主键，自增';
COMMENT ON COLUMN webhooks.account_id IS '账户ID';
COMMENT ON COLUMN webhooks.inbox_id IS '收件箱ID';
COMMENT ON COLUMN webhooks.url IS 'Webhook URL地址';
COMMENT ON COLUMN webhooks.created_at IS 'Webhook创建时间';
COMMENT ON COLUMN webhooks.updated_at IS 'Webhook更新时间';
COMMENT ON COLUMN webhooks.webhook_type IS 'Webhook类型，0=默认';
COMMENT ON COLUMN webhooks.subscriptions IS '订阅事件JSON数组';

-- integrations_hooks 表字段注释
COMMENT ON COLUMN integrations_hooks.id IS '集成钩子ID，主键，自增';
COMMENT ON COLUMN integrations_hooks.status IS '钩子状态，1=默认';
COMMENT ON COLUMN integrations_hooks.inbox_id IS '收件箱ID';
COMMENT ON COLUMN integrations_hooks.account_id IS '账户ID';
COMMENT ON COLUMN integrations_hooks.app_id IS '应用ID';
COMMENT ON COLUMN integrations_hooks.hook_type IS '钩子类型，0=默认';
COMMENT ON COLUMN integrations_hooks.reference_id IS '参考ID';
COMMENT ON COLUMN integrations_hooks.access_token IS '访问令牌';
COMMENT ON COLUMN integrations_hooks.created_at IS '钩子创建时间';
COMMENT ON COLUMN integrations_hooks.updated_at IS '钩子更新时间';
COMMENT ON COLUMN integrations_hooks.settings IS '钩子设置JSON配置';

-- telegram_bots 表字段注释
COMMENT ON COLUMN telegram_bots.id IS 'Telegram机器人ID，主键，自增';
COMMENT ON COLUMN telegram_bots.name IS '机器人名称';
COMMENT ON COLUMN telegram_bots.auth_key IS '认证密钥';
COMMENT ON COLUMN telegram_bots.account_id IS '账户ID';
COMMENT ON COLUMN telegram_bots.created_at IS '机器人创建时间';
COMMENT ON COLUMN telegram_bots.updated_at IS '机器人更新时间';

-- installation_configs 表字段注释
COMMENT ON COLUMN installation_configs.id IS '安装配置ID，主键，自增';
COMMENT ON COLUMN installation_configs.name IS '配置名称';
COMMENT ON COLUMN installation_configs.serialized_value IS '序列化配置值JSON';
COMMENT ON COLUMN installation_configs.created_at IS '配置创建时间';
COMMENT ON COLUMN installation_configs.updated_at IS '配置更新时间';
COMMENT ON COLUMN installation_configs.locked IS '是否锁定，默认true';

-- data_imports 表字段注释
COMMENT ON COLUMN data_imports.id IS '数据导入ID，主键，自增';
COMMENT ON COLUMN data_imports.account_id IS '所属账户ID，关联accounts表';
COMMENT ON COLUMN data_imports.data_type IS '数据类型';
COMMENT ON COLUMN data_imports.status IS '导入状态，0=默认';
COMMENT ON COLUMN data_imports.processing_errors IS '处理错误信息';
COMMENT ON COLUMN data_imports.total_records IS '总记录数';
COMMENT ON COLUMN data_imports.processed_records IS '已处理记录数';
COMMENT ON COLUMN data_imports.created_at IS '导入创建时间';
COMMENT ON COLUMN data_imports.updated_at IS '导入更新时间';

-- action_mailbox_inbound_emails 表字段注释
COMMENT ON COLUMN action_mailbox_inbound_emails.id IS '入站邮件ID，主键，自增';
COMMENT ON COLUMN action_mailbox_inbound_emails.status IS '邮件状态，0=默认';
COMMENT ON COLUMN action_mailbox_inbound_emails.message_id IS '邮件消息ID';
COMMENT ON COLUMN action_mailbox_inbound_emails.message_checksum IS '邮件校验和';
COMMENT ON COLUMN action_mailbox_inbound_emails.created_at IS '邮件创建时间';
COMMENT ON COLUMN action_mailbox_inbound_emails.updated_at IS '邮件更新时间';

-- 添加字段注释完成标记
-- 总计：多租户核心(5) + 渠道管理(13) + 客户管理(4) + 对话消息(8) + 团队协作(9) + 知识库(7) + AI功能(9) + 自动化(6) + 权限角色(5) + 系统功能(24) = 90个表
-- 涵盖约1000+个字段的完整注释，提升数据库可读性和维护性
