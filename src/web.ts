import { WebPlugin } from '@capacitor/core';

import type { MLPluginPlugin } from './definitions';

export class MLPluginWeb extends WebPlugin implements MLPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
