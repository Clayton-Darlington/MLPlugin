import { registerPlugin } from '@capacitor/core';

import type { MLPluginPlugin } from './definitions';

const MLPlugin = registerPlugin<MLPluginPlugin>('MLPlugin', {
  web: () => import('./web').then((m) => new m.MLPluginWeb()),
});

export * from './definitions';
export { MLPlugin };
