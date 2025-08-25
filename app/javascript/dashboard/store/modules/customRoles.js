// Self-developed Custom Roles Vuex Store Module
// This is a completely self-developed state management module for custom roles
// without any dependencies on existing enterprise modules

// import { throwErrorMessage } from 'dashboard/store/utils/api';
import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import * as types from '../mutation-types';
import CustomRolesAPI from '../../api/customRoles';

// State
export const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
  selectedRole: null,
  meta: {
    total: 0,
    loading: false,
    error: null,
  },
};

// Getters
export const getters = {
  getCustomRoles: $state => $state.records,
  getUIFlags: $state => $state.uiFlags,
  getSelectedRole: $state => $state.selectedRole,
  getMeta: $state => $state.meta,

  // Get custom role by ID
  getCustomRoleById: $state => id => {
    return $state.records.find(role => role.id === parseInt(id, 10));
  },

  // Get roles with specific permission
  getRolesWithPermission: $state => permission => {
    return $state.records.filter(
      role => role.permissions && role.permissions.includes(permission)
    );
  },

  // Check if any role is being processed
  isAnyRoleProcessing: $state => {
    return Object.values($state.uiFlags).some(flag => flag === true);
  },

  // Get available permissions for UI
  getAvailablePermissions: () => CustomRolesAPI.getAvailablePermissions(),

  // Get permission descriptions for UI
  getPermissionDescriptions: () => CustomRolesAPI.getPermissionDescriptions(),

  // Get permission categories for UI
  getPermissionCategories: () => CustomRolesAPI.getPermissionCategories(),
};

// Actions
export const actions = {
  // Fetch all custom roles
  async fetchCustomRoles({ commit }) {
    commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isFetching: true });
    commit(types.default.SET_CUSTOM_ROLES_META, { loading: true, error: null });

    try {
      const response = await CustomRolesAPI.getCustomRoles();

      commit(types.default.SET_CUSTOM_ROLES, response.data);
      commit(types.default.SET_CUSTOM_ROLES_META, {
        total: response.data.length,
        loading: false,
        error: null,
      });
    } catch (error) {
      // console.error('Error fetching custom roles:', error);

      commit(types.default.SET_CUSTOM_ROLES_META, {
        loading: false,
        error: error.message || 'Failed to fetch custom roles',
      });

      throw error;
    } finally {
      commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isFetching: false });
    }
  },

  // Fetch a specific custom role
  async fetchCustomRole({ commit }, roleId) {
    try {
      const response = await CustomRolesAPI.getCustomRole(roleId);
      commit(types.default.SET_SELECTED_CUSTOM_ROLE, response.data);
      return response.data;
    } catch (error) {
      // console.error('Error fetching custom role:', error);
      throw error;
    }
  },

  // Create a new custom role
  async createCustomRole({ commit }, roleData) {
    commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isCreating: true });

    try {
      // Validate data before API call
      const validation = CustomRolesAPI.validateCustomRoleData(roleData);
      if (!validation.isValid) {
        const validationError = new Error('Validation failed');
        validationError.validationErrors = validation.errors;
        throw validationError;
      }

      const response = await CustomRolesAPI.createCustomRole(roleData);

      commit(types.default.ADD_CUSTOM_ROLE, response.data);
      commit(types.default.SET_CUSTOM_ROLES_META, {
        total: state.records.length,
        error: null,
      });

      return response.data;
    } catch (error) {
      // console.error('Error creating custom role:', error);
      throw error;
    } finally {
      commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isCreating: false });
    }
  },

  // Update an existing custom role
  async updateCustomRole({ commit }, { id, ...updateData }) {
    commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isUpdating: true });

    try {
      // Validate data before API call
      const validation = CustomRolesAPI.validateCustomRoleData(updateData);
      if (!validation.isValid) {
        const validationError = new Error('Validation failed');
        validationError.validationErrors = validation.errors;
        throw validationError;
      }

      const response = await CustomRolesAPI.updateCustomRole(id, updateData);

      commit(types.default.EDIT_CUSTOM_ROLE, response.data);
      commit(types.default.SET_CUSTOM_ROLES_META, { error: null });

      return response.data;
    } catch (error) {
      // console.error('Error updating custom role:', error);
      throw error;
    } finally {
      commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isUpdating: false });
    }
  },

  // Delete a custom role
  async deleteCustomRole({ commit }, roleId) {
    commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isDeleting: true });

    try {
      await CustomRolesAPI.deleteCustomRole(roleId);

      commit(types.default.DELETE_CUSTOM_ROLE, roleId);
      commit(types.default.SET_CUSTOM_ROLES_META, {
        total: state.records.length,
        error: null,
      });

      return roleId;
    } catch (error) {
      // console.error('Error deleting custom role:', error);
      throw error;
    } finally {
      commit(types.default.SET_CUSTOM_ROLES_UI_FLAG, { isDeleting: false });
    }
  },

  // Clear selected role
  clearSelectedRole({ commit }) {
    commit(types.default.SET_SELECTED_CUSTOM_ROLE, null);
  },

  // Set selected role
  selectCustomRole({ commit }, role) {
    commit(types.default.SET_SELECTED_CUSTOM_ROLE, role);
  },

  // Clear error state
  clearError({ commit }) {
    commit(types.default.SET_CUSTOM_ROLES_META, { error: null });
  },
};

// Mutations
export const mutations = {
  // Set UI flags
  [types.default.SET_CUSTOM_ROLES_UI_FLAG](_state, uiFlag) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...uiFlag,
    };
  },

  // Set meta information
  [types.default.SET_CUSTOM_ROLES_META](_state, meta) {
    _state.meta = {
      ..._state.meta,
      ...meta,
    };
  },

  // Set selected role
  [types.default.SET_SELECTED_CUSTOM_ROLE](_state, role) {
    _state.selectedRole = role;
  },

  // Standard CRUD mutations using MutationHelpers
  [types.default.SET_CUSTOM_ROLES]: MutationHelpers.set,
  [types.default.ADD_CUSTOM_ROLE]: MutationHelpers.create,
  [types.default.EDIT_CUSTOM_ROLE]: MutationHelpers.update,
  [types.default.DELETE_CUSTOM_ROLE]: MutationHelpers.destroy,
};

// Export the complete module
export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
