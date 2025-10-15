# Using Restricted Models with MLPlugin

This guide demonstrates how to use the ML Plugin with restricted/gated models that require authentication, such as models hosted on Hugging Face.

## Prerequisites

1. **Hugging Face Account**: Create an account at [huggingface.co](https://huggingface.co)
2. **Access Token**: Generate a token at [Settings > Access Tokens](https://huggingface.co/settings/tokens)
3. **Model Access**: Request access to gated models if required

## Example: Using Gemma-3n E2B with Authentication

```typescript
import { MLPlugin } from 'ml-plugin';

// Method 1: Using environment variables (recommended for development)
const HUGGING_FACE_TOKEN = process.env.HUGGING_FACE_TOKEN;

async function generateWithRestrictedModel() {
  try {
    const result = await MLPlugin.generateText({
      prompt: 'Explain the concept of machine learning in simple terms',
      maxTokens: 200,
      temperature: 0.7,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
        modelFileName: 'gemma-3n-e2b-restricted.litertlm',
        authToken: HUGGING_FACE_TOKEN, // Your HF token
        headers: {
          'User-Agent': 'MLPlugin/1.0',
          'Accept': 'application/octet-stream'
        }
      }
    });

    console.log('Generated text:', result.response);
    console.log('Tokens used:', result.tokensUsed);
  } catch (error) {
    console.error('Error generating text:', error);
    
    // Handle common authentication errors
    if (error.message.includes('Authentication failed')) {
      console.error('Please check your Hugging Face token');
    } else if (error.message.includes('Access forbidden')) {
      console.error('You may need to request access to this gated model');
    }
  }
}
```

## Method 2: Using Secure Storage (recommended for production)

```typescript
import { Storage } from '@ionic/storage-angular';

class MLService {
  constructor(private storage: Storage) {}

  private async getAuthToken(): Promise<string> {
    // Retrieve token from secure storage
    return await this.storage.get('hugging_face_token');
  }

  async generateText(prompt: string) {
    const authToken = await this.getAuthToken();
    
    if (!authToken) {
      throw new Error('Authentication token not found. Please log in.');
    }

    return await MLPlugin.generateText({
      prompt,
      maxTokens: 150,
      temperature: 0.8,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
        modelFileName: 'gemma-3n-e2b.litertlm',
        authToken: authToken
      }
    });
  }
}
```

## Method 3: Server-Side Token Management (most secure)

```typescript
// Client-side code
async function generateWithServerToken(prompt: string) {
  // Get a temporary token from your server
  const tokenResponse = await fetch('/api/ml-token', {
    method: 'POST',
    headers: { 'Authorization': 'Bearer ' + userJWT }
  });
  
  const { temporaryToken } = await tokenResponse.json();

  return await MLPlugin.generateText({
    prompt,
    maxTokens: 200,
    modelConfig: {
      downloadAtRuntime: true,
      downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
      modelFileName: 'gemma-3n-e2b.litertlm',
      authToken: temporaryToken // Server-provided token
    }
  });
}
```

## Error Handling

```typescript
async function robustGeneration(prompt: string) {
  try {
    const result = await MLPlugin.generateText({
      prompt,
      maxTokens: 150,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
        authToken: 'hf_your_token_here'
      }
    });
    
    return result.response;
  } catch (error) {
    // Handle different error types
    if (error.message.includes('Authentication failed')) {
      // Token is invalid or expired
      console.log('Please update your Hugging Face token');
      throw new Error('Authentication required');
    } else if (error.message.includes('Access forbidden')) {
      // Need to request access to the model
      console.log('Request access at: https://huggingface.co/google/gemma-3n-E2B-it-litert-lm');
      throw new Error('Model access required');
    } else if (error.message.includes('Model not found')) {
      // URL is incorrect
      throw new Error('Model URL is invalid');
    } else {
      // Other errors (network, storage, etc.)
      console.error('Unexpected error:', error);
      throw error;
    }
  }
}
```

## Best Practices

### Security
- **Never hardcode tokens** in your application code
- Use environment variables for development
- Use secure storage or server-side management for production
- Implement token refresh mechanisms for long-running apps

### Performance
- **Cache downloaded models** - they won't be re-downloaded if the file exists
- **Choose appropriate model sizes** - larger models take longer to download
- **Monitor download progress** - implement UI feedback for large downloads

### Error Handling
- **Implement fallbacks** - use bundled models if download fails
- **Provide user feedback** - explain authentication requirements
- **Log errors appropriately** - without exposing sensitive tokens

## Supported Models

| Model | Size | Authentication | Best For |
|-------|------|---------------|----------|
| **Gemma-3n E2B** | ~2B params | Required | General text generation |
| **Gemma-3n E4B** | ~4B params | Required | Higher quality responses |
| **Gemma-3 1B** | ~1B params | Optional | Fast, lightweight |

## Testing Authentication

```typescript
// Simple test to verify token works
async function testAuthentication(token: string) {
  try {
    const result = await MLPlugin.generateText({
      prompt: 'Hello',
      maxTokens: 10,
      modelConfig: {
        downloadAtRuntime: true,
        downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
        authToken: token
      }
    });
    
    console.log('Authentication successful!');
    return true;
  } catch (error) {
    console.error('Authentication failed:', error.message);
    return false;
  }
}
```