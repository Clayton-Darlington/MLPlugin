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
   * Base64 encoded image data (with or without data URI prefix)
   */
  base64Image: string;
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
   * @param options - Configuration object containing the base64 image data
   * @returns Promise resolving to classification results
   * 
   * @example
   * ```typescript
   * const result = await MLPlugin.classifyImage({
   *   base64Image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...'
   * });
   * console.log(result.predictions);
   * ```
   */
  classifyImage(options: ClassifyImageOptions): Promise<ClassifyImageResult>;
}
