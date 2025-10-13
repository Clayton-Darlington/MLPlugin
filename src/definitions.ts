export interface ClassificationResult {
  /**
   * The predicted label/class name
   */
  label: string;
  /**
   * Confidence score between 0 and 1
   */
  confidence: number;
}

export interface ClassifyImageOptions {
  /**
   * Absolute path to the image file on the device
   */
  imagePath: string;
}

export interface ClassifyImageResult {
  /**
   * Array of classification predictions, ordered by confidence (highest first)
   */
  predictions: ClassificationResult[];
}

export interface MLPluginPlugin {
  /**
   * Echo back a string value
   */
  echo(options: { value: string }): Promise<{ value: string }>;

  /**
   * Classify an image using Vision and CoreML (iOS only, stubs for other platforms)
   * 
   * @param options - Configuration object containing the image path
   * @returns Promise resolving to classification results
   * 
   * @example
   * ```typescript
   * const result = await MLPlugin.classifyImage({
   *   imagePath: '/path/to/image.jpg'
   * });
   * console.log(result.predictions);
   * ```
   */
  classifyImage(options: ClassifyImageOptions): Promise<ClassifyImageResult>;
}
