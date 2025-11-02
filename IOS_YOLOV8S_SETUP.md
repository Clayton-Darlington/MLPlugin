# iOS YOLOv8s Setup Guide

## Quick Start

This plugin now requires a YOLOv8s CoreML model to be added to your iOS app.

## Required Model File

- **Filename**: `yolov8s.mlmodel` or `yolov8s.mlmodelc`
- **Format**: CoreML model
- **Location**: iOS app bundle (added via Xcode)

## Setup Instructions

### Option 1: Download Pre-converted Model

1. Download YOLOv8s CoreML model from:
   - [Ultralytics Hub](https://hub.ultralytics.com/)
   - [Apple ML Models](https://developer.apple.com/machine-learning/models/)
   - Or search for "yolov8s coreml" on GitHub

2. Add to Xcode:
   - Open your iOS app project in Xcode
   - Drag `yolov8s.mlmodel` into project navigator
   - Check "Copy items if needed"
   - Select your app target
   - Click "Add"

### Option 2: Export from PyTorch

If you have Python and Ultralytics installed:

```bash
# Install ultralytics if needed
pip install ultralytics

# Export YOLOv8s to CoreML
yolo export model=yolov8s.pt format=coreml
```

This creates `yolov8s.mlmodel` which you can add to Xcode.

### Option 3: Use Other YOLO Variants

You can use other YOLO models, but **must** rename them to `yolov8s.mlmodel`:

```bash
# Export YOLOv8n (nano - faster, less accurate)
yolo export model=yolov8n.pt format=coreml
mv yolov8n.mlmodel yolov8s.mlmodel

# Export YOLOv8m (medium - slower, more accurate)  
yolo export model=yolov8m.pt format=coreml
mv yolov8m.mlmodel yolov8s.mlmodel
```

## Verification

After adding the model, verify it's correctly configured:

1. **In Xcode Project Navigator**: 
   - You should see `yolov8s.mlmodel` listed
   - It should have a checkmark next to your app target

2. **Build the app**:
   - Xcode will compile the model to `.mlmodelc` format
   - Check for any compilation errors in build logs

3. **Run the app**:
   - Check console logs for: `"YOLOv8s model loaded successfully"`
   - If you see: `"Warning: yolov8s model not found"` - the file is not in the bundle

## Model Information

### YOLOv8s Specifications
- **Input**: RGB images (any resolution, auto-scaled)
- **Output**: Object detections with bounding boxes
- **Classes**: 80 object classes (COCO dataset)
- **Model Size**: ~22 MB
- **Performance**: ~50-100ms on modern iPhones

### Supported Object Classes
person, bicycle, car, motorcycle, airplane, bus, train, truck, boat, traffic light, fire hydrant, stop sign, parking meter, bench, bird, cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe, backpack, umbrella, handbag, tie, suitcase, frisbee, skis, snowboard, sports ball, kite, baseball bat, baseball glove, skateboard, surfboard, tennis racket, bottle, wine glass, cup, fork, knife, spoon, bowl, banana, apple, sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake, chair, couch, potted plant, bed, dining table, toilet, tv, laptop, mouse, remote, keyboard, cell phone, microwave, oven, toaster, sink, refrigerator, book, clock, vase, scissors, teddy bear, hair drier, toothbrush

## Response Format

iOS will now return detections with bounding boxes:

```typescript
{
  predictions: [
    {
      label: "person",
      confidence: 0.94,
      boundingBox: {
        x: 0.25,      // Normalized (0-1) from left
        y: 0.30,      // Normalized (0-1) from top
        width: 0.40,  // Normalized width
        height: 0.50  // Normalized height
      },
      modelName: "YOLOv8s"
    },
    // ... more detections
  ]
}
```

To convert to pixel coordinates:

```typescript
const imageWidth = 1920;  // Your actual image width
const imageHeight = 1080; // Your actual image height

predictions.forEach(pred => {
  if (pred.boundingBox) {
    const bbox = {
      x: pred.boundingBox.x * imageWidth,
      y: pred.boundingBox.y * imageHeight,
      width: pred.boundingBox.width * imageWidth,
      height: pred.boundingBox.height * imageHeight
    };
    
    // Draw rectangle at (bbox.x, bbox.y) 
    // with size (bbox.width, bbox.height)
  }
});
```

## Troubleshooting

### "YOLOv8s model not found in app bundle"

**Solution**: 
1. Check the file is named exactly `yolov8s.mlmodel` (case-sensitive)
2. Verify it's checked in your app target's "Build Phases" > "Copy Bundle Resources"
3. Clean build folder: Product > Clean Build Folder in Xcode
4. Rebuild and run

### "Failed to load YOLOv8s model"

**Possible causes**:
1. Corrupted model file - try re-downloading/re-exporting
2. Incompatible model version - ensure it's CoreML format
3. iOS version too old - requires iOS 14.0+

### "No objects detected by YOLOv8s"

**This is normal if**:
- Image contains no recognizable objects from the 80 COCO classes
- Objects are too small or low quality
- Lighting conditions are poor

**Try**:
- Use better lit, clearer images
- Ensure objects are reasonably sized in frame
- Test with images that definitely contain common objects (person, car, cat, etc.)

## Custom Trained Models

If you have a custom-trained YOLOv8 model:

1. Export to CoreML format:
```bash
yolo export model=path/to/your/custom_model.pt format=coreml
```

2. Rename to `yolov8s.mlmodel`

3. Add to Xcode as described above

**Note**: Custom models may have different output classes. Update your app's UI to handle the specific classes your model detects.

## Performance Tips

1. **Image Size**: Resize images before detection to reduce processing time
   ```typescript
   // Aim for ~640x640 pixels for best balance of speed/accuracy
   ```

2. **Confidence Threshold**: Filter low-confidence predictions
   ```typescript
   const filtered = result.predictions.filter(p => p.confidence > 0.5);
   ```

3. **Model Variants**: 
   - Use YOLOv8n for faster, real-time detection
   - Use YOLOv8m or YOLOv8l for better accuracy on static images

## Need Help?

- Check example app in `example-app/` folder
- See `YOLOV8S_UPDATE.md` for detailed migration guide
- Review `README.md` for general plugin usage
