-- Chatwoot PostgreSQL Schema
-- Generated from db/schema.rb
-- Schema version: 2025_08_25_020836

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "plpgsql";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Create access_tokens table
CREATE TABLE "access_tokens" (
    "id" BIGSERIAL PRIMARY KEY,
    "owner_type" VARCHAR(255),
    "owner_id" BIGINT,
    "token" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create accounts table
CREATE TABLE "accounts" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "locale" INTEGER DEFAULT 0,
    "domain" VARCHAR(100),
    "support_email" VARCHAR(100),
    "feature_flags" BIGINT DEFAULT 0 NOT NULL,
    "auto_resolve_duration" INTEGER,
    "limits" JSONB DEFAULT '{}',
    "custom_attributes" JSONB DEFAULT '{}',
    "status" INTEGER DEFAULT 0,
    "internal_attributes" JSONB DEFAULT '{}' NOT NULL,
    "settings" JSONB DEFAULT '{}'
);

-- Create account_users table
CREATE TABLE "account_users" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT,
    "user_id" BIGINT,
    "role" INTEGER DEFAULT 0,
    "inviter_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "active_at" TIMESTAMP WITHOUT TIME ZONE,
    "availability" INTEGER DEFAULT 0 NOT NULL,
    "auto_offline" BOOLEAN DEFAULT true NOT NULL,
    "custom_role_id" BIGINT,
    "agent_capacity_policy_id" BIGINT
);

-- Create action_mailbox_inbound_emails table
CREATE TABLE "action_mailbox_inbound_emails" (
    "id" BIGSERIAL PRIMARY KEY,
    "status" INTEGER DEFAULT 0 NOT NULL,
    "message_id" VARCHAR(255) NOT NULL,
    "message_checksum" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create active_storage_attachments table
CREATE TABLE "active_storage_attachments" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "record_type" VARCHAR(255) NOT NULL,
    "record_id" BIGINT NOT NULL,
    "blob_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create active_storage_blobs table
CREATE TABLE "active_storage_blobs" (
    "id" BIGSERIAL PRIMARY KEY,
    "key" VARCHAR(255) NOT NULL,
    "filename" VARCHAR(255) NOT NULL,
    "content_type" VARCHAR(255),
    "metadata" TEXT,
    "byte_size" BIGINT NOT NULL,
    "checksum" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "service_name" VARCHAR(255) NOT NULL
);

-- Create active_storage_variant_records table
CREATE TABLE "active_storage_variant_records" (
    "id" BIGSERIAL PRIMARY KEY,
    "blob_id" BIGINT NOT NULL,
    "variation_digest" VARCHAR(255) NOT NULL
);

-- Create agent_bot_inboxes table
CREATE TABLE "agent_bot_inboxes" (
    "id" BIGSERIAL PRIMARY KEY,
    "inbox_id" INTEGER,
    "agent_bot_id" INTEGER,
    "status" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "account_id" INTEGER
);

-- Create agent_bots table
CREATE TABLE "agent_bots" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "description" VARCHAR(255),
    "outgoing_url" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "account_id" BIGINT,
    "bot_type" INTEGER DEFAULT 0,
    "bot_config" JSONB DEFAULT '{}'
);

-- Create agent_capacity_policies table
CREATE TABLE "agent_capacity_policies" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "exclusion_rules" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create applied_slas table
CREATE TABLE "applied_slas" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "sla_policy_id" BIGINT NOT NULL,
    "conversation_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "sla_status" INTEGER DEFAULT 0
);

-- Create article_embeddings table
CREATE TABLE "article_embeddings" (
    "id" BIGSERIAL PRIMARY KEY,
    "article_id" BIGINT NOT NULL,
    "term" TEXT NOT NULL,
    "embedding" VECTOR(1536),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create articles table
CREATE TABLE "articles" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "portal_id" INTEGER NOT NULL,
    "category_id" INTEGER,
    "folder_id" INTEGER,
    "title" VARCHAR(255),
    "description" TEXT,
    "content" TEXT,
    "status" INTEGER,
    "views" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "author_id" BIGINT,
    "associated_article_id" BIGINT,
    "meta" JSONB DEFAULT '{}',
    "slug" VARCHAR(255) NOT NULL,
    "position" INTEGER,
    "locale" VARCHAR(255) DEFAULT 'en' NOT NULL
);

-- Create assignment_policies table
CREATE TABLE "assignment_policies" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "assignment_order" INTEGER DEFAULT 0 NOT NULL,
    "conversation_priority" INTEGER DEFAULT 0 NOT NULL,
    "fair_distribution_limit" INTEGER DEFAULT 100 NOT NULL,
    "fair_distribution_window" INTEGER DEFAULT 3600 NOT NULL,
    "enabled" BOOLEAN DEFAULT true NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create attachments table
CREATE TABLE "attachments" (
    "id" SERIAL PRIMARY KEY,
    "file_type" INTEGER DEFAULT 0,
    "external_url" VARCHAR(255),
    "coordinates_lat" REAL DEFAULT 0.0,
    "coordinates_long" REAL DEFAULT 0.0,
    "message_id" INTEGER NOT NULL,
    "account_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "fallback_title" VARCHAR(255),
    "extension" VARCHAR(255),
    "meta" JSONB DEFAULT '{}'
);

-- Create audits table
CREATE TABLE "audits" (
    "id" BIGSERIAL PRIMARY KEY,
    "auditable_id" BIGINT,
    "auditable_type" VARCHAR(255),
    "associated_id" BIGINT,
    "associated_type" VARCHAR(255),
    "user_id" BIGINT,
    "user_type" VARCHAR(255),
    "username" VARCHAR(255),
    "action" VARCHAR(255),
    "audited_changes" JSONB,
    "version" INTEGER DEFAULT 0,
    "comment" VARCHAR(255),
    "remote_address" VARCHAR(255),
    "request_uuid" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE
);

-- Create automation_rules table
CREATE TABLE "automation_rules" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "event_name" VARCHAR(255) NOT NULL,
    "conditions" JSONB DEFAULT '{}' NOT NULL,
    "actions" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "active" BOOLEAN DEFAULT true NOT NULL
);

-- Create campaigns table
CREATE TABLE "campaigns" (
    "id" BIGSERIAL PRIMARY KEY,
    "display_id" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "message" TEXT NOT NULL,
    "sender_id" INTEGER,
    "enabled" BOOLEAN DEFAULT true,
    "account_id" BIGINT NOT NULL,
    "inbox_id" BIGINT NOT NULL,
    "trigger_rules" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "campaign_type" INTEGER DEFAULT 0 NOT NULL,
    "campaign_status" INTEGER DEFAULT 0 NOT NULL,
    "audience" JSONB DEFAULT '[]',
    "scheduled_at" TIMESTAMP WITHOUT TIME ZONE,
    "trigger_only_during_business_hours" BOOLEAN DEFAULT false,
    "template_params" JSONB DEFAULT '{}' NOT NULL
);

-- Create canned_responses table
CREATE TABLE "canned_responses" (
    "id" SERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "short_code" VARCHAR(255),
    "content" TEXT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create captain_assistant_responses table
CREATE TABLE "captain_assistant_responses" (
    "id" BIGSERIAL PRIMARY KEY,
    "question" VARCHAR(255) NOT NULL,
    "answer" TEXT NOT NULL,
    "embedding" VECTOR(1536),
    "assistant_id" BIGINT NOT NULL,
    "documentable_id" BIGINT,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "status" INTEGER DEFAULT 1 NOT NULL,
    "documentable_type" VARCHAR(255)
);

-- Create captain_assistants table
CREATE TABLE "captain_assistants" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "account_id" BIGINT NOT NULL,
    "description" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "config" JSONB DEFAULT '{}' NOT NULL,
    "response_guidelines" JSONB DEFAULT '[]',
    "guardrails" JSONB DEFAULT '[]'
);

-- Create captain_documents table
CREATE TABLE "captain_documents" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "external_link" VARCHAR(255) NOT NULL,
    "content" TEXT,
    "assistant_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "status" INTEGER DEFAULT 0 NOT NULL
);

-- Create captain_inboxes table
CREATE TABLE "captain_inboxes" (
    "id" BIGSERIAL PRIMARY KEY,
    "captain_assistant_id" BIGINT NOT NULL,
    "inbox_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create captain_scenarios table
CREATE TABLE "captain_scenarios" (
    "id" BIGSERIAL PRIMARY KEY,
    "title" VARCHAR(255),
    "description" TEXT,
    "instruction" TEXT,
    "tools" JSONB DEFAULT '[]',
    "enabled" BOOLEAN DEFAULT true NOT NULL,
    "assistant_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create categories table
CREATE TABLE "categories" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "portal_id" INTEGER NOT NULL,
    "name" VARCHAR(255),
    "description" TEXT,
    "position" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "locale" VARCHAR(255) DEFAULT 'en',
    "slug" VARCHAR(255) NOT NULL,
    "parent_category_id" BIGINT,
    "associated_category_id" BIGINT,
    "icon" VARCHAR(255) DEFAULT ''
);

-- Create channel_api table
CREATE TABLE "channel_api" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "webhook_url" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "identifier" VARCHAR(255),
    "hmac_token" VARCHAR(255),
    "hmac_mandatory" BOOLEAN DEFAULT false,
    "additional_attributes" JSONB DEFAULT '{}'
);

-- Create channel_email table
CREATE TABLE "channel_email" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "forward_to_email" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "imap_enabled" BOOLEAN DEFAULT false,
    "imap_address" VARCHAR(255) DEFAULT '',
    "imap_port" INTEGER DEFAULT 0,
    "imap_login" VARCHAR(255) DEFAULT '',
    "imap_password" VARCHAR(255) DEFAULT '',
    "imap_enable_ssl" BOOLEAN DEFAULT true,
    "smtp_enabled" BOOLEAN DEFAULT false,
    "smtp_address" VARCHAR(255) DEFAULT '',
    "smtp_port" INTEGER DEFAULT 0,
    "smtp_login" VARCHAR(255) DEFAULT '',
    "smtp_password" VARCHAR(255) DEFAULT '',
    "smtp_domain" VARCHAR(255) DEFAULT '',
    "smtp_enable_starttls_auto" BOOLEAN DEFAULT true,
    "smtp_authentication" VARCHAR(255) DEFAULT 'login',
    "smtp_openssl_verify_mode" VARCHAR(255) DEFAULT 'none',
    "smtp_enable_ssl_tls" BOOLEAN DEFAULT false,
    "provider_config" JSONB DEFAULT '{}',
    "provider" VARCHAR(255)
);

-- Create channel_facebook_pages table
CREATE TABLE "channel_facebook_pages" (
    "id" SERIAL PRIMARY KEY,
    "page_id" VARCHAR(255) NOT NULL,
    "user_access_token" VARCHAR(255) NOT NULL,
    "page_access_token" VARCHAR(255) NOT NULL,
    "account_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "instagram_id" VARCHAR(255)
);

-- Create channel_instagram table
CREATE TABLE "channel_instagram" (
    "id" BIGSERIAL PRIMARY KEY,
    "access_token" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "account_id" INTEGER NOT NULL,
    "instagram_id" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create channel_line table
CREATE TABLE "channel_line" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "line_channel_id" VARCHAR(255) NOT NULL,
    "line_channel_secret" VARCHAR(255) NOT NULL,
    "line_channel_token" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create channel_sms table
CREATE TABLE "channel_sms" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "phone_number" VARCHAR(255) NOT NULL,
    "provider" VARCHAR(255) DEFAULT 'default',
    "provider_config" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create channel_telegram table
CREATE TABLE "channel_telegram" (
    "id" BIGSERIAL PRIMARY KEY,
    "bot_name" VARCHAR(255),
    "account_id" INTEGER NOT NULL,
    "bot_token" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create channel_twilio_sms table
CREATE TABLE "channel_twilio_sms" (
    "id" BIGSERIAL PRIMARY KEY,
    "phone_number" VARCHAR(255),
    "auth_token" VARCHAR(255) NOT NULL,
    "account_sid" VARCHAR(255) NOT NULL,
    "account_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "medium" INTEGER DEFAULT 0,
    "messaging_service_sid" VARCHAR(255),
    "api_key_sid" VARCHAR(255)
);

-- Create channel_twitter_profiles table
CREATE TABLE "channel_twitter_profiles" (
    "id" BIGSERIAL PRIMARY KEY,
    "profile_id" VARCHAR(255) NOT NULL,
    "twitter_access_token" VARCHAR(255) NOT NULL,
    "twitter_access_token_secret" VARCHAR(255) NOT NULL,
    "account_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "tweets_enabled" BOOLEAN DEFAULT true
);

-- Create channel_voice table
CREATE TABLE "channel_voice" (
    "id" BIGSERIAL PRIMARY KEY,
    "phone_number" VARCHAR(255) NOT NULL,
    "provider" VARCHAR(255) DEFAULT 'twilio' NOT NULL,
    "provider_config" JSONB NOT NULL,
    "account_id" INTEGER NOT NULL,
    "additional_attributes" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create channel_web_widgets table
CREATE TABLE "channel_web_widgets" (
    "id" SERIAL PRIMARY KEY,
    "website_url" VARCHAR(255),
    "account_id" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "website_token" VARCHAR(255),
    "widget_color" VARCHAR(255) DEFAULT '#1f93ff',
    "welcome_title" VARCHAR(255),
    "welcome_tagline" VARCHAR(255),
    "feature_flags" INTEGER DEFAULT 7 NOT NULL,
    "reply_time" INTEGER DEFAULT 0,
    "hmac_token" VARCHAR(255),
    "pre_chat_form_enabled" BOOLEAN DEFAULT false,
    "pre_chat_form_options" JSONB DEFAULT '{}',
    "hmac_mandatory" BOOLEAN DEFAULT false,
    "continuity_via_email" BOOLEAN DEFAULT true NOT NULL
);

-- Create channel_whatsapp table
CREATE TABLE "channel_whatsapp" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "phone_number" VARCHAR(255) NOT NULL,
    "provider" VARCHAR(255) DEFAULT 'default',
    "provider_config" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "message_templates" JSONB DEFAULT '{}',
    "message_templates_last_updated" TIMESTAMP WITHOUT TIME ZONE
);

-- Create contact_inboxes table
CREATE TABLE "contact_inboxes" (
    "id" BIGSERIAL PRIMARY KEY,
    "contact_id" BIGINT,
    "inbox_id" BIGINT,
    "source_id" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "hmac_verified" BOOLEAN DEFAULT false,
    "pubsub_token" VARCHAR(255)
);

-- Create contacts table
CREATE TABLE "contacts" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) DEFAULT '',
    "email" VARCHAR(255),
    "phone_number" VARCHAR(255),
    "account_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "additional_attributes" JSONB DEFAULT '{}',
    "identifier" VARCHAR(255),
    "custom_attributes" JSONB DEFAULT '{}',
    "last_activity_at" TIMESTAMP WITHOUT TIME ZONE,
    "contact_type" INTEGER DEFAULT 0,
    "middle_name" VARCHAR(255) DEFAULT '',
    "last_name" VARCHAR(255) DEFAULT '',
    "location" VARCHAR(255) DEFAULT '',
    "country_code" VARCHAR(255) DEFAULT '',
    "blocked" BOOLEAN DEFAULT false NOT NULL
);

-- Create conversation_participants table
CREATE TABLE "conversation_participants" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "conversation_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create conversations table
CREATE TABLE "conversations" (
    "id" SERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "inbox_id" INTEGER NOT NULL,
    "status" INTEGER DEFAULT 0 NOT NULL,
    "assignee_id" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "contact_id" BIGINT,
    "display_id" INTEGER NOT NULL,
    "contact_last_seen_at" TIMESTAMP WITHOUT TIME ZONE,
    "agent_last_seen_at" TIMESTAMP WITHOUT TIME ZONE,
    "additional_attributes" JSONB DEFAULT '{}',
    "contact_inbox_id" BIGINT,
    "uuid" UUID DEFAULT gen_random_uuid() NOT NULL,
    "identifier" VARCHAR(255),
    "last_activity_at" TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "team_id" BIGINT,
    "campaign_id" BIGINT,
    "snoozed_until" TIMESTAMP WITHOUT TIME ZONE,
    "custom_attributes" JSONB DEFAULT '{}',
    "assignee_last_seen_at" TIMESTAMP WITHOUT TIME ZONE,
    "first_reply_created_at" TIMESTAMP WITHOUT TIME ZONE,
    "priority" INTEGER,
    "sla_policy_id" BIGINT,
    "waiting_since" TIMESTAMP WITHOUT TIME ZONE,
    "cached_label_list" TEXT
);

-- Create copilot_messages table
CREATE TABLE "copilot_messages" (
    "id" BIGSERIAL PRIMARY KEY,
    "copilot_thread_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "message" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "message_type" INTEGER DEFAULT 0
);

-- Create copilot_threads table
CREATE TABLE "copilot_threads" (
    "id" BIGSERIAL PRIMARY KEY,
    "title" VARCHAR(255) NOT NULL,
    "user_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "assistant_id" INTEGER
);

-- Create csat_survey_responses table
CREATE TABLE "csat_survey_responses" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "conversation_id" BIGINT NOT NULL,
    "message_id" BIGINT NOT NULL,
    "rating" INTEGER NOT NULL,
    "feedback_message" TEXT,
    "contact_id" BIGINT NOT NULL,
    "assigned_agent_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create custom_attribute_definitions table
CREATE TABLE "custom_attribute_definitions" (
    "id" BIGSERIAL PRIMARY KEY,
    "attribute_display_name" VARCHAR(255),
    "attribute_key" VARCHAR(255),
    "attribute_display_type" INTEGER DEFAULT 0,
    "default_value" INTEGER,
    "attribute_model" INTEGER DEFAULT 0,
    "account_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "attribute_description" TEXT,
    "attribute_values" JSONB DEFAULT '[]',
    "regex_pattern" VARCHAR(255),
    "regex_cue" VARCHAR(255)
);

-- Create custom_filters table
CREATE TABLE "custom_filters" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "filter_type" INTEGER DEFAULT 0 NOT NULL,
    "query" JSONB DEFAULT '{}' NOT NULL,
    "account_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create custom_role_audit_logs table
CREATE TABLE "custom_role_audit_logs" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "custom_role_id" BIGINT,
    "user_id" BIGINT,
    "target_user_id" BIGINT,
    "action" VARCHAR(255) NOT NULL,
    "change_data" JSONB,
    "ip_address" VARCHAR(255),
    "user_agent" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create custom_role_templates table
CREATE TABLE "custom_role_templates" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "permissions" TEXT[] DEFAULT '{}',
    "is_system" BOOLEAN DEFAULT false NOT NULL,
    "category" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create custom_roles table
CREATE TABLE "custom_roles" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "description" VARCHAR(255),
    "account_id" BIGINT NOT NULL,
    "permissions" TEXT[] DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "parent_id" BIGINT,
    "is_system" BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT "check_custom_roles_has_permissions" CHECK (array_length("permissions", 1) > 0),
    CONSTRAINT "check_custom_roles_name_not_empty" CHECK (length(TRIM(BOTH FROM "name")) > 0)
);

-- Create dashboard_apps table
CREATE TABLE "dashboard_apps" (
    "id" BIGSERIAL PRIMARY KEY,
    "title" VARCHAR(255) NOT NULL,
    "content" JSONB DEFAULT '[]',
    "account_id" BIGINT NOT NULL,
    "user_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create data_imports table
CREATE TABLE "data_imports" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "data_type" VARCHAR(255) NOT NULL,
    "status" INTEGER DEFAULT 0 NOT NULL,
    "processing_errors" TEXT,
    "total_records" INTEGER,
    "processed_records" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create email_templates table
CREATE TABLE "email_templates" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "body" TEXT NOT NULL,
    "account_id" INTEGER,
    "template_type" INTEGER DEFAULT 1,
    "locale" INTEGER DEFAULT 0 NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create folders table
CREATE TABLE "folders" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,
    "name" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create inbox_assignment_policies table
CREATE TABLE "inbox_assignment_policies" (
    "id" BIGSERIAL PRIMARY KEY,
    "inbox_id" BIGINT NOT NULL,
    "assignment_policy_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create inbox_capacity_limits table
CREATE TABLE "inbox_capacity_limits" (
    "id" BIGSERIAL PRIMARY KEY,
    "agent_capacity_policy_id" BIGINT NOT NULL,
    "inbox_id" BIGINT NOT NULL,
    "conversation_limit" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create inbox_members table
CREATE TABLE "inbox_members" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER NOT NULL,
    "inbox_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create inboxes table
CREATE TABLE "inboxes" (
    "id" SERIAL PRIMARY KEY,
    "channel_id" INTEGER NOT NULL,
    "account_id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "channel_type" VARCHAR(255),
    "enable_auto_assignment" BOOLEAN DEFAULT true,
    "greeting_enabled" BOOLEAN DEFAULT false,
    "greeting_message" VARCHAR(255),
    "email_address" VARCHAR(255),
    "working_hours_enabled" BOOLEAN DEFAULT false,
    "out_of_office_message" VARCHAR(255),
    "timezone" VARCHAR(255) DEFAULT 'UTC',
    "enable_email_collect" BOOLEAN DEFAULT true,
    "csat_survey_enabled" BOOLEAN DEFAULT false,
    "allow_messages_after_resolved" BOOLEAN DEFAULT true,
    "auto_assignment_config" JSONB DEFAULT '{}',
    "lock_to_single_conversation" BOOLEAN DEFAULT false NOT NULL,
    "portal_id" BIGINT,
    "sender_name_type" INTEGER DEFAULT 0 NOT NULL,
    "business_name" VARCHAR(255),
    "csat_config" JSONB DEFAULT '{}' NOT NULL
);

-- Create installation_configs table
CREATE TABLE "installation_configs" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "serialized_value" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "locked" BOOLEAN DEFAULT true NOT NULL
);

-- Create integrations_hooks table
CREATE TABLE "integrations_hooks" (
    "id" BIGSERIAL PRIMARY KEY,
    "status" INTEGER DEFAULT 1,
    "inbox_id" INTEGER,
    "account_id" INTEGER,
    "app_id" VARCHAR(255),
    "hook_type" INTEGER DEFAULT 0,
    "reference_id" VARCHAR(255),
    "access_token" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "settings" JSONB DEFAULT '{}'
);

-- Create labels table
CREATE TABLE "labels" (
    "id" BIGSERIAL PRIMARY KEY,
    "title" VARCHAR(255),
    "description" TEXT,
    "color" VARCHAR(255) DEFAULT '#1f93ff' NOT NULL,
    "show_on_sidebar" BOOLEAN,
    "account_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create leaves table
CREATE TABLE "leaves" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "leave_type" INTEGER DEFAULT 0 NOT NULL,
    "status" INTEGER DEFAULT 0 NOT NULL,
    "reason" TEXT,
    "approved_by_id" BIGINT,
    "approved_at" TIMESTAMP WITHOUT TIME ZONE,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create macros table
CREATE TABLE "macros" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "visibility" INTEGER DEFAULT 0,
    "created_by_id" BIGINT,
    "updated_by_id" BIGINT,
    "actions" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create mentions table
CREATE TABLE "mentions" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "conversation_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "mentioned_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create messages table
CREATE TABLE "messages" (
    "id" SERIAL PRIMARY KEY,
    "content" TEXT,
    "account_id" INTEGER NOT NULL,
    "inbox_id" INTEGER NOT NULL,
    "conversation_id" INTEGER NOT NULL,
    "message_type" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "private" BOOLEAN DEFAULT false NOT NULL,
    "status" INTEGER DEFAULT 0,
    "source_id" VARCHAR(255),
    "content_type" INTEGER DEFAULT 0 NOT NULL,
    "content_attributes" JSON DEFAULT '{}',
    "sender_type" VARCHAR(255),
    "sender_id" BIGINT,
    "external_source_ids" JSONB DEFAULT '{}',
    "additional_attributes" JSONB DEFAULT '{}',
    "processed_message_content" TEXT,
    "sentiment" JSONB DEFAULT '{}'
);

-- Create notes table
CREATE TABLE "notes" (
    "id" BIGSERIAL PRIMARY KEY,
    "content" TEXT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "contact_id" BIGINT NOT NULL,
    "user_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create notification_settings table
CREATE TABLE "notification_settings" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER,
    "user_id" INTEGER,
    "email_flags" INTEGER DEFAULT 0 NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "push_flags" INTEGER DEFAULT 0 NOT NULL
);

-- Create notification_subscriptions table
CREATE TABLE "notification_subscriptions" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "subscription_type" INTEGER NOT NULL,
    "subscription_attributes" JSONB DEFAULT '{}' NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "identifier" TEXT
);

-- Create notifications table
CREATE TABLE "notifications" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "notification_type" INTEGER NOT NULL,
    "primary_actor_type" VARCHAR(255) NOT NULL,
    "primary_actor_id" BIGINT NOT NULL,
    "secondary_actor_type" VARCHAR(255),
    "secondary_actor_id" BIGINT,
    "read_at" TIMESTAMP WITHOUT TIME ZONE,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "snoozed_until" TIMESTAMP WITHOUT TIME ZONE,
    "last_activity_at" TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "meta" JSONB DEFAULT '{}'
);

-- Create platform_app_permissibles table
CREATE TABLE "platform_app_permissibles" (
    "id" BIGSERIAL PRIMARY KEY,
    "platform_app_id" BIGINT NOT NULL,
    "permissible_type" VARCHAR(255) NOT NULL,
    "permissible_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create platform_apps table
CREATE TABLE "platform_apps" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create portals table
CREATE TABLE "portals" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(255) NOT NULL,
    "custom_domain" VARCHAR(255),
    "color" VARCHAR(255),
    "homepage_link" VARCHAR(255),
    "page_title" VARCHAR(255),
    "header_text" TEXT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "config" JSONB DEFAULT '{"allowed_locales": ["en"]}',
    "archived" BOOLEAN DEFAULT false,
    "channel_web_widget_id" BIGINT,
    "ssl_settings" JSONB DEFAULT '{}' NOT NULL
);

-- Create portals_members table
CREATE TABLE "portals_members" (
    "portal_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL
);

-- Create related_categories table
CREATE TABLE "related_categories" (
    "id" BIGSERIAL PRIMARY KEY,
    "category_id" BIGINT,
    "related_category_id" BIGINT,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create reporting_events table
CREATE TABLE "reporting_events" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "value" REAL,
    "account_id" INTEGER,
    "inbox_id" INTEGER,
    "user_id" INTEGER,
    "conversation_id" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "value_in_business_hours" REAL,
    "event_start_time" TIMESTAMP WITHOUT TIME ZONE,
    "event_end_time" TIMESTAMP WITHOUT TIME ZONE
);

-- Create sla_events table
CREATE TABLE "sla_events" (
    "id" BIGSERIAL PRIMARY KEY,
    "applied_sla_id" BIGINT NOT NULL,
    "conversation_id" BIGINT NOT NULL,
    "account_id" BIGINT NOT NULL,
    "sla_policy_id" BIGINT NOT NULL,
    "inbox_id" BIGINT NOT NULL,
    "event_type" INTEGER,
    "meta" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create sla_policies table
CREATE TABLE "sla_policies" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "first_response_time_threshold" REAL,
    "next_response_time_threshold" REAL,
    "only_during_business_hours" BOOLEAN DEFAULT false,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "description" VARCHAR(255),
    "resolution_time_threshold" REAL
);

-- Create taggings table
CREATE TABLE "taggings" (
    "id" SERIAL PRIMARY KEY,
    "tag_id" INTEGER,
    "taggable_type" VARCHAR(255),
    "taggable_id" INTEGER,
    "tagger_type" VARCHAR(255),
    "tagger_id" INTEGER,
    "context" VARCHAR(128),
    "created_at" TIMESTAMP WITHOUT TIME ZONE
);

-- Create tags table
CREATE TABLE "tags" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "taggings_count" INTEGER DEFAULT 0
);

-- Create team_members table
CREATE TABLE "team_members" (
    "id" BIGSERIAL PRIMARY KEY,
    "team_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create teams table
CREATE TABLE "teams" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "allow_auto_assign" BOOLEAN DEFAULT true,
    "account_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create telegram_bots table
CREATE TABLE "telegram_bots" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "auth_key" VARCHAR(255),
    "account_id" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Create users table
CREATE TABLE "users" (
    "id" SERIAL PRIMARY KEY,
    "provider" VARCHAR(255) DEFAULT 'email' NOT NULL,
    "uid" VARCHAR(255) DEFAULT '' NOT NULL,
    "encrypted_password" VARCHAR(255) DEFAULT '' NOT NULL,
    "reset_password_token" VARCHAR(255),
    "reset_password_sent_at" TIMESTAMP WITHOUT TIME ZONE,
    "remember_created_at" TIMESTAMP WITHOUT TIME ZONE,
    "sign_in_count" INTEGER DEFAULT 0 NOT NULL,
    "current_sign_in_at" TIMESTAMP WITHOUT TIME ZONE,
    "last_sign_in_at" TIMESTAMP WITHOUT TIME ZONE,
    "current_sign_in_ip" VARCHAR(255),
    "last_sign_in_ip" VARCHAR(255),
    "confirmation_token" VARCHAR(255),
    "confirmed_at" TIMESTAMP WITHOUT TIME ZONE,
    "confirmation_sent_at" TIMESTAMP WITHOUT TIME ZONE,
    "unconfirmed_email" VARCHAR(255),
    "name" VARCHAR(255) NOT NULL,
    "display_name" VARCHAR(255),
    "email" VARCHAR(255),
    "tokens" JSON,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "pubsub_token" VARCHAR(255),
    "availability" INTEGER DEFAULT 0,
    "ui_settings" JSONB DEFAULT '{}',
    "custom_attributes" JSONB DEFAULT '{}',
    "type" VARCHAR(255),
    "message_signature" TEXT
);

-- Create webhooks table
CREATE TABLE "webhooks" (
    "id" BIGSERIAL PRIMARY KEY,
    "account_id" INTEGER,
    "inbox_id" INTEGER,
    "url" VARCHAR(255),
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "webhook_type" INTEGER DEFAULT 0,
    "subscriptions" JSONB DEFAULT '["conversation_status_changed", "conversation_updated", "conversation_created", "contact_created", "contact_updated", "message_created", "message_updated", "webwidget_triggered"]'
);

-- Create working_hours table
CREATE TABLE "working_hours" (
    "id" BIGSERIAL PRIMARY KEY,
    "inbox_id" BIGINT,
    "account_id" BIGINT,
    "day_of_week" INTEGER NOT NULL,
    "closed_all_day" BOOLEAN DEFAULT false,
    "open_hour" INTEGER,
    "open_minutes" INTEGER,
    "close_hour" INTEGER,
    "close_minutes" INTEGER,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "open_all_day" BOOLEAN DEFAULT false
);

-- Create all indexes
CREATE INDEX "index_access_tokens_on_owner_type_and_owner_id" ON "access_tokens" ("owner_type", "owner_id");
CREATE UNIQUE INDEX "index_access_tokens_on_token" ON "access_tokens" ("token");

CREATE INDEX "index_accounts_on_status" ON "accounts" ("status");

CREATE UNIQUE INDEX "uniq_user_id_per_account_id" ON "account_users" ("account_id", "user_id");
CREATE INDEX "index_account_users_on_account_id" ON "account_users" ("account_id");
CREATE INDEX "index_account_users_on_agent_capacity_policy_id" ON "account_users" ("agent_capacity_policy_id");
CREATE INDEX "index_account_users_on_custom_role_id" ON "account_users" ("custom_role_id");
CREATE INDEX "index_account_users_on_user_id" ON "account_users" ("user_id");

CREATE UNIQUE INDEX "index_action_mailbox_inbound_emails_uniqueness" ON "action_mailbox_inbound_emails" ("message_id", "message_checksum");

CREATE INDEX "index_active_storage_attachments_on_blob_id" ON "active_storage_attachments" ("blob_id");
CREATE UNIQUE INDEX "index_active_storage_attachments_uniqueness" ON "active_storage_attachments" ("record_type", "record_id", "name", "blob_id");

CREATE UNIQUE INDEX "index_active_storage_blobs_on_key" ON "active_storage_blobs" ("key");

CREATE UNIQUE INDEX "index_active_storage_variant_records_uniqueness" ON "active_storage_variant_records" ("blob_id", "variation_digest");

CREATE INDEX "index_agent_bots_on_account_id" ON "agent_bots" ("account_id");

CREATE INDEX "index_agent_capacity_policies_on_account_id" ON "agent_capacity_policies" ("account_id");

CREATE UNIQUE INDEX "index_applied_slas_on_account_sla_policy_conversation" ON "applied_slas" ("account_id", "sla_policy_id", "conversation_id");
CREATE INDEX "index_applied_slas_on_account_id" ON "applied_slas" ("account_id");
CREATE INDEX "index_applied_slas_on_conversation_id" ON "applied_slas" ("conversation_id");
CREATE INDEX "index_applied_slas_on_sla_policy_id" ON "applied_slas" ("sla_policy_id");

CREATE INDEX "index_article_embeddings_on_embedding" ON "article_embeddings" USING ivfflat ("embedding");

CREATE INDEX "index_articles_on_account_id" ON "articles" ("account_id");
CREATE INDEX "index_articles_on_associated_article_id" ON "articles" ("associated_article_id");
CREATE INDEX "index_articles_on_author_id" ON "articles" ("author_id");
CREATE INDEX "index_articles_on_portal_id" ON "articles" ("portal_id");
CREATE UNIQUE INDEX "index_articles_on_slug" ON "articles" ("slug");
CREATE INDEX "index_articles_on_status" ON "articles" ("status");
CREATE INDEX "index_articles_on_views" ON "articles" ("views");

CREATE UNIQUE INDEX "index_assignment_policies_on_account_id_and_name" ON "assignment_policies" ("account_id", "name");
CREATE INDEX "index_assignment_policies_on_account_id" ON "assignment_policies" ("account_id");
CREATE INDEX "index_assignment_policies_on_enabled" ON "assignment_policies" ("enabled");

CREATE INDEX "index_attachments_on_account_id" ON "attachments" ("account_id");
CREATE INDEX "index_attachments_on_message_id" ON "attachments" ("message_id");

CREATE INDEX "associated_index" ON "audits" ("associated_type", "associated_id");
CREATE INDEX "auditable_index" ON "audits" ("auditable_type", "auditable_id", "version");
CREATE INDEX "index_audits_on_created_at" ON "audits" ("created_at");
CREATE INDEX "index_audits_on_request_uuid" ON "audits" ("request_uuid");
CREATE INDEX "user_index" ON "audits" ("user_id", "user_type");

CREATE INDEX "index_automation_rules_on_account_id" ON "automation_rules" ("account_id");

CREATE INDEX "index_campaigns_on_account_id" ON "campaigns" ("account_id");
CREATE INDEX "index_campaigns_on_campaign_status" ON "campaigns" ("campaign_status");
CREATE INDEX "index_campaigns_on_campaign_type" ON "campaigns" ("campaign_type");
CREATE INDEX "index_campaigns_on_inbox_id" ON "campaigns" ("inbox_id");
CREATE INDEX "index_campaigns_on_scheduled_at" ON "campaigns" ("scheduled_at");

CREATE INDEX "index_captain_assistant_responses_on_account_id" ON "captain_assistant_responses" ("account_id");
CREATE INDEX "index_captain_assistant_responses_on_assistant_id" ON "captain_assistant_responses" ("assistant_id");
CREATE INDEX "idx_cap_asst_resp_on_documentable" ON "captain_assistant_responses" ("documentable_id", "documentable_type");
CREATE INDEX "vector_idx_knowledge_entries_embedding" ON "captain_assistant_responses" USING ivfflat ("embedding");
CREATE INDEX "index_captain_assistant_responses_on_status" ON "captain_assistant_responses" ("status");

CREATE INDEX "index_captain_assistants_on_account_id" ON "captain_assistants" ("account_id");

CREATE INDEX "index_captain_documents_on_account_id" ON "captain_documents" ("account_id");
CREATE UNIQUE INDEX "index_captain_documents_on_assistant_id_and_external_link" ON "captain_documents" ("assistant_id", "external_link");
CREATE INDEX "index_captain_documents_on_assistant_id" ON "captain_documents" ("assistant_id");
CREATE INDEX "index_captain_documents_on_status" ON "captain_documents" ("status");

CREATE UNIQUE INDEX "index_captain_inboxes_on_captain_assistant_id_and_inbox_id" ON "captain_inboxes" ("captain_assistant_id", "inbox_id");
CREATE INDEX "index_captain_inboxes_on_captain_assistant_id" ON "captain_inboxes" ("captain_assistant_id");
CREATE INDEX "index_captain_inboxes_on_inbox_id" ON "captain_inboxes" ("inbox_id");

CREATE INDEX "index_captain_scenarios_on_account_id" ON "captain_scenarios" ("account_id");
CREATE INDEX "index_captain_scenarios_on_assistant_id_and_enabled" ON "captain_scenarios" ("assistant_id", "enabled");
CREATE INDEX "index_captain_scenarios_on_assistant_id" ON "captain_scenarios" ("assistant_id");
CREATE INDEX "index_captain_scenarios_on_enabled" ON "captain_scenarios" ("enabled");

CREATE INDEX "index_categories_on_associated_category_id" ON "categories" ("associated_category_id");
CREATE INDEX "index_categories_on_locale_and_account_id" ON "categories" ("locale", "account_id");
CREATE INDEX "index_categories_on_locale" ON "categories" ("locale");
CREATE INDEX "index_categories_on_parent_category_id" ON "categories" ("parent_category_id");
CREATE UNIQUE INDEX "index_categories_on_slug_and_locale_and_portal_id" ON "categories" ("slug", "locale", "portal_id");

CREATE UNIQUE INDEX "index_channel_api_on_hmac_token" ON "channel_api" ("hmac_token");
CREATE UNIQUE INDEX "index_channel_api_on_identifier" ON "channel_api" ("identifier");

CREATE UNIQUE INDEX "index_channel_email_on_email" ON "channel_email" ("email");
CREATE UNIQUE INDEX "index_channel_email_on_forward_to_email" ON "channel_email" ("forward_to_email");

CREATE UNIQUE INDEX "index_channel_facebook_pages_on_page_id_and_account_id" ON "channel_facebook_pages" ("page_id", "account_id");
CREATE INDEX "index_channel_facebook_pages_on_page_id" ON "channel_facebook_pages" ("page_id");

CREATE UNIQUE INDEX "index_channel_instagram_on_instagram_id" ON "channel_instagram" ("instagram_id");

CREATE UNIQUE INDEX "index_channel_line_on_line_channel_id" ON "channel_line" ("line_channel_id");

CREATE UNIQUE INDEX "index_channel_sms_on_phone_number" ON "channel_sms" ("phone_number");

CREATE UNIQUE INDEX "index_channel_telegram_on_bot_token" ON "channel_telegram" ("bot_token");

CREATE UNIQUE INDEX "index_channel_twilio_sms_on_account_sid_and_phone_number" ON "channel_twilio_sms" ("account_sid", "phone_number");
CREATE UNIQUE INDEX "index_channel_twilio_sms_on_messaging_service_sid" ON "channel_twilio_sms" ("messaging_service_sid");
CREATE UNIQUE INDEX "index_channel_twilio_sms_on_phone_number" ON "channel_twilio_sms" ("phone_number");

CREATE UNIQUE INDEX "index_channel_twitter_profiles_on_account_id_and_profile_id" ON "channel_twitter_profiles" ("account_id", "profile_id");

CREATE INDEX "index_channel_voice_on_account_id" ON "channel_voice" ("account_id");
CREATE UNIQUE INDEX "index_channel_voice_on_phone_number" ON "channel_voice" ("phone_number");

CREATE UNIQUE INDEX "index_channel_web_widgets_on_hmac_token" ON "channel_web_widgets" ("hmac_token");
CREATE UNIQUE INDEX "index_channel_web_widgets_on_website_token" ON "channel_web_widgets" ("website_token");

CREATE UNIQUE INDEX "index_channel_whatsapp_on_phone_number" ON "channel_whatsapp" ("phone_number");

CREATE INDEX "index_contact_inboxes_on_contact_id" ON "contact_inboxes" ("contact_id");
CREATE UNIQUE INDEX "index_contact_inboxes_on_inbox_id_and_source_id" ON "contact_inboxes" ("inbox_id", "source_id");
CREATE INDEX "index_contact_inboxes_on_inbox_id" ON "contact_inboxes" ("inbox_id");
CREATE UNIQUE INDEX "index_contact_inboxes_on_pubsub_token" ON "contact_inboxes" ("pubsub_token");
CREATE INDEX "index_contact_inboxes_on_source_id" ON "contact_inboxes" ("source_id");

CREATE INDEX "index_contacts_on_lower_email_account_id" ON "contacts" (lower("email"), "account_id");
CREATE INDEX "index_contacts_on_account_id_and_contact_type" ON "contacts" ("account_id", "contact_type");
CREATE INDEX "index_contacts_on_nonempty_fields" ON "contacts" ("account_id", "email", "phone_number", "identifier") WHERE (("email" <> '') OR ("phone_number" <> '') OR ("identifier" <> ''));
CREATE INDEX "index_contacts_on_account_id_and_last_activity_at" ON "contacts" ("account_id", "last_activity_at" DESC NULLS LAST);
CREATE INDEX "index_contacts_on_account_id" ON "contacts" ("account_id");
CREATE INDEX "index_resolved_contact_account_id" ON "contacts" ("account_id") WHERE (("email" <> '') OR ("phone_number" <> '') OR ("identifier" <> ''));
CREATE INDEX "index_contacts_on_blocked" ON "contacts" ("blocked");
CREATE UNIQUE INDEX "uniq_email_per_account_contact" ON "contacts" ("email", "account_id");
CREATE UNIQUE INDEX "uniq_identifier_per_account_contact" ON "contacts" ("identifier", "account_id");
CREATE INDEX "index_contacts_on_name_email_phone_number_identifier" ON "contacts" USING gin ("name" gin_trgm_ops, "email" gin_trgm_ops, "phone_number" gin_trgm_ops, "identifier" gin_trgm_ops);
CREATE INDEX "index_contacts_on_phone_number_and_account_id" ON "contacts" ("phone_number", "account_id");

CREATE INDEX "index_conversation_participants_on_account_id" ON "conversation_participants" ("account_id");
CREATE INDEX "index_conversation_participants_on_conversation_id" ON "conversation_participants" ("conversation_id");
CREATE UNIQUE INDEX "index_conversation_participants_on_user_id_and_conversation_id" ON "conversation_participants" ("user_id", "conversation_id");
CREATE INDEX "index_conversation_participants_on_user_id" ON "conversation_participants" ("user_id");

CREATE UNIQUE INDEX "index_conversations_on_account_id_and_display_id" ON "conversations" ("account_id", "display_id");
CREATE INDEX "index_conversations_on_id_and_account_id" ON "conversations" ("id", "account_id");
CREATE INDEX "conv_acid_inbid_stat_asgnid_idx" ON "conversations" ("account_id", "inbox_id", "status", "assignee_id");
CREATE INDEX "index_conversations_on_account_id" ON "conversations" ("account_id");
CREATE INDEX "index_conversations_on_assignee_id_and_account_id" ON "conversations" ("assignee_id", "account_id");
CREATE INDEX "index_conversations_on_campaign_id" ON "conversations" ("campaign_id");
CREATE INDEX "index_conversations_on_contact_id" ON "conversations" ("contact_id");
CREATE INDEX "index_conversations_on_contact_inbox_id" ON "conversations" ("contact_inbox_id");
CREATE INDEX "index_conversations_on_first_reply_created_at" ON "conversations" ("first_reply_created_at");
CREATE INDEX "index_conversations_on_inbox_id" ON "conversations" ("inbox_id");
CREATE INDEX "index_conversations_on_priority" ON "conversations" ("priority");
CREATE INDEX "index_conversations_on_status_and_account_id" ON "conversations" ("status", "account_id");
CREATE INDEX "index_conversations_on_status_and_priority" ON "conversations" ("status", "priority");
CREATE INDEX "index_conversations_on_team_id" ON "conversations" ("team_id");
CREATE UNIQUE INDEX "index_conversations_on_uuid" ON "conversations" ("uuid");
CREATE INDEX "index_conversations_on_waiting_since" ON "conversations" ("waiting_since");

CREATE INDEX "index_copilot_messages_on_account_id" ON "copilot_messages" ("account_id");
CREATE INDEX "index_copilot_messages_on_copilot_thread_id" ON "copilot_messages" ("copilot_thread_id");

CREATE INDEX "index_copilot_threads_on_account_id" ON "copilot_threads" ("account_id");
CREATE INDEX "index_copilot_threads_on_assistant_id" ON "copilot_threads" ("assistant_id");
CREATE INDEX "index_copilot_threads_on_user_id" ON "copilot_threads" ("user_id");

CREATE INDEX "index_csat_survey_responses_on_account_id" ON "csat_survey_responses" ("account_id");
CREATE INDEX "index_csat_survey_responses_on_assigned_agent_id" ON "csat_survey_responses" ("assigned_agent_id");
CREATE INDEX "index_csat_survey_responses_on_contact_id" ON "csat_survey_responses" ("contact_id");
CREATE INDEX "index_csat_survey_responses_on_conversation_id" ON "csat_survey_responses" ("conversation_id");
CREATE UNIQUE INDEX "index_csat_survey_responses_on_message_id" ON "csat_survey_responses" ("message_id");

CREATE INDEX "index_custom_attribute_definitions_on_account_id" ON "custom_attribute_definitions" ("account_id");
CREATE UNIQUE INDEX "attribute_key_model_index" ON "custom_attribute_definitions" ("attribute_key", "attribute_model", "account_id");

CREATE INDEX "index_custom_filters_on_account_id" ON "custom_filters" ("account_id");
CREATE INDEX "index_custom_filters_on_user_id" ON "custom_filters" ("user_id");

CREATE INDEX "index_custom_role_audit_logs_on_account_id" ON "custom_role_audit_logs" ("account_id");
CREATE INDEX "index_custom_role_audit_logs_on_action" ON "custom_role_audit_logs" ("action");
CREATE INDEX "index_custom_role_audit_logs_on_change_data" ON "custom_role_audit_logs" USING gin ("change_data");
CREATE INDEX "index_custom_role_audit_logs_on_created_at" ON "custom_role_audit_logs" ("created_at");
CREATE INDEX "index_custom_role_audit_logs_on_custom_role_id" ON "custom_role_audit_logs" ("custom_role_id");
CREATE INDEX "index_custom_role_audit_logs_on_target_user_id" ON "custom_role_audit_logs" ("target_user_id");
CREATE INDEX "index_custom_role_audit_logs_on_user_id" ON "custom_role_audit_logs" ("user_id");

CREATE INDEX "index_custom_role_templates_on_category" ON "custom_role_templates" ("category");
CREATE INDEX "index_custom_role_templates_on_is_system" ON "custom_role_templates" ("is_system");
CREATE UNIQUE INDEX "index_custom_role_templates_on_name" ON "custom_role_templates" ("name");

CREATE UNIQUE INDEX "index_custom_roles_on_account_id_and_name" ON "custom_roles" ("account_id", "name");
CREATE UNIQUE INDEX "index_custom_roles_unique_name_per_account" ON "custom_roles" ("account_id", "name");
CREATE INDEX "index_custom_roles_on_account_id" ON "custom_roles" ("account_id");
CREATE INDEX "index_custom_roles_on_is_system" ON "custom_roles" ("is_system");
CREATE INDEX "index_custom_roles_on_parent_id" ON "custom_roles" ("parent_id");

CREATE INDEX "index_dashboard_apps_on_account_id" ON "dashboard_apps" ("account_id");
CREATE INDEX "index_dashboard_apps_on_user_id" ON "dashboard_apps" ("user_id");

CREATE INDEX "index_data_imports_on_account_id" ON "data_imports" ("account_id");

CREATE UNIQUE INDEX "index_email_templates_on_name_and_account_id" ON "email_templates" ("name", "account_id");

CREATE INDEX "index_inbox_assignment_policies_on_assignment_policy_id" ON "inbox_assignment_policies" ("assignment_policy_id");
CREATE UNIQUE INDEX "index_inbox_assignment_policies_on_inbox_id" ON "inbox_assignment_policies" ("inbox_id");

CREATE UNIQUE INDEX "idx_on_agent_capacity_policy_id_inbox_id_71c7ec4caf" ON "inbox_capacity_limits" ("agent_capacity_policy_id", "inbox_id");
CREATE INDEX "index_inbox_capacity_limits_on_agent_capacity_policy_id" ON "inbox_capacity_limits" ("agent_capacity_policy_id");
CREATE INDEX "index_inbox_capacity_limits_on_inbox_id" ON "inbox_capacity_limits" ("inbox_id");

CREATE UNIQUE INDEX "index_inbox_members_on_inbox_id_and_user_id" ON "inbox_members" ("inbox_id", "user_id");
CREATE INDEX "index_inbox_members_on_inbox_id" ON "inbox_members" ("inbox_id");

CREATE INDEX "index_inboxes_on_account_id" ON "inboxes" ("account_id");
CREATE INDEX "index_inboxes_on_channel_id_and_channel_type" ON "inboxes" ("channel_id", "channel_type");
CREATE INDEX "index_inboxes_on_portal_id" ON "inboxes" ("portal_id");

CREATE UNIQUE INDEX "index_installation_configs_on_name_and_created_at" ON "installation_configs" ("name", "created_at");
CREATE UNIQUE INDEX "index_installation_configs_on_name" ON "installation_configs" ("name");

CREATE INDEX "index_labels_on_account_id" ON "labels" ("account_id");
CREATE UNIQUE INDEX "index_labels_on_title_and_account_id" ON "labels" ("title", "account_id");

CREATE INDEX "index_leaves_on_account_id_and_status" ON "leaves" ("account_id", "status");
CREATE INDEX "index_leaves_on_account_id" ON "leaves" ("account_id");
CREATE INDEX "index_leaves_on_approved_by_id" ON "leaves" ("approved_by_id");
CREATE INDEX "index_leaves_on_user_id" ON "leaves" ("user_id");

CREATE INDEX "index_macros_on_account_id" ON "macros" ("account_id");

CREATE INDEX "index_mentions_on_account_id" ON "mentions" ("account_id");
CREATE INDEX "index_mentions_on_conversation_id" ON "mentions" ("conversation_id");
CREATE UNIQUE INDEX "index_mentions_on_user_id_and_conversation_id" ON "mentions" ("user_id", "conversation_id");
CREATE INDEX "index_mentions_on_user_id" ON "mentions" ("user_id");

CREATE INDEX "index_messages_on_additional_attributes_campaign_id" ON "messages" USING gin (("additional_attributes" -> 'campaign_id'));
CREATE INDEX "idx_messages_account_content_created" ON "messages" ("account_id", "content_type", "created_at");
CREATE INDEX "index_messages_on_account_created_type" ON "messages" ("account_id", "created_at", "message_type");
CREATE INDEX "index_messages_on_account_id_and_inbox_id" ON "messages" ("account_id", "inbox_id");
CREATE INDEX "index_messages_on_account_id" ON "messages" ("account_id");
CREATE INDEX "index_messages_on_content" ON "messages" USING gin ("content" gin_trgm_ops);
CREATE INDEX "index_messages_on_conversation_account_type_created" ON "messages" ("conversation_id", "account_id", "message_type", "created_at");
CREATE INDEX "index_messages_on_conversation_id" ON "messages" ("conversation_id");
CREATE INDEX "index_messages_on_created_at" ON "messages" ("created_at");
CREATE INDEX "index_messages_on_inbox_id" ON "messages" ("inbox_id");
CREATE INDEX "index_messages_on_sender_type_and_sender_id" ON "messages" ("sender_type", "sender_id");
CREATE INDEX "index_messages_on_source_id" ON "messages" ("source_id");

CREATE INDEX "index_notes_on_account_id" ON "notes" ("account_id");
CREATE INDEX "index_notes_on_contact_id" ON "notes" ("contact_id");
CREATE INDEX "index_notes_on_user_id" ON "notes" ("user_id");

CREATE UNIQUE INDEX "by_account_user" ON "notification_settings" ("account_id", "user_id");

CREATE UNIQUE INDEX "index_notification_subscriptions_on_identifier" ON "notification_subscriptions" ("identifier");
CREATE INDEX "index_notification_subscriptions_on_user_id" ON "notification_subscriptions" ("user_id");

CREATE INDEX "index_notifications_on_account_id" ON "notifications" ("account_id");
CREATE INDEX "index_notifications_on_last_activity_at" ON "notifications" ("last_activity_at");
CREATE INDEX "uniq_primary_actor_per_account_notifications" ON "notifications" ("primary_actor_type", "primary_actor_id");
CREATE INDEX "uniq_secondary_actor_per_account_notifications" ON "notifications" ("secondary_actor_type", "secondary_actor_id");
CREATE INDEX "idx_notifications_performance" ON "notifications" ("user_id", "account_id", "snoozed_until", "read_at");
CREATE INDEX "index_notifications_on_user_id" ON "notifications" ("user_id");

CREATE INDEX "index_platform_app_permissibles_on_permissibles" ON "platform_app_permissibles" ("permissible_type", "permissible_id");
CREATE UNIQUE INDEX "unique_permissibles_index" ON "platform_app_permissibles" ("platform_app_id", "permissible_id", "permissible_type");
CREATE INDEX "index_platform_app_permissibles_on_platform_app_id" ON "platform_app_permissibles" ("platform_app_id");

CREATE INDEX "index_portals_on_channel_web_widget_id" ON "portals" ("channel_web_widget_id");
CREATE UNIQUE INDEX "index_portals_on_custom_domain" ON "portals" ("custom_domain");
CREATE UNIQUE INDEX "index_portals_on_slug" ON "portals" ("slug");

CREATE UNIQUE INDEX "index_portals_members_on_portal_id_and_user_id" ON "portals_members" ("portal_id", "user_id");
CREATE INDEX "index_portals_members_on_portal_id" ON "portals_members" ("portal_id");
CREATE INDEX "index_portals_members_on_user_id" ON "portals_members" ("user_id");

CREATE UNIQUE INDEX "index_related_categories_on_category_id_and_related_category_id" ON "related_categories" ("category_id", "related_category_id");
CREATE UNIQUE INDEX "index_related_categories_on_related_category_id_and_category_id" ON "related_categories" ("related_category_id", "category_id");

CREATE INDEX "reporting_events__account_id__name__created_at" ON "reporting_events" ("account_id", "name", "created_at");
CREATE INDEX "index_reporting_events_on_account_id" ON "reporting_events" ("account_id");
CREATE INDEX "index_reporting_events_on_conversation_id" ON "reporting_events" ("conversation_id");
CREATE INDEX "index_reporting_events_on_created_at" ON "reporting_events" ("created_at");
CREATE INDEX "index_reporting_events_on_inbox_id" ON "reporting_events" ("inbox_id");
CREATE INDEX "index_reporting_events_on_name" ON "reporting_events" ("name");
CREATE INDEX "index_reporting_events_on_user_id" ON "reporting_events" ("user_id");

CREATE INDEX "index_sla_events_on_account_id" ON "sla_events" ("account_id");
CREATE INDEX "index_sla_events_on_applied_sla_id" ON "sla_events" ("applied_sla_id");
CREATE INDEX "index_sla_events_on_conversation_id" ON "sla_events" ("conversation_id");
CREATE INDEX "index_sla_events_on_inbox_id" ON "sla_events" ("inbox_id");
CREATE INDEX "index_sla_events_on_sla_policy_id" ON "sla_events" ("sla_policy_id");

CREATE INDEX "index_sla_policies_on_account_id" ON "sla_policies" ("account_id");

CREATE INDEX "index_taggings_on_context" ON "taggings" ("context");
CREATE UNIQUE INDEX "taggings_idx" ON "taggings" ("tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type");
CREATE INDEX "index_taggings_on_tag_id" ON "taggings" ("tag_id");
CREATE INDEX "index_taggings_on_taggable_id_and_taggable_type_and_context" ON "taggings" ("taggable_id", "taggable_type", "context");
CREATE INDEX "taggings_idy" ON "taggings" ("taggable_id", "taggable_type", "tagger_id", "context");
CREATE INDEX "index_taggings_on_taggable_id" ON "taggings" ("taggable_id");
CREATE INDEX "index_taggings_on_taggable_type" ON "taggings" ("taggable_type");
CREATE INDEX "index_taggings_on_tagger_id_and_tagger_type" ON "taggings" ("tagger_id", "tagger_type");
CREATE INDEX "index_taggings_on_tagger_id" ON "taggings" ("tagger_id");

CREATE INDEX "tags_name_trgm_idx" ON "tags" USING gin (lower("name") gin_trgm_ops);
CREATE UNIQUE INDEX "index_tags_on_name" ON "tags" ("name");

CREATE UNIQUE INDEX "index_team_members_on_team_id_and_user_id" ON "team_members" ("team_id", "user_id");
CREATE INDEX "index_team_members_on_team_id" ON "team_members" ("team_id");
CREATE INDEX "index_team_members_on_user_id" ON "team_members" ("user_id");

CREATE INDEX "index_teams_on_account_id" ON "teams" ("account_id");
CREATE UNIQUE INDEX "index_teams_on_name_and_account_id" ON "teams" ("name", "account_id");

CREATE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_pubsub_token" ON "users" ("pubsub_token");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE UNIQUE INDEX "index_users_on_uid_and_provider" ON "users" ("uid", "provider");

CREATE UNIQUE INDEX "index_webhooks_on_account_id_and_url" ON "webhooks" ("account_id", "url");

CREATE INDEX "index_working_hours_on_account_id" ON "working_hours" ("account_id");
CREATE INDEX "index_working_hours_on_inbox_id" ON "working_hours" ("inbox_id");

-- Add Foreign Key Constraints
ALTER TABLE "account_users" ADD FOREIGN KEY ("custom_role_id") REFERENCES "custom_roles" ("id") ON DELETE SET NULL;
ALTER TABLE "active_storage_attachments" ADD FOREIGN KEY ("blob_id") REFERENCES "active_storage_blobs" ("id");
ALTER TABLE "active_storage_variant_records" ADD FOREIGN KEY ("blob_id") REFERENCES "active_storage_blobs" ("id");
ALTER TABLE "custom_role_audit_logs" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");
ALTER TABLE "custom_role_audit_logs" ADD FOREIGN KEY ("custom_role_id") REFERENCES "custom_roles" ("id");
ALTER TABLE "custom_role_audit_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "custom_role_audit_logs" ADD FOREIGN KEY ("target_user_id") REFERENCES "users" ("id");
ALTER TABLE "custom_roles" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE CASCADE;
ALTER TABLE "custom_roles" ADD FOREIGN KEY ("parent_id") REFERENCES "custom_roles" ("id");
ALTER TABLE "inboxes" ADD FOREIGN KEY ("portal_id") REFERENCES "portals" ("id");

-- Create sequences for display_id generation
-- This function will be called by the trigger to create sequences for each account
CREATE OR REPLACE FUNCTION create_conv_sequence() RETURNS TRIGGER AS $$
BEGIN
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS conv_dpid_seq_%s', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create conversation display_id sequence when account is created
CREATE TRIGGER accounts_after_insert_row_tr
    AFTER INSERT ON accounts
    FOR EACH ROW
    EXECUTE FUNCTION create_conv_sequence();

-- Function to set display_id for conversations
CREATE OR REPLACE FUNCTION set_conversation_display_id() RETURNS TRIGGER AS $$
BEGIN
    NEW.display_id := nextval('conv_dpid_seq_' || NEW.account_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to set display_id before conversation insert
CREATE TRIGGER conversations_before_insert_row_tr
    BEFORE INSERT ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION set_conversation_display_id();

-- Create sequences for campaign display_id generation
CREATE OR REPLACE FUNCTION create_camp_sequence() RETURNS TRIGGER AS $$
BEGIN
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS camp_dpid_seq_%s', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create campaign display_id sequence when account is created
CREATE TRIGGER camp_dpid_before_insert
    AFTER INSERT ON accounts
    FOR EACH ROW
    EXECUTE FUNCTION create_camp_sequence();

-- Function to set display_id for campaigns
CREATE OR REPLACE FUNCTION set_campaign_display_id() RETURNS TRIGGER AS $$
BEGIN
    NEW.display_id := nextval('camp_dpid_seq_' || NEW.account_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to set display_id before campaign insert
CREATE TRIGGER campaigns_before_insert_row_tr
    BEFORE INSERT ON campaigns
    FOR EACH ROW
    EXECUTE FUNCTION set_campaign_display_id();