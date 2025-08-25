<script setup>
import { computed, ref, watch, onMounted } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Button from 'dashboard/components-next/button/Button.vue';

// Props
const props = defineProps({
  mode: {
    type: String,
    default: 'create',
    validator: value => ['create', 'edit'].includes(value),
  },
  selectedRole: {
    type: Object,
    default: null,
  },
});

// Emits
const emit = defineEmits(['close', 'saved']);

// Composables
const store = useStore();
const { t } = useI18n();

// State
const form = ref({
  name: '',
  description: '',
  permissions: [],
});

const selectedConversationPermission = ref('');
const errors = ref({});
const isSubmitting = ref(false);

// Computed
const isEditMode = computed(() => props.mode === 'edit');

const permissionCategories = computed(
  () => store.getters['customRoles/getPermissionCategories']
);

const conversationPermissions = computed(
  () => permissionCategories.value.conversation || []
);
const managementPermissions = computed(
  () => permissionCategories.value.management || []
);

const allSelectedPermissions = computed(() => {
  const permissions = [...form.value.permissions];
  if (selectedConversationPermission.value) {
    permissions.push(selectedConversationPermission.value);
  }
  return permissions;
});

const isFormValid = computed(() => {
  return (
    form.value.name.trim().length >= 2 &&
    form.value.description.trim().length >= 1 &&
    allSelectedPermissions.value.length > 0 &&
    Object.keys(errors.value).length === 0
  );
});

// Methods
const initializeForm = () => {
  if (isEditMode.value && props.selectedRole) {
    form.value.name = props.selectedRole.name || '';
    form.value.description = props.selectedRole.description || '';

    // Separate conversation permission from others
    const rolePermissions = props.selectedRole.permissions || [];
    const conversationPerm = rolePermissions.find(p =>
      conversationPermissions.value.includes(p)
    );
    const otherPermissions = rolePermissions.filter(
      p => !conversationPermissions.value.includes(p)
    );

    selectedConversationPermission.value = conversationPerm || '';
    form.value.permissions = otherPermissions;
  } else {
    // Reset form for create mode
    form.value.name = '';
    form.value.description = '';
    form.value.permissions = [];
    selectedConversationPermission.value = '';
  }

  errors.value = {};
};

const validateForm = () => {
  const newErrors = {};

  // Name validation
  if (!form.value.name.trim()) {
    newErrors.name = t('CUSTOM_ROLE.FORM.NAME.ERROR');
  } else if (form.value.name.trim().length < 2) {
    newErrors.name = t('CUSTOM_ROLE.FORM.NAME.MIN_LENGTH_ERROR');
  } else if (form.value.name.trim().length > 100) {
    newErrors.name = t('CUSTOM_ROLE.FORM.NAME.MAX_LENGTH_ERROR');
  }

  // Description validation
  if (!form.value.description.trim()) {
    newErrors.description = t('CUSTOM_ROLE.FORM.DESCRIPTION.ERROR');
  } else if (form.value.description.trim().length > 500) {
    newErrors.description = t('CUSTOM_ROLE.FORM.DESCRIPTION.MAX_LENGTH_ERROR');
  }

  // Permissions validation
  if (allSelectedPermissions.value.length === 0) {
    newErrors.permissions = t('CUSTOM_ROLE.FORM.PERMISSIONS.ERROR');
  }

  errors.value = newErrors;
  return Object.keys(newErrors).length === 0;
};

const handleSubmit = async () => {
  if (!validateForm() || isSubmitting.value) return;

  isSubmitting.value = true;

  try {
    const roleData = {
      name: form.value.name.trim(),
      description: form.value.description.trim(),
      permissions: allSelectedPermissions.value,
    };

    if (isEditMode.value) {
      await store.dispatch('customRoles/updateCustomRole', {
        id: props.selectedRole.id,
        ...roleData,
      });
      useAlert(t('CUSTOM_ROLE.EDIT.API.SUCCESS_MESSAGE'));
    } else {
      await store.dispatch('customRoles/createCustomRole', roleData);
      useAlert(t('CUSTOM_ROLE.ADD.API.SUCCESS_MESSAGE'));
    }

    emit('saved');
  } catch (error) {
    console.error('Error saving custom role:', error);

    if (error.validationErrors) {
      errors.value = error.validationErrors;
    } else {
      useAlert(error.message || t('CUSTOM_ROLE.FORM.API.ERROR_MESSAGE'));
    }
  } finally {
    isSubmitting.value = false;
  }
};

const closeModal = () => {
  emit('close');
};

const getFieldError = fieldName => {
  return errors.value[fieldName] || '';
};

const getPermissionTitle = permission => {
  return t(`CUSTOM_ROLE.PERMISSIONS.${permission.toUpperCase()}`);
};

const getPermissionDescription = permission => {
  return t(`CUSTOM_ROLE.PERMISSION_DESCRIPTIONS.${permission.toUpperCase()}`);
};

const getPermissionLevel = permission => {
  const levels = {
    conversation_manage: t(
      'CUSTOM_ROLE.FORM.PERMISSIONS.PERMISSION_LEVELS.HIGHEST'
    ),
    conversation_unassigned_manage: t(
      'CUSTOM_ROLE.FORM.PERMISSIONS.PERMISSION_LEVELS.MEDIUM'
    ),
    conversation_participating_manage: t(
      'CUSTOM_ROLE.FORM.PERMISSIONS.PERMISSION_LEVELS.BASIC'
    ),
  };
  return levels[permission] || '';
};

const getPermissionLevelClass = permission => {
  const classes = {
    conversation_manage:
      'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
    conversation_unassigned_manage:
      'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
    conversation_participating_manage:
      'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  };
  return classes[permission] || '';
};

// Watchers
watch(() => props.selectedRole, initializeForm);
watch([() => form.value.name, () => form.value.description], validateForm);

// Lifecycle
onMounted(initializeForm);
</script>

<template>
  <div class="flex flex-col">
    <!-- Modal Header -->
    <div
      class="flex items-center justify-between p-6 border-b border-slate-200 dark:border-slate-700"
    >
      <div>
        <h2 class="text-lg font-semibold text-slate-900 dark:text-slate-100">
          {{
            isEditMode
              ? $t('CUSTOM_ROLE.EDIT.TITLE')
              : $t('CUSTOM_ROLE.ADD.TITLE')
          }}
        </h2>
        <p class="text-sm text-slate-600 dark:text-slate-400 mt-1">
          {{
            isEditMode
              ? $t('CUSTOM_ROLE.EDIT.DESC')
              : $t('CUSTOM_ROLE.ADD.DESC')
          }}
        </p>
      </div>
    </div>

    <!-- Modal Body -->
    <form class="flex-1 p-6" @submit.prevent="handleSubmit">
      <div class="space-y-6">
        <!-- Role Name -->
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2"
          >
            {{ $t('CUSTOM_ROLE.FORM.NAME.LABEL') }}
            <span class="text-red-500 ml-1">*</span>
          </label>
          <woot-input
            v-model="form.name"
            :placeholder="$t('CUSTOM_ROLE.FORM.NAME.PLACEHOLDER')"
            :error="getFieldError('name')"
            required
          />
          <p v-if="getFieldError('name')" class="mt-1 text-sm text-red-600">
            {{ getFieldError('name') }}
          </p>
        </div>

        <!-- Role Description -->
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2"
          >
            {{ $t('CUSTOM_ROLE.FORM.DESCRIPTION.LABEL') }}
            <span class="text-red-500 ml-1">*</span>
          </label>
          <woot-input
            v-model="form.description"
            :placeholder="$t('CUSTOM_ROLE.FORM.DESCRIPTION.PLACEHOLDER')"
            :error="getFieldError('description')"
            type="textarea"
            :rows="3"
            required
          />
          <p
            v-if="getFieldError('description')"
            class="mt-1 text-sm text-red-600"
          >
            {{ getFieldError('description') }}
          </p>
        </div>

        <!-- Permissions -->
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2"
          >
            {{ $t('CUSTOM_ROLE.FORM.PERMISSIONS.LABEL') }}
            <span class="text-red-500 ml-1">*</span>
          </label>

          <div class="bg-slate-50 dark:bg-slate-800 rounded-lg p-4 space-y-4">
            <!-- Conversation Permissions -->
            <div>
              <h4
                class="text-sm font-semibold text-slate-700 dark:text-slate-300 mb-3"
              >
                {{ $t('CUSTOM_ROLE.FORM.PERMISSIONS.CONVERSATION_MANAGEMENT') }}
              </h4>
              <p class="text-xs text-slate-500 dark:text-slate-400 mb-3">
                {{ $t('CUSTOM_ROLE.FORM.PERMISSIONS.CONVERSATION_HELP_TEXT') }}
              </p>

              <div class="space-y-3">
                <div
                  v-for="permission in conversationPermissions"
                  :key="permission"
                  class="flex items-start space-x-3"
                >
                  <input
                    :id="permission"
                    v-model="selectedConversationPermission"
                    type="radio"
                    :value="permission"
                    name="conversationPermission"
                    class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-slate-300 dark:border-slate-600"
                  />
                  <div class="min-w-0 flex-1">
                    <label
                      :for="permission"
                      class="block text-sm font-medium text-slate-900 dark:text-slate-100 cursor-pointer"
                    >
                      {{ getPermissionTitle(permission) }}
                    </label>
                    <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">
                      {{ getPermissionDescription(permission) }}
                    </p>

                    <!-- Permission Level Badge -->
                    <span
                      class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium mt-2"
                      :class="getPermissionLevelClass(permission)"
                    >
                      {{ getPermissionLevel(permission) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Other Permissions -->
            <div>
              <h4
                class="text-sm font-semibold text-slate-700 dark:text-slate-300 mb-3"
              >
                {{ $t('CUSTOM_ROLE.FORM.PERMISSIONS.ADDITIONAL_PERMISSIONS') }}
              </h4>

              <div class="space-y-3">
                <div
                  v-for="permission in managementPermissions"
                  :key="permission"
                  class="flex items-start space-x-3"
                >
                  <input
                    :id="permission"
                    v-model="form.permissions"
                    type="checkbox"
                    :value="permission"
                    class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-slate-300 dark:border-slate-600 rounded"
                  />
                  <div class="min-w-0 flex-1">
                    <label
                      :for="permission"
                      class="block text-sm font-medium text-slate-900 dark:text-slate-100 cursor-pointer"
                    >
                      {{ getPermissionTitle(permission) }}
                    </label>
                    <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">
                      {{ getPermissionDescription(permission) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <p
            v-if="getFieldError('permissions')"
            class="mt-1 text-sm text-red-600"
          >
            {{ getFieldError('permissions') }}
          </p>
        </div>

        <!-- Selected Permissions Summary -->
        <div
          v-if="allSelectedPermissions.length > 0"
          class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4"
        >
          <h5 class="text-sm font-medium text-blue-900 dark:text-blue-100 mb-2">
            {{
              $t('CUSTOM_ROLE.FORM.PERMISSIONS.SELECTED_PERMISSIONS', {
                count: allSelectedPermissions.length,
              })
            }}
          </h5>
          <div class="flex flex-wrap gap-2">
            <span
              v-for="permission in allSelectedPermissions"
              :key="permission"
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
            >
              {{ getPermissionTitle(permission) }}
            </span>
          </div>
        </div>
      </div>
    </form>

    <!-- Modal Footer -->
    <div
      class="flex items-center justify-end space-x-3 p-6 border-t border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800"
    >
      <Button
        variant="outline"
        :label="$t('CUSTOM_ROLE.FORM.CANCEL_BUTTON_TEXT')"
        @click="closeModal"
      />

      <Button
        :label="
          isEditMode
            ? $t('CUSTOM_ROLE.EDIT.SUBMIT')
            : $t('CUSTOM_ROLE.ADD.SUBMIT')
        "
        :disabled="!isFormValid"
        :loading="isSubmitting"
        @click="handleSubmit"
      />
    </div>
  </div>
</template>
