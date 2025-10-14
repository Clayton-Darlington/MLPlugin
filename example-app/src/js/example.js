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
        
        const result = await MLPlugin.generateText({ 
            prompt: prompt,
            maxTokens: 150,
            temperature: 0.7
        });
        
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
