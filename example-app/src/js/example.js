import { MLPlugin } from 'ml-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    MLPlugin.echo({ value: inputValue })
}

window.testClassifyImage = async () => {
    try {
        // Example image path - in a real app, you'd get this from a file picker or camera
        const imagePath = '/path/to/your/test/image.jpg';
        
        const result = await MLPlugin.classifyImage({ imagePath });
        
        console.log('Classification results:', result);
        
        // Display results
        const resultsDiv = document.getElementById('classificationResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = '<h3>Classification Results:</h3>';
            result.predictions.forEach((prediction, index) => {
                resultsDiv.innerHTML += `
                    <div>
                        <strong>${index + 1}.</strong> 
                        ${prediction.label} 
                        (${(prediction.confidence * 100).toFixed(1)}%)
                    </div>
                `;
            });
        }
        
    } catch (error) {
        console.error('Classification failed:', error);
        const resultsDiv = document.getElementById('classificationResults');
        if (resultsDiv) {
            resultsDiv.innerHTML = `<div style="color: red;">Error: ${error.message}</div>`;
        }
    }
}
