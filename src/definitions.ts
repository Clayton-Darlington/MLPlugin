export interface BoundingBox {
  /**
   * X coordinate of the bounding box (normalized 0-1)
   */
  x: number;
  /**
   * Y coordinate of the bounding box (normalized 0-1)
   */
  y: number;
  /**
   * Width of the bounding box (normalized 0-1)
   */
  width: number;
  /**
   * Height of the bounding box (normalized 0-1)
   */
  height: number;
}

export interface DetectionResult {
  /**
   * The detected object label/class name
   */
  label: string;
  /**
   * Confidence score between 0 and 1
   */
  confidence: number;
  /**
   * Bounding box coordinates for the detected object
   */
  boundingBox: BoundingBox;
  /**
   * Name of the model used for detection
   */
  modelName?: string;
}

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

export interface DetectObjectsOptions {
  /**
   * Base64 encoded image data (with or without data URI prefix)
   */
  base64Image: string;
}

export interface DetectObjectsResult {
  /**
   * Array of object detections with bounding boxes, ordered by confidence (highest first)
   */
  detections: DetectionResult[];
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
  /**
   * Top-K sampling parameter to limit vocabulary selection (optional)
   */
  topK?: number;
  /**
   * Top-P sampling parameter for nucleus sampling (0.0 to 1.0, optional)
   */
  topP?: number;
  /**
   * Random seed for reproducible generation (optional)
   */
  randomSeed?: number;
  /**
   * Model configuration options
   */
  modelConfig?: ModelConfig;
}

export interface ModelConfig {
  /**
   * Whether to download the model at runtime instead of using bundled model
   */
  downloadAtRuntime?: boolean;
  /**
   * URL to download the model from (required if downloadAtRuntime is true)
   */
  downloadUrl?: string;
  /**
   * Local model filename to use (defaults based on URL or bundled model)
   */
  modelFileName?: string;
  /**
   * Authentication token for accessing restricted/gated models (e.g., Hugging Face token)
   */
  authToken?: string;
  /**
   * Additional headers to include with download request
   */
  headers?: { [key: string]: string };
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
   * Detect objects in an image using YOLOv8s (iOS only)
   * Returns detected objects with bounding boxes and confidence scores
   * 
   * @param options - Configuration object containing the base64 image data
   * @returns Promise resolving to object detection results with bounding boxes
   * 
   * @example
   * ```typescript
   * const result = await MLPlugin.detectObjects({
   *   base64Image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...'
   * });
   * result.detections.forEach(detection => {
   *   console.log(`Found ${detection.label} at confidence ${detection.confidence}`);
   *   console.log(`Bounding box:`, detection.boundingBox);
   * });
   * ```
   */
  detectObjects(options: DetectObjectsOptions): Promise<DetectObjectsResult>;

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
