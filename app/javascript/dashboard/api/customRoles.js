// Self-developed Custom Roles API Client
// This is a completely self-developed implementation for managing custom roles
// without any dependencies on existing enterprise modules

import ApiClient from './ApiClient';

class CustomRolesAPI extends ApiClient {
  constructor() {
    super('custom_roles', { accountScoped: true });
  }

  // Get all custom roles for the current account
  async getCustomRoles() {
    try {
      const response = await this.get();
      return response;
    } catch (error) {
      throw this.handleApiError(error);
    }
  }

  // Get a specific custom role by ID
  async getCustomRole(id) {
    try {
      const response = await this.show(id);
      return response;
    } catch (error) {
      throw this.handleApiError(error);
    }
  }

  // Create a new custom role
  async createCustomRole(customRoleData) {
    try {
      const response = await this.create({ custom_role: customRoleData });
      return response;
    } catch (error) {
      throw this.handleApiError(error);
    }
  }

  // Update an existing custom role
  async updateCustomRole(id, customRoleData) {
    try {
      const response = await this.update(id, { custom_role: customRoleData });
      return response;
    } catch (error) {
      throw this.handleApiError(error);
    }
  }

  // Delete a custom role
  async deleteCustomRole(id) {
    try {
      const response = await this.delete(id);
      return response;
    } catch (error) {
      throw this.handleApiError(error);
    }
  }

  // Get available permissions for custom roles
  getAvailablePermissions() {
    return [
      'conversation_manage',
      'conversation_unassigned_manage',
      'conversation_participating_manage',
      'contact_manage',
      'report_manage',
      'knowledge_base_manage',
    ];
  }

  // Get permission descriptions
  getPermissionDescriptions() {
    return {
      conversation_manage:
        'Can manage all conversations within assigned inboxes',
      conversation_unassigned_manage:
        'Can manage unassigned conversations and those assigned to them',
      conversation_participating_manage:
        'Can manage conversations they are participating in or assigned to',
      contact_manage: 'Can create, update, and manage contacts',
      report_manage: 'Can access and view reports and analytics',
      knowledge_base_manage:
        'Can create, edit, and manage knowledge base articles and portals',
    };
  }

  // Get permission categories for UI organization
  getPermissionCategories() {
    return {
      conversation: [
        'conversation_manage',
        'conversation_unassigned_manage',
        'conversation_participating_manage',
      ],
      management: ['contact_manage', 'report_manage', 'knowledge_base_manage'],
    };
  }

  // Validate custom role data before API call
  validateCustomRoleData(data) {
    const errors = {};

    // Name validation
    if (!data.name || data.name.trim().length === 0) {
      errors.name = 'Name is required';
    } else if (data.name.trim().length < 2) {
      errors.name = 'Name must be at least 2 characters long';
    } else if (data.name.trim().length > 100) {
      errors.name = 'Name cannot exceed 100 characters';
    }

    // Description validation
    if (!data.description || data.description.trim().length === 0) {
      errors.description = 'Description is required';
    } else if (data.description.trim().length > 500) {
      errors.description = 'Description cannot exceed 500 characters';
    }

    // Permissions validation
    if (
      !data.permissions ||
      !Array.isArray(data.permissions) ||
      data.permissions.length === 0
    ) {
      errors.permissions = 'At least one permission must be selected';
    } else {
      const validPermissions = this.getAvailablePermissions();
      const invalidPermissions = data.permissions.filter(
        p => !validPermissions.includes(p)
      );

      if (invalidPermissions.length > 0) {
        errors.permissions = `Invalid permissions: ${invalidPermissions.join(', ')}`;
      }

      // Check for conflicting conversation permissions
      const conversationPermissions = data.permissions.filter(p =>
        [
          'conversation_manage',
          'conversation_unassigned_manage',
          'conversation_participating_manage',
        ].includes(p)
      );

      if (conversationPermissions.length > 1) {
        errors.permissions =
          'Only one conversation management permission can be selected';
      }
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors,
    };
  }

  // Handle API errors with user-friendly messages
  handleApiError(error) {
    const errorData = {
      message: 'An unexpected error occurred',
      details: null,
      status: error.status || 500,
    };

    if (error.response && error.response.data) {
      const responseData = error.response.data;

      switch (error.status) {
        case 403:
          if (responseData.error === 'FEATURE_NOT_ENABLED') {
            errorData.message =
              'Custom roles feature is not available on your current plan';
            errorData.upgradeRequired = true;
          } else {
            errorData.message =
              'You do not have permission to perform this action';
          }
          break;
        case 404:
          errorData.message = 'Custom role not found';
          break;
        case 422:
          if (responseData.error === 'VALIDATION_FAILED') {
            errorData.message = 'Validation failed';
            errorData.validationErrors = responseData.field_errors || {};
            errorData.details = responseData.details || [];
          } else if (responseData.error === 'ROLE_HAS_ASSIGNED_USERS') {
            errorData.message = 'Cannot delete role with assigned users';
            errorData.assignedUsersCount =
              responseData.details?.assigned_users_count || 0;
          } else {
            errorData.message = responseData.message || 'Invalid request';
          }
          break;
        default:
          errorData.message =
            responseData.message ||
            'An error occurred while processing your request';
      }

      errorData.details = responseData.details;
    }

    return errorData;
  }
}

// Export singleton instance
export default new CustomRolesAPI();
