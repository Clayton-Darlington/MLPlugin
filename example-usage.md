# MLPlugin Image Classification Example

## Usage

```typescript
import { MLPlugin } from 'ml-plugin';

// Classify an image from the device
async function classifyImage() {
  try {
    const result = await MLPlugin.classifyImage({
      imagePath: '/path/to/your/image.jpg' // Use a path to an image file on the device
    });
    
    console.log('Classification results:', result.predictions);
    
    // Result format:
    // {
    //   predictions: [
    //     { label: 'cat', confidence: 0.95 },
    //     { label: 'dog', confidence: 0.03 },
    //     { label: 'bird', confidence: 0.01 }
    //   ]
    // }
    
  } catch (error) {
    console.error('Classification failed:', error);
  }
}
```

## Setup for iOS

1. **Add a CoreML Model**: 
   - Download a `.mlmodel` file (e.g., MobileNetV2 from Apple's Machine Learning page)
   - Convert it to `.mlmodelc` format using Xcode or coremltools
   - Add the `MobileNetV2.mlmodelc` file to your iOS app bundle

2. **Alternative Setup**:
   - The plugin will work with a fallback if no model is provided
   - You can modify the `setupModel()` function in `MLPlugin.swift` to use a different model name

## Platform Support

- **iOS**: Full implementation using Vision and CoreML frameworks
- **Android**: Stub implementation (returns mock data)
- **Web**: Stub implementation (returns mock data)

## Model Requirements

The iOS implementation expects a classification model that outputs `VNClassificationObservation` results. Popular models that work well:

- MobileNetV2
- ResNet50
- SqueezeNet
- Custom trained classification models

## Error Handling

The plugin will handle common errors:
- Invalid image path
- Model loading failures
- Image processing errors
- Vision framework errors

On iOS, if no model is found, it will return a default prediction rather than failing completely.