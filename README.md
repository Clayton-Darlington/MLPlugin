# ml-plugin

ML Plugin with Image Classification using Vision and CoreML

## Features

- **Image Classification**: Classify images using Google MLKit on iOS and Android
- **LLM Text Generation**: Generate text using MediaPipe LLM Inference on iOS and Android
- **Cross-platform**: Full native implementations for iOS and Android, stubs for Web
- **Device-only processing**: All processing happens on-device for privacy

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

**Image Classification**: Uses Google MLKit (same as Android)
- No additional setup required - works out of the box
- MLKit automatically downloads base models on first use

**LLM Text Generation**: Uses MediaPipe LLM Inference
- Requires adding a compatible model file to your iOS app bundle
- **Recommended**: [Gemma-3n E2B (.litertlm)](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm) - Latest optimized format
- **Alternative**: [Gemma-2 2B (.bin)](https://www.kaggle.com/models/google/gemma-2/tfLite/gemma2-2b-it-gpu-int8) - Legacy format
- Add the model file to your Xcode project's bundle
- Requires iOS 14.0 or later

### Android Setup

**Image Classification**: Uses Google MLKit and works out of the box
- No additional setup required
- MLKit automatically downloads base models on first use

**LLM Text Generation**: Uses MediaPipe LLM Inference  
- Requires downloading a compatible model file to device storage
- **Recommended**: [Gemma-3n E2B (.litertlm)](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm) - Latest optimized format
- **Alternative**: [Gemma-3 1B (.task)](https://huggingface.co/litert-community/Gemma3-1B-IT) - Legacy format
- Push model to `/data/local/tmp/llm/` using adb during development
- For production, download model from server at runtime

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

// Generate text with LLM
const textResult = await MLPlugin.generateText({
  prompt: 'Explain quantum computing in simple terms',
  maxTokens: 150,
  temperature: 0.7
});

console.log(textResult.response);
// Output: Generated explanation text...
```

## Model Formats

### LLM Model Formats Support

| Format | Extension | Platform Support | Status | Notes |
|--------|-----------|------------------|--------|-------|
| **LiteRT LM** | `.litertlm` | iOS, Android, Web | ✅ **Recommended** | Latest optimized format, ready-to-use |
| **Task Bundle** | `.task` | iOS, Android, Web | ✅ Supported | Legacy format, still widely used |
| **Binary** | `.bin` | iOS only | ✅ Supported | Legacy iOS format |

### Recommended Models

| Model | Size | Format | Best For | Download |
|-------|------|---------|----------|----------|
| **Gemma-3n E2B** | ~2B params | `.litertlm` | General use, latest features | [HuggingFace](https://huggingface.co/google/gemma-3n-E2B-it-litert-lm) |
| **Gemma-3n E4B** | ~4B params | `.litertlm` | Higher accuracy | [HuggingFace](https://huggingface.co/google/gemma-3n-E4B-it-litert-lm) |
| **Gemma-3 1B** | ~1B params | `.task`/`.litertlm` | Lightweight, fast | [HuggingFace](https://huggingface.co/litert-community/Gemma3-1B-IT) |

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`classifyImage(...)`](#classifyimage)
* [`generateText(...)`](#generatetext)
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


### generateText(...)

```typescript
generateText(options: LLMInferenceOptions) => Promise<LLMInferenceResult>
```

Generate text using on-device LLM inference

| Param         | Type                                                                | Description                                                                  |
| ------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **`options`** | <code><a href="#llminferenceoptions">LLMInferenceOptions</a></code> | - Configuration object containing the prompt and generation parameters |

**Returns:** <code>Promise&lt;<a href="#llminferenceresult">LLMInferenceResult</a>&gt;</code>

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

| Prop              | Type                | Description                                                   |
| ----------------- | ------------------- | ------------------------------------------------------------- |
| **`base64Image`** | <code>string</code> | Base64 encoded image data (with or without data URI prefix) |


#### LLMInferenceResult

| Prop             | Type                | Description                                |
| ---------------- | ------------------- | ------------------------------------------ |
| **`response`**   | <code>string</code> | The generated text response from the LLM  |
| **`tokensUsed`** | <code>number</code> | Number of tokens used in the generation   |


#### LLMInferenceOptions

| Prop              | Type                | Description                                              |
| ----------------- | ------------------- | -------------------------------------------------------- |
| **`prompt`**      | <code>string</code> | The text prompt to send to the LLM                      |
| **`maxTokens`**   | <code>number</code> | Maximum number of tokens to generate (default: 100)     |
| **`temperature`** | <code>number</code> | Temperature for controlling randomness (0.0 to 1.0, default: 0.7) |

</docgen-api>

## Platform Support

| Platform | Image Classification | LLM Text Generation | Notes |
|----------|---------------------|-------------------|-------|
| iOS      | ✅ Google MLKit      | ✅ MediaPipe LLM   | Requires model files in app bundle |
| Android  | ✅ Google MLKit      | ✅ MediaPipe LLM   | Requires model files on device storage |
| Web      | 🚧 Stub             | 🚧 Stub           | Returns mock responses |
