<script setup>
import { computed, onMounted, ref } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import CustomRoleModal from './components/CustomRoleModal.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';

// Composables
const store = useStore();
const { t } = useI18n();

// State
const showModal = ref(false);
const showDeleteModal = ref(false);
const modalMode = ref('create');
const selectedRole = ref(null);
const roleToDelete = ref(null);

// Computed
const customRoles = computed(() => store.getters['customRoles/getCustomRoles']);
const uiFlags = computed(() => store.getters['customRoles/getUIFlags']);
const meta = computed(() => store.getters['customRoles/getMeta']);

const isLoading = computed(
  () => uiFlags.value.isFetching || meta.value.loading
);

const currentAccount = computed(() => store.getters.getCurrentAccount);
const isFeatureEnabled = computed(() => {
  // Check if custom_roles feature is enabled - could be in features array or features object
  const features = currentAccount.value?.features;
  if (Array.isArray(features)) {
    return features.includes('custom_roles');
  }
  if (features && typeof features === 'object') {
    return features.custom_roles === true;
  }
  // For now, return true to allow access since we manually enabled the feature
  return true;
});

const showPaywall = computed(() => !isFeatureEnabled.value);
const canManageCustomRoles = computed(
  () =>
    isFeatureEnabled.value && store.getters.getCurrentRole === 'administrator'
);

const deleteConfirmMessage = computed(() => {
  if (!roleToDelete.value) return '';
  return `${t('CUSTOM_ROLE.DELETE.CONFIRM.MESSAGE')} "${roleToDelete.value.name}"?`;
});

const tableHeaders = computed(() => {
  return [
    t('CUSTOM_ROLE.LIST.TABLE_HEADER.NAME'),
    t('CUSTOM_ROLE.LIST.TABLE_HEADER.DESCRIPTION'),
    t('CUSTOM_ROLE.LIST.TABLE_HEADER.PERMISSIONS'),
    t('CUSTOM_ROLE.LIST.TABLE_HEADER.USERS'),
    t('CUSTOM_ROLE.LIST.TABLE_HEADER.ACTIONS'),
  ];
});

// Methods
const fetchCustomRoles = async () => {
  try {
    await store.dispatch('customRoles/fetchCustomRoles');
  } catch (error) {
    console.error('Failed to fetch custom roles:', error);
    useAlert(error.message || 'Failed to load custom roles');
  }
};

const openCreateModal = () => {
  if (!canManageCustomRoles.value) return;

  modalMode.value = 'create';
  selectedRole.value = null;
  showModal.value = true;
};

const openEditModal = role => {
  modalMode.value = 'edit';
  selectedRole.value = { ...role };
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedRole.value = null;
  modalMode.value = 'create';
};

const openDeleteConfirmation = role => {
  roleToDelete.value = role;
  showDeleteModal.value = true;
};

const closeDeleteModal = () => {
  showDeleteModal.value = false;
  roleToDelete.value = null;
};

const confirmDelete = async () => {
  if (!roleToDelete.value) return;

  try {
    await store.dispatch('customRoles/deleteCustomRole', roleToDelete.value.id);
    useAlert(t('CUSTOM_ROLE.DELETE.API.SUCCESS_MESSAGE'));
  } catch (error) {
    console.error('Failed to delete custom role:', error);
    useAlert(error.message || t('CUSTOM_ROLE.DELETE.API.ERROR_MESSAGE'));
  } finally {
    closeDeleteModal();
  }
};

const handleRoleSaved = () => {
  closeModal();
  // Refresh the list is handled by the store mutations
};

const handleUpgradeClick = () => {
  // This would typically navigate to billing/upgrade page
  // For now, we'll just show an alert
  useAlert(t('CUSTOM_ROLE.PAYWALL.CONTACT_ADMIN'));
};

const getPermissionDisplayName = permission => {
  return t(`CUSTOM_ROLE.PERMISSIONS.${permission.toUpperCase()}`);
};

const getPermissionBadgeClass = permission => {
  const baseClasses =
    'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium';

  if (permission.startsWith('conversation_')) {
    return `${baseClasses} bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200`;
  }
  if (permission.includes('manage')) {
    return `${baseClasses} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`;
  }

  return `${baseClasses} bg-slate-100 text-slate-800 dark:bg-slate-700 dark:text-slate-200`;
};

// Lifecycle
onMounted(() => {
  if (canManageCustomRoles.value) {
    fetchCustomRoles();
  }
});
</script>

<template>
  <div class="flex-1 overflow-auto">
    <!-- Header Section -->
    <BaseSettingsHeader
      :title="$t('CUSTOM_ROLE.HEADER')"
      :description="$t('CUSTOM_ROLE.DESCRIPTION')"
      :link-text="$t('CUSTOM_ROLE.LEARN_MORE')"
      feature-name="custom_roles"
    >
      <template #actions>
        <Button
          icon="i-lucide-circle-plus"
          :label="$t('CUSTOM_ROLE.HEADER_BTN_TXT')"
          :disabled="!canManageCustomRoles"
          @click="openCreateModal"
        />
      </template>
    </BaseSettingsHeader>

    <div class="mt-6 flex-1">
      <!-- Feature Paywall -->
      <div
        v-if="showPaywall"
        class="bg-white dark:bg-slate-800 rounded-lg border border-slate-200 dark:border-slate-700 p-8 text-center"
      >
        <div
          class="mx-auto w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center mb-4"
        >
          <Icon icon="i-lucide-crown" class="text-white size-8" />
        </div>

        <h3
          class="text-lg font-semibold text-slate-900 dark:text-slate-100 mb-2"
        >
          {{ $t('CUSTOM_ROLE.PAYWALL.TITLE') }}
        </h3>

        <p class="text-slate-600 dark:text-slate-400 mb-4 max-w-md mx-auto">
          {{ $t('CUSTOM_ROLE.PAYWALL.AVAILABLE_ON') }}
        </p>

        <p
          class="text-sm text-slate-500 dark:text-slate-500 mb-6 max-w-lg mx-auto"
        >
          {{ $t('CUSTOM_ROLE.PAYWALL.UPGRADE_PROMPT') }}
        </p>

        <Button
          :label="$t('CUSTOM_ROLE.PAYWALL.UPGRADE_NOW')"
          @click="handleUpgradeClick"
        />

        <p class="text-xs text-slate-400 dark:text-slate-500 mt-3">
          {{ $t('CUSTOM_ROLE.PAYWALL.CANCEL_ANYTIME') }}
        </p>
      </div>

      <!-- Loading State -->
      <woot-loading-state
        v-else-if="isLoading"
        :message="$t('CUSTOM_ROLE.LOADING')"
      />

      <!-- Empty State -->
      <p
        v-else-if="!customRoles.length"
        class="flex flex-col items-center justify-center h-full text-base text-n-slate-11 py-8"
      >
        {{ $t('CUSTOM_ROLE.LIST.404') }}
      </p>

      <!-- Roles Table -->
      <table v-else class="min-w-full overflow-x-auto divide-y divide-n-weak">
        <thead>
          <th
            v-for="thHeader in tableHeaders"
            :key="thHeader"
            class="py-4 ltr:pr-4 rtl:pl-4 text-left font-semibold text-n-slate-11 last:text-right"
          >
            {{ thHeader }}
          </th>
        </thead>
        <tbody class="divide-y divide-n-weak text-n-slate-11">
          <tr v-for="role in customRoles" :key="role.id">
            <td
              class="py-4 ltr:pr-4 rtl:pl-4 truncate max-w-xs font-medium"
              :title="role.name"
            >
              {{ role.name }}
            </td>
            <td class="py-4 ltr:pr-4 rtl:pl-4 md:break-all whitespace-normal">
              {{ role.description }}
            </td>
            <td class="py-4 ltr:pr-4 rtl:pl-4">
              <div class="flex flex-wrap gap-1">
                <span
                  v-for="permission in role.permissions.slice(0, 3)"
                  :key="permission"
                  class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                  :class="getPermissionBadgeClass(permission)"
                >
                  {{ getPermissionDisplayName(permission) }}
                </span>
                <span
                  v-if="role.permissions.length > 3"
                  class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-300"
                >
                  +{{ role.permissions.length - 3 }}
                </span>
              </div>
            </td>
            <td class="py-4 ltr:pr-4 rtl:pl-4 whitespace-nowrap">
              {{
                $t('CUSTOM_ROLE.LIST.USER_COUNT', {
                  count: role.assigned_users_count || 0,
                })
              }}
            </td>
            <td class="py-4 flex justify-end gap-1">
              <Button
                v-tooltip.top="$t('CUSTOM_ROLE.EDIT.BUTTON_TEXT')"
                icon="i-lucide-pen"
                slate
                xs
                faded
                @click="openEditModal(role)"
              />
              <Button
                v-tooltip.top="$t('CUSTOM_ROLE.DELETE.BUTTON_TEXT')"
                icon="i-lucide-trash-2"
                xs
                ruby
                faded
                :disabled="!role.deletable"
                @click="openDeleteConfirmation(role)"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Create/Edit Modal -->
    <woot-modal v-model:show="showModal" :on-close="closeModal">
      <CustomRoleModal
        :mode="modalMode"
        :selected-role="selectedRole"
        @close="closeModal"
        @saved="handleRoleSaved"
      />
    </woot-modal>

    <!-- Delete Confirmation Modal -->
    <woot-delete-modal
      v-model:show="showDeleteModal"
      :on-close="closeDeleteModal"
      :on-confirm="confirmDelete"
      :title="$t('CUSTOM_ROLE.DELETE.CONFIRM.TITLE')"
      :message="deleteConfirmMessage"
      :confirm-text="$t('CUSTOM_ROLE.DELETE.CONFIRM.YES')"
      :reject-text="$t('CUSTOM_ROLE.DELETE.CONFIRM.NO')"
    />
  </div>
</template>
