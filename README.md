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

## iOS Setup

To use image classification on iOS, you need to add a CoreML model to your app:

1. Download a classification model (e.g., MobileNetV2 from Apple's ML Gallery)
2. Add the `.mlmodelc` file to your iOS app bundle
3. The plugin will automatically detect and use the model

## Usage

```typescript
import { MLPlugin } from 'ml-plugin';

// Classify an image
const result = await MLPlugin.classifyImage({
  imagePath: '/path/to/image.jpg'
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
| iOS      | ✅ Full | Uses Vision + CoreML for image classification |
| Android  | 🚧 Stub | Returns mock predictions |
| Web      | 🚧 Stub | Returns mock predictions |
