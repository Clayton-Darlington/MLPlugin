export interface MLPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
