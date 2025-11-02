# YOLOv8s Integration Update for iOS

## Summary

The iOS implementation has been updated to use YOLOv8s for object detection instead of Google MLKit for image classification. This change provides more advanced object detection capabilities with bounding boxes and support for multiple objects in a single image.

## Changes Made

### 1. iOS Swift Implementation (`ios/Sources/MLPluginPlugin/MLPlugin.swift`)

#### Replaced Dependencies
- **Removed**: `MLKitImageLabeling` and `MLKitVision`
- **Added**: `Vision` and `CoreML` (built-in iOS frameworks)

#### Updated Class Properties
```swift
// Before:
private var imageLabeler: ImageLabeler

// After:
private var yoloModel: VNCoreMLModel?
```

#### Model Loading
- Added `loadYOLOModel()` method that looks for `yolov8s.mlmodel` or `yolov8s.mlmodelc` in the app bundle
- The model must be added to the iOS app by the developer

#### Image Classification/Detection
- Completely rewrote `classifyImage()` method to use Vision framework with YOLOv8s
- Now returns object detection results with bounding boxes
- Supports both `VNRecognizedObjectObservation` (object detection) and `VNClassificationObservation` (fallback)

#### Response Format
The iOS implementation now returns:
```swift
[
  "label": String,           // Object class name
  "confidence": Double,      // Confidence score (0-1)
  "boundingBox": [           // Optional: Only for object detection
    "x": Double,            // Normalized x coordinate
    "y": Double,            // Normalized y coordinate  
    "width": Double,        // Normalized width
    "height": Double        // Normalized height
  ],
  "modelName": "YOLOv8s"
]
```

### 2. Podspec Update (`MlPlugin.podspec`)

#### Removed Dependencies
```ruby
# Removed:
s.dependency 'GoogleMLKit/ImageLabeling', '~> 4.0.0'
```

#### Added Frameworks
```ruby
# Added:
s.frameworks = 'Vision', 'CoreML'
```

### 3. Documentation Updates

#### README.md
- Updated features section to distinguish between iOS (YOLOv8s) and Android (MLKit)
- Updated iOS setup section with instructions for adding YOLOv8s model
- Updated platform support table
- Added step-by-step guide for adding the model to Xcode

#### example-usage.md
- Updated example code to show iOS returns bounding boxes
- Added iOS vs Android result format comparison
- Added "Object Detection Models (iOS)" section with setup instructions
- Updated platform support section

#### example-app/src/index.html
- Updated image classification section header and description

## Requirements for iOS Apps Using This Plugin

### 1. YOLOv8s Model File
The app developer must:
1. Export or download YOLOv8s model in CoreML format
2. Add the file to their iOS project in Xcode
3. Name it `yolov8s.mlmodel` or `yolov8s.mlmodelc`
4. Ensure it's included in the app bundle target

### 2. Model Export Options
If you need to create the CoreML model:
- Use Ultralytics YOLOv8: `yolo export model=yolov8s.pt format=coreml`
- Download pre-converted CoreML models from Ultralytics or Apple's Model Gallery
- Custom trained YOLOv8s models can also be used

### 3. Supported Classes
YOLOv8s trained on COCO dataset supports 80 object classes including:
- person, bicycle, car, motorcycle, airplane, bus, train, truck, boat
- cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe
- And many more common objects

## Backward Compatibility

### Breaking Changes
- iOS apps using this plugin **must** now include the YOLOv8s model file
- The response format now includes `boundingBox` data (only on iOS)
- Apps must update their UI to handle the new response format with bounding boxes

### Android Compatibility
- **No changes** to Android implementation
- Android continues to use Google MLKit for image classification
- Android responses remain the same (no bounding boxes)

## Migration Guide for Existing Apps

### Step 1: Add YOLOv8s Model
```bash
# Download or export YOLOv8s CoreML model
# Then in Xcode:
# 1. Open your iOS project
# 2. Drag yolov8s.mlmodel into project navigator
# 3. Check "Copy items if needed"
# 4. Ensure it's added to your app target
```

### Step 2: Update UI Code (Optional)
If you want to display bounding boxes on iOS:
```typescript
const result = await MLPlugin.classifyImage({
  base64Image: imageData
});

result.predictions.forEach(pred => {
  console.log(`Detected ${pred.label} with confidence ${pred.confidence}`);
  
  if (pred.boundingBox) {
    // iOS: Draw bounding box
    const bbox = pred.boundingBox;
    // Convert normalized coordinates to pixel coordinates
    // and draw rectangle on image
  }
});
```

### Step 3: Update Pod Dependencies
```bash
cd ios
pod install  # Will remove MLKit, use built-in frameworks
```

## Benefits of This Change

1. **No External Dependencies**: Vision and CoreML are built into iOS, reducing app size
2. **Object Detection**: Get bounding boxes for detected objects, not just labels
3. **Multiple Objects**: Detect multiple objects in a single image
4. **Better Accuracy**: YOLOv8s is state-of-the-art for object detection
5. **Flexibility**: Can swap to other YOLO variants (nano, medium, large) by changing the model file
6. **COCO Dataset**: Supports 80 object classes out of the box

## Testing

After updating, test the following:
1. Model loads successfully on app launch
2. Image detection returns results with bounding boxes
3. Confidence scores are reasonable (typically > 0.5 for valid detections)
4. Error handling when model is missing shows appropriate message

## Support

If you encounter issues:
1. Verify `yolov8s.mlmodel` is in your app bundle
2. Check Xcode build logs for CoreML compilation errors
3. Ensure iOS deployment target is 14.0 or later
4. Verify the model file is not corrupted (try re-exporting)
