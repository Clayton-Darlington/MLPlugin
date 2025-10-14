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

export interface LLMInferenceOptions {
  /**
   * The text prompt to send to the LLM
   */
  prompt: string;
  /**
   * Maximum number of tokens to generate (default: 100)
   */
  maxTokens?: number;
  /**
   * Temperature for controlling randomness (0.0 to 1.0, default: 0.7)
   */
  temperature?: number;
}

export interface LLMInferenceResult {
  /**
   * The generated text response from the LLM
   */
  response: string;
  /**
   * Number of tokens used in the generation
   */
  tokensUsed?: number;
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

  /**
   * Generate text using on-device LLM inference
   * 
   * @param options - Configuration object containing the prompt and generation parameters
   * @returns Promise resolving to generated text response
   * 
   * @example
   * ```typescript
   * const result = await MLPlugin.generateText({
   *   prompt: 'Explain quantum computing in simple terms',
   *   maxTokens: 150,
   *   temperature: 0.7
   * });
   * console.log(result.response);
   * ```
   */
  generateText(options: LLMInferenceOptions): Promise<LLMInferenceResult>;
}
