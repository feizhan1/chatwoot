// Self-developed Custom Roles Routes
// This provides the routing configuration for the custom roles management feature
// without any dependencies on existing enterprise modules

import { frontendURL } from '../../../../helper/URLHelper';
import SettingsWrapper from '../SettingsWrapper.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/custom-roles'),
      meta: {
        permissions: ['administrator'],
        featureFlag: 'custom_roles',
      },
      component: SettingsWrapper,
      children: [
        {
          path: '',
          name: 'custom_roles_list',
          component: () => import('./Index.vue'),
        },
      ],
    },
  ],
};
