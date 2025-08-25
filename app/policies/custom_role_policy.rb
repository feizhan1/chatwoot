# Self-developed Custom Role Policy
# This policy controls access to custom roles functionality
# Completely self-developed without dependencies on enterprise modules

class CustomRolePolicy < ApplicationPolicy
  # The record is a CustomRole instance
  # The user context comes from ApplicationPolicy and represents the account_user

  def index?
    administrator?
  end

  def show?
    administrator? && same_account?
  end

  def create?
    administrator?
  end

  def update?
    administrator? && same_account?
  end

  def destroy?
    administrator? && same_account? && record.deletable?
  end

  # Scope class for filtering records based on user permissions
  class Scope < Scope
    def resolve
      if user.administrator?
        # Administrators can see all custom roles in their account
        scope.where(account: user.account)
      else
        # Non-administrators cannot access custom roles management
        scope.none
      end
    end
  end

  private

  # Check if the current user is an administrator
  def administrator?
    user.administrator?
  end

  # Check if the custom role belongs to the same account as the user
  def same_account?
    record.account_id == user.account_id
  end

  # Additional permission checks can be added here as needed
  # For example, checking for specific permissions in the future

  def has_custom_role_management_permission?
    # For now, only administrators can manage custom roles
    # This can be extended in the future if needed
    administrator?
  end
end