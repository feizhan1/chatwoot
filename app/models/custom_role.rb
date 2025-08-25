# == Schema Information
#
# Table name: custom_roles
#
#  id          :bigint           not null, primary key
#  description :string
#  is_system   :boolean          default(FALSE), not null
#  name        :string
#  permissions :text             default([]), is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#  parent_id   :bigint
#
# Indexes
#
#  index_custom_roles_on_account_id            (account_id)
#  index_custom_roles_on_account_id_and_name   (account_id,name) UNIQUE
#  index_custom_roles_on_is_system             (is_system)
#  index_custom_roles_on_parent_id             (parent_id)
#  index_custom_roles_unique_name_per_account  (account_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#  fk_rails_...  (parent_id => custom_roles.id)
#

class CustomRole < ApplicationRecord
  # === Associations ===
  belongs_to :account
  has_many :account_users, dependent: :nullify

  # === Constants ===
  # The 6 official permissions exactly as per Chatwoot Enterprise specification
  PERMISSIONS = %w[
    conversation_manage
    conversation_unassigned_manage
    conversation_participating_manage
    contact_manage
    report_manage
    knowledge_base_manage
  ].freeze

  # Permission descriptions mapping
  PERMISSION_DESCRIPTIONS = {
    'conversation_manage' => 'Can manage all conversations within assigned inboxes',
    'conversation_unassigned_manage' => 'Can manage unassigned conversations and those assigned to them',
    'conversation_participating_manage' => 'Can manage conversations they are participating in or assigned to',
    'contact_manage' => 'Can create, update, and manage contacts',
    'report_manage' => 'Can access and view reports and analytics',
    'knowledge_base_manage' => 'Can create, edit, and manage knowledge base articles and portals'
  }.freeze

  # Permission categories for UI organization
  PERMISSION_CATEGORIES = {
    'conversation' => %w[conversation_manage conversation_unassigned_manage conversation_participating_manage],
    'management' => %w[contact_manage report_manage knowledge_base_manage]
  }.freeze

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :name, uniqueness: { scope: :account_id, message: 'must be unique within account' }
  validates :description, presence: true, length: { minimum: 1, maximum: 500 }
  validates :permissions, presence: true, length: { minimum: 1, message: 'at least one permission must be selected' }
  validate :permissions_must_be_valid
  validate :permissions_must_be_array
  validate :no_conflicting_conversation_permissions

  # === Scopes ===
  scope :by_account, ->(account) { where(account: account) }
  scope :with_permission, ->(permission) { where('? = ANY(permissions)', permission) }
  scope :ordered, -> { order(:name) }

  # === Instance Methods ===

  # Check if role has a specific permission
  def has_permission?(permission)
    permissions.include?(permission.to_s)
  end

  # Check if role can be safely deleted (no users assigned)
  def deletable?
    account_users.empty?
  end

  # Get human-readable description for a permission
  def self.permission_description(permission)
    PERMISSION_DESCRIPTIONS[permission.to_s] || permission.to_s.humanize
  end

  # Get permissions by category for UI display
  def permissions_by_category
    result = {}
    PERMISSION_CATEGORIES.each do |category, category_permissions|
      result[category] = permissions & category_permissions
    end
    result.reject { |_, perms| perms.empty? }
  end

  # Check conversation permission hierarchy for user interface
  def conversation_permission_level
    return 'manage_all' if has_permission?('conversation_manage')
    return 'manage_unassigned' if has_permission?('conversation_unassigned_manage')
    return 'manage_participating' if has_permission?('conversation_participating_manage')
    'none'
  end

  private

  # === Validation Methods ===

  def permissions_must_be_valid
    return unless permissions.is_a?(Array)

    invalid_permissions = permissions - PERMISSIONS
    return if invalid_permissions.empty?

    errors.add(:permissions, "contains invalid permissions: #{invalid_permissions.join(', ')}")
  end

  def permissions_must_be_array
    return if permissions.is_a?(Array)

    errors.add(:permissions, 'must be an array')
  end

  def no_conflicting_conversation_permissions
    return unless permissions.is_a?(Array)

    conversation_permissions = permissions & PERMISSION_CATEGORIES['conversation']
    return if conversation_permissions.length <= 1

    errors.add(:permissions, 'cannot have multiple conversation management permissions. Please select only one.')
  end
end
