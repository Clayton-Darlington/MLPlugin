# ml-plugin

ML Plugin with Image Classification using Vision and CoreML

## Features

- **Image Classification**: Classify images using Vision and CoreML on iOS
- **Cross-platform**: Stub implementations for Android and Web
- **Device-only processing**: All classification happens on-device for privacy

## Install

```bash
npm install ml-plugin
npx cap sync
```

## Local Dev
For easy local deving pull the git repo and just npm link to whatever project you are working on.

To link:

```bash
cd /dir/with/plugin
npm link

cd /dir/with/project
npm link ml-plugin
```

## Platform Setup

### iOS Setup

iOS implementation uses Google's MLKit (same as Android):

1. No additional setup required
2. MLKit will automatically download base models on first use  
3. Uses Google's on-device image labeling models
4. Requires internet connection for initial model download
5. Requires iOS 14.0 or later

### Android Setup

Android implementation uses Google's MLKit and works out of the box:

1. No additional setup required
2. MLKit will automatically download base models on first use
3. Uses Google's on-device image labeling models
4. Requires internet connection for initial model download

## Usage

```typescript
import { Camera, CameraResultType } from '@capacitor/camera';
import { MLPlugin } from 'ml-plugin';

// Take a photo with the camera
const image = await Camera.getPhoto({
  quality: 90,
  allowEditing: false,
  resultType: CameraResultType.Base64
});

// Classify the photo
const result = await MLPlugin.classifyImage({
  base64Image: `data:image/jpeg;base64,${image.base64String}`
});

console.log(result.predictions);
// Output: [{ label: 'cat', confidence: 0.95 }, ...]
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`classifyImage(...)`](#classifyimage)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

Echo back a string value

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### classifyImage(...)

```typescript
classifyImage(options: ClassifyImageOptions) => Promise<ClassifyImageResult>
```

Classify an image using Vision and CoreML (iOS only, stubs for other platforms)

| Param         | Type                                                                  | Description                                      |
| ------------- | --------------------------------------------------------------------- | ------------------------------------------------ |
| **`options`** | <code><a href="#classifyimageoptions">ClassifyImageOptions</a></code> | - Configuration object containing the image path |

**Returns:** <code>Promise&lt;<a href="#classifyimageresult">ClassifyImageResult</a>&gt;</code>

--------------------


### Interfaces


#### ClassifyImageResult

| Prop              | Type                                | Description                                                                |
| ----------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| **`predictions`** | <code>ClassificationResult[]</code> | Array of classification predictions, ordered by confidence (highest first) |


#### ClassificationResult

| Prop             | Type                | Description                      |
| ---------------- | ------------------- | -------------------------------- |
| **`label`**      | <code>string</code> | The predicted label/class name   |
| **`confidence`** | <code>number</code> | Confidence score between 0 and 1 |


#### ClassifyImageOptions

| Prop            | Type                | Description                                   |
| --------------- | ------------------- | --------------------------------------------- |
| **`imagePath`** | <code>string</code> | Absolute path to the image file on the device |

</docgen-api>

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS      | ✅ Full | Uses Google MLKit for image classification |
| Android  | ✅ Full | Uses Google MLKit for image classification |
| Web      | 🚧 Stub | Returns mock predictions |
