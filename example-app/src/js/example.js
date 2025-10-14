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
        
        const result = await MLPlugin.classifyImage({ base64Image });
        
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
