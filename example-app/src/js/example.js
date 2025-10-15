import { MLPlugin } from 'ml-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    MLPlugin.echo({ value: inputValue })
}

window.testClassifyImage = async () => {
    try {
        // Example base64 image - in a real app, you'd get this from Capacitor Camera plugin
        // This is a small test image encoded as base64
        const base64Image = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=';
        
        console.log('Starting image classification...');
        const resultsDiv = document.getElementById('classificationResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = '<h3>Classifying image...</h3><div>Please wait...</div>';
        }
        
        const result = await MLPlugin.classifyImage({ base64Image });
        
        console.log('Classification results:', result);
        
        // Display results
        if (resultsDiv) {
            resultsDiv.innerHTML = '<h3>Classification Results:</h3>';
            
            if (result.predictions && result.predictions.length > 0) {
                result.predictions.forEach((prediction, index) => {
                    resultsDiv.innerHTML += `
                        <div style="padding: 8px; border-bottom: 1px solid #eee;">
                            <strong>${index + 1}.</strong> 
                            ${prediction.label} 
                            <span style="color: #666;">(${(prediction.confidence * 100).toFixed(1)}%)</span>
                        </div>
                    `;
                });
                
                // Add platform info
                resultsDiv.innerHTML += `
                    <div style="margin-top: 16px; padding: 8px; background: #f5f5f5; border-radius: 4px; font-size: 12px;">
                        <strong>Platform:</strong> ${getPlatformInfo()}<br>
                        <strong>Results:</strong> ${result.predictions.length} predictions
                    </div>
                `;
            } else {
                resultsDiv.innerHTML += '<div>No predictions returned</div>';
            }
        }
        
    } catch (error) {
        console.error('Classification failed:', error);
        const resultsDiv = document.getElementById('classificationResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = `
                <div style="color: red; padding: 8px; border: 1px solid red; border-radius: 4px;">
                    <strong>Error:</strong> ${error.message || error}
                </div>
            `;
        }
    }
}

window.testGenerateText = async () => {
    try {
        const promptInput = document.getElementById("promptInput");
        const prompt = promptInput.value || 'Explain artificial intelligence in simple terms';
        
        console.log('Starting text generation...');
        const resultsDiv = document.getElementById('textResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = '<h3>Generating text...</h3><div>Please wait...</div>';
        }
        
        // Check if user wants to download model at runtime
        const downloadCheckbox = document.getElementById("downloadModelCheckbox");
        const useDownload = downloadCheckbox ? downloadCheckbox.checked : false;
        
        // Check for authentication token
        const authTokenInput = document.getElementById("authTokenInput");
        const authToken = authTokenInput ? authTokenInput.value.trim() : '';
        
        const options = { 
            prompt: prompt,
            maxTokens: 150,
            temperature: 0.7
        };
        
        // Add download configuration if enabled
        if (useDownload) {
            const modelConfig = {
                downloadAtRuntime: true,
                downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
                modelFileName: 'gemma-3n-e2b.litertlm'
            };
            
            // Add authentication if token provided
            if (authToken) {
                modelConfig.authToken = authToken;
                modelConfig.headers = {
                    'User-Agent': 'MLPlugin-Example/1.0'
                };
            }
            
            options.modelConfig = modelConfig;
        }
        
        const result = await MLPlugin.generateText(options);
        
        console.log('Text generation results:', result);
        
        // Display results
        if (resultsDiv) {
            resultsDiv.innerHTML = `
                <h3>Generated Text:</h3>
                <div style="padding: 12px; background: #f9f9f9; border-radius: 4px; margin: 8px 0; line-height: 1.5;">
                    ${result.response}
                </div>
                <div style="margin-top: 16px; padding: 8px; background: #f5f5f5; border-radius: 4px; font-size: 12px;">
                    <strong>Platform:</strong> ${getPlatformInfo()}<br>
                    <strong>Tokens Used:</strong> ${result.tokensUsed || 'N/A'}<br>
                    <strong>Prompt:</strong> "${prompt}"
                </div>
            `;
        }
        
    } catch (error) {
        console.error('Text generation failed:', error);
        const resultsDiv = document.getElementById('textResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = `
                <div style="color: red; padding: 8px; border: 1px solid red; border-radius: 4px;">
                    <strong>Error:</strong> ${error.message || error}
                </div>
            `;
        }
    }
}

window.testRestrictedModel = async () => {
    try {
        const authTokenInput = document.getElementById("authTokenInput");
        const authToken = authTokenInput ? authTokenInput.value.trim() : '';
        
        if (!authToken) {
            alert('Please enter your Hugging Face token to test restricted model access');
            return;
        }
        
        console.log('Testing restricted model access...');
        const resultsDiv = document.getElementById('restrictedModelResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = '<h3>Testing restricted model access...</h3><div>Please wait...</div>';
        }
        
        const result = await MLPlugin.generateText({
            prompt: 'Hello, this is a test of the restricted model access.',
            maxTokens: 50,
            temperature: 0.7,
            modelConfig: {
                downloadAtRuntime: true,
                downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm',
                modelFileName: 'gemma-3n-e2b-restricted.litertlm',
                authToken: authToken,
                headers: {
                    'User-Agent': 'MLPlugin-Example/1.0'
                }
            }
        });
        
        console.log('Restricted model test results:', result);
        
        if (resultsDiv) {
            resultsDiv.innerHTML = `
                <h3>✅ Authentication Successful!</h3>
                <div style="padding: 12px; background: #e8f5e8; border-radius: 4px; margin: 8px 0; border-left: 4px solid #4caf50;">
                    <strong>Generated Response:</strong><br>
                    ${result.response}
                </div>
                <div style="margin-top: 16px; padding: 8px; background: #f5f5f5; border-radius: 4px; font-size: 12px;">
                    <strong>Token Status:</strong> Valid<br>
                    <strong>Model Access:</strong> Granted<br>
                    <strong>Tokens Used:</strong> ${result.tokensUsed || 'N/A'}
                </div>
            `;
        }
        
    } catch (error) {
        console.error('Restricted model test failed:', error);
        const resultsDiv = document.getElementById('restrictedModelResults');
        if (resultsDiv) {
            let errorMessage = 'Unknown error';
            let errorClass = 'error';
            
            if (error.message.includes('Authentication failed')) {
                errorMessage = 'Authentication failed. Please check your Hugging Face token.';
                errorClass = 'auth-error';
            } else if (error.message.includes('Access forbidden')) {
                errorMessage = 'Access forbidden. You may need to request access to this gated model at: https://huggingface.co/google/gemma-3n-E2B-it-litert-lm';
                errorClass = 'access-error';
            } else if (error.message.includes('Model not found')) {
                errorMessage = 'Model not found. The URL may be incorrect.';
                errorClass = 'not-found-error';
            } else {
                errorMessage = error.message || error;
            }
            
            resultsDiv.innerHTML = `
                <div style="color: red; padding: 8px; border: 1px solid red; border-radius: 4px; background: #ffe6e6;">
                    <strong>❌ ${errorClass === 'auth-error' ? 'Authentication' : errorClass === 'access-error' ? 'Access' : 'Error'}:</strong><br>
                    ${errorMessage}
                </div>
            `;
        }
    }
}

function getPlatformInfo() {
    const platform = window.Capacitor?.getPlatform?.() || 'web';
    switch (platform) {
        case 'ios':
            return 'iOS (MLKit + MediaPipe LLM)';
        case 'android':  
            return 'Android (MLKit + MediaPipe LLM)';
        case 'web':
            return 'Web (Stub)';
        default:
            return platform;
    }
}
