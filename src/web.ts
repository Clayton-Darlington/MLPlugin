import { WebPlugin } from '@capacitor/core';

import type { MLPluginPlugin, ClassifyImageOptions, ClassifyImageResult } from './definitions';

export class MLPluginWeb extends WebPlugin implements MLPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async classifyImage(options: ClassifyImageOptions): Promise<ClassifyImageResult> {
    console.log('classifyImage called on web with options:', options);
    // Stub implementation for web
    return {
      predictions: [
        { label: 'web-stub-prediction', confidence: 0.95 }
      ]
    };
  }
}
