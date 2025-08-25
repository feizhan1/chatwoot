# Self-developed Custom Role Support for AccountUser
# This module extends AccountUser with custom role functionality without depending on enterprise modules

module CustomRoleSupport
  extend ActiveSupport::Concern

  included do
    # === Associations ===
    belongs_to :custom_role, optional: true

    # === Validations ===
    validate :custom_role_belongs_to_same_account, if: :custom_role_id?
    validate :cannot_have_both_system_role_and_custom_role, if: :custom_role_id?

    # === Callbacks ===
    before_save :clear_custom_role_if_system_role_changed
  end

  # === Instance Methods ===

  # Override the permissions method to include custom role permissions
  # This method replaces the original permissions method from AccountUser
  def permissions
    if custom_role.present?
      # Custom role users get their custom role permissions plus the 'custom_role' identifier
      custom_role.permissions + ['custom_role']
    else
      # Fall back to the original permissions method for system roles
      administrator? ? ['administrator'] : ['agent']
    end
  end

  # Check if user has a specific permission
  def has_permission?(permission)
    return true if administrator? # Administrators have all permissions
    
    permissions.include?(permission.to_s)
  end

  # Get the effective role type for display purposes
  def effective_role
    if custom_role.present?
      'custom_role'
    else
      role # 'administrator' or 'agent'
    end
  end

  # Get the display name for the user's role
  def role_display_name
    if custom_role.present?
      custom_role.name
    else
      role.humanize
    end
  end

  # Check if user can manage conversations based on their permissions
  def can_manage_conversations?(conversation_scope = :participating)
    return true if administrator?
    return false unless custom_role.present?

    case conversation_scope
    when :all
      has_permission?('conversation_manage')
    when :unassigned
      has_permission?('conversation_manage') || has_permission?('conversation_unassigned_manage')
    when :participating
      has_permission?('conversation_manage') || 
      has_permission?('conversation_unassigned_manage') || 
      has_permission?('conversation_participating_manage')
    else
      false
    end
  end

  # Check if user can manage contacts
  def can_manage_contacts?
    return true if administrator?
    has_permission?('contact_manage')
  end

  # Check if user can manage reports
  def can_manage_reports?
    return true if administrator?
    has_permission?('report_manage')
  end

  # Check if user can manage knowledge base
  def can_manage_knowledge_base?
    return true if administrator?
    has_permission?('knowledge_base_manage')
  end

  # Get conversation permission level for UI logic
  def conversation_permission_level
    return 'administrator' if administrator?
    return 'agent' unless custom_role.present?

    custom_role.conversation_permission_level
  end

  private

  # === Validation Methods ===

  def custom_role_belongs_to_same_account
    return unless custom_role_id? && custom_role.present?

    errors.add(:custom_role, 'must belong to the same account') unless custom_role.account_id == account_id
  end

  def cannot_have_both_system_role_and_custom_role
    return unless custom_role_id?

    # If custom_role is set, the system role should be 'agent' (not administrator)
    # This prevents conflicts where someone has both administrator privileges and custom role
    if administrator?
      errors.add(:base, 'cannot have both administrator role and custom role. Please choose one.')
    end
  end

  # === Callback Methods ===

  def clear_custom_role_if_system_role_changed
    # If the system role changes to administrator, clear custom role to avoid conflicts
    if role_changed? && administrator?
      self.custom_role = nil
    end
  end
end