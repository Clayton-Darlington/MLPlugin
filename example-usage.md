# MLPlugin Usage Examples

## Image Classification

```typescript
import { MLPlugin } from 'ml-plugin';
import { Camera, CameraResultType } from '@capacitor/camera';

// Take a photo and classify it
async function classifyPhoto() {
  try {
    // Take a photo with Capacitor Camera
    const image = await Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64
    });

    // Classify/detect objects in the photo
    const result = await MLPlugin.classifyImage({
      base64Image: `data:image/jpeg;base64,${image.base64String}`
    });
    
    console.log('Detection results:', result.predictions);
    
    // Result format (iOS with YOLOv8s - includes bounding boxes):
    // {
    //   predictions: [
    //     { 
    //       label: 'cat', 
    //       confidence: 0.95,
    //       boundingBox: { x: 0.2, y: 0.3, width: 0.4, height: 0.5 },
    //       modelName: 'YOLOv8s'
    //     },
    //     { 
    //       label: 'dog', 
    //       confidence: 0.88,
    //       boundingBox: { x: 0.5, y: 0.4, width: 0.3, height: 0.4 },
    //       modelName: 'YOLOv8s'
    //     }
    //   ]
    // }
    //
    // Result format (Android with MLKit - classification only):
    // {
    //   predictions: [
    //     { label: 'cat', confidence: 0.95 },
    //     { label: 'dog', confidence: 0.03 }
    //   ]
    // }
    
  } catch (error) {
    console.error('Classification failed:', error);
  }
}
```

## LLM Text Generation - Basic Usage

```typescript
// Generate text with bundled model
async function generateText() {
  try {
    const result = await MLPlugin.generateText({
      prompt: 'Explain quantum computing in simple terms',
      maxTokens: 150,
      temperature: 0.7
    });
    
    console.log('Generated text:', result.response);
    console.log('Tokens used:', result.tokensUsed);
    
  } catch (error) {
    console.error('Text generation failed:', error);
  }
}
```

## LLM Text Generation - Download Model at Runtime

```typescript
// Download and use a public model at runtime
async function generateTextWithDownload() {
  try {
    const result = await MLPlugin.generateText({
      prompt: 'Write a short story about space exploration',
      maxTokens: 200,
      temperature: 0.8,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/model.litertlm',
        modelFileName: 'gemma-3-1b.litertlm'
      }
    });
    
    console.log('Generated text:', result.response);
    
  } catch (error) {
    console.error('Text generation failed:', error);
  }
}
```

## LLM Text Generation - Restricted/Gated Models

```typescript
// Access restricted models with authentication
async function generateTextWithAuth() {
  try {
    // Get your token from https://huggingface.co/settings/tokens
    const huggingFaceToken = 'hf_your_token_here';
    
    const result = await MLPlugin.generateText({
      prompt: 'Explain the theory of relativity',
      maxTokens: 300,
      temperature: 0.7,
      topK: 50,
      topP: 0.9,
      randomSeed: 42,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
        modelFileName: 'gemma-3n-e2b.litertlm',
        authToken: huggingFaceToken,
        headers: {
          'User-Agent': 'MyApp/1.0'
        }
      }
    });
    
    console.log('Generated text:', result.response);
    
  } catch (error) {
    if (error.message.includes('Authentication failed')) {
      console.error('Invalid token - check your Hugging Face token');
    } else if (error.message.includes('Access forbidden')) {
      console.error('Access denied - request access to the gated model');
    } else {
      console.error('Text generation failed:', error);
    }
  }
}
```

## Secure Token Management

**Never hardcode tokens in production apps!**

```typescript
// Development - use environment variables
const getHuggingFaceToken = () => {
  return process.env.HUGGING_FACE_TOKEN || '';
};

// Production - use secure storage
import { Preferences } from '@capacitor/preferences';

const getSecureToken = async () => {
  const { value } = await Preferences.get({ key: 'hf_token' });
  return value || '';
};

// Use in your app
async function generateTextSecurely() {
  const token = await getSecureToken();
  
  if (!token) {
    console.error('No authentication token available');
    return;
  }
  
  const result = await MLPlugin.generateText({
    prompt: 'Your prompt here',
    modelConfig: {
      downloadAtRuntime: true,
      downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
      authToken: token
    }
  });
}
```

## Getting Hugging Face Access

### Step 1: Create Account & Get Token
1. Create account at [huggingface.co](https://huggingface.co)
2. Go to [Settings > Access Tokens](https://huggingface.co/settings/tokens)
3. Create new token with "Read" permissions
4. Copy the token (starts with `hf_`)

### Step 2: Request Model Access
1. Visit the model page: [gemma-3n-E2B-it-litert-lm](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm)
2. Click "Request access" if prompted
3. Wait for approval (usually automatic)

## Platform Support

- **iOS**: Object detection using YOLOv8s (Vision + CoreML) + MediaPipe LLM
- **Android**: Image classification using Google MLKit + MediaPipe LLM  
- **Web**: Stub implementation (returns mock data)

## Model Formats Supported

### LLM Models
- **LiteRT LM** (`.litertlm`) - Recommended, latest format
- **Task Bundle** (`.task`) - Legacy format, still supported
- **Binary** (`.bin`) - iOS only, legacy format

### Recommended Models
- **Gemma-3n E2B** (~2B params) - Best balance of quality and size
- **Gemma-3n E4B** (~4B params) - Higher accuracy, larger download
- **Gemma-3 1B** (~1B params) - Fastest, most compact

## Deployment Strategies

### Bundled Models (Default)
```typescript
// No modelConfig needed - uses bundled model
const result = await MLPlugin.generateText({
  prompt: 'Your prompt here'
});
```

**Pros**: Offline, fast startup, guaranteed availability  
**Cons**: Large app size, can't update models without app updates

### Runtime Downloads
```typescript
// Download on first use
const result = await MLPlugin.generateText({
  prompt: 'Your prompt here',
  modelConfig: {
    downloadAtRuntime: true,
    downloadUrl: 'https://huggingface.co/...',
    modelFileName: 'model.litertlm'
  }
});
```

**Pros**: Smaller app size, updatable models, A/B testing  
**Cons**: Requires network, potential download failures

## Object Detection Models (iOS)

The iOS implementation uses YOLOv8s for object detection, which provides:
- Real-time object detection with bounding boxes
- Support for 80+ object classes (COCO dataset)
- Confidence scores for each detection
- Multiple objects detected per image

**YOLOv8s Model Setup:**
1. Export YOLOv8s to CoreML format (`.mlmodel` or `.mlmodelc`)
2. Add the model file to your iOS app's Xcode project
3. Ensure the file is named `yolov8s.mlmodel` or `yolov8s.mlmodelc`
4. The plugin automatically loads and uses the model

**Alternative object detection models:**
- YOLOv8n (nano) - Faster, less accurate
- YOLOv8m (medium) - Slower, more accurate
- Custom trained YOLO models in CoreML format

## Error Handling

The plugin will handle common errors:
- Invalid image path
- Model loading failures
- Image processing errors
- Vision framework errors

On iOS, if no model is found, it will return a default prediction rather than failing completely.