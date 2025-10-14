package com.mycompany.plugins.example;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import com.getcapacitor.Logger;
import com.getcapacitor.JSObject;
import com.getcapacitor.JSArray;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.label.ImageLabel;
import com.google.mlkit.vision.label.ImageLabeler;
import com.google.mlkit.vision.label.ImageLabeling;
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions;
import com.google.mediapipe.tasks.genai.llminference.LlmInference;
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions;
import java.util.concurrent.CompletableFuture;
import java.util.List;

public class MLPlugin {
    
    private ImageLabeler imageLabeler;
    private LlmInference llmInference;
    
    public MLPlugin() {
        // Initialize MLKit Image Labeler with default options
        ImageLabelerOptions options = new ImageLabelerOptions.Builder()
                .setConfidenceThreshold(0.7f)
                .build();
        imageLabeler = ImageLabeling.getClient(options);
        
        // LLM Inference will be initialized on first use
        llmInference = null;
    }

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }

    public CompletableFuture<JSObject> classifyImageAsync(String base64Image) {
        Logger.info("classifyImage called on Android with base64 image length: " + base64Image.length());
        
        CompletableFuture<JSObject> future = new CompletableFuture<>();
        
        try {
            // Decode base64 to bitmap
            Bitmap bitmap = decodeBase64ToBitmap(base64Image);
            if (bitmap == null) {
                JSObject errorResult = new JSObject();
                errorResult.put("error", "Failed to decode base64 image");
                future.complete(errorResult);
                return future;
            }
            
            // Convert bitmap to InputImage for MLKit
            InputImage image = InputImage.fromBitmap(bitmap, 0);
            
            // Process image with MLKit
            imageLabeler.process(image)
                .addOnSuccessListener(labels -> {
                    JSObject result = new JSObject();
                    JSArray predictions = new JSArray();
                    
                    // Convert MLKit results to our format
                    for (ImageLabel label : labels) {
                        JSObject prediction = new JSObject();
                        prediction.put("label", label.getText());
                        prediction.put("confidence", (double) label.getConfidence());
                        predictions.put(prediction);
                    }
                    
                    result.put("predictions", predictions);
                    Logger.info("MLKit classification completed with " + labels.size() + " predictions");
                    future.complete(result);
                })
                .addOnFailureListener(e -> {
                    Logger.error("MLKit classification failed", e.getMessage(), e);
                    JSObject errorResult = new JSObject();
                    errorResult.put("error", "MLKit classification failed: " + e.getMessage());
                    future.complete(errorResult);
                });
                
        } catch (Exception e) {
            Logger.error("Exception in classifyImage", e.getMessage(), e);
            JSObject errorResult = new JSObject();
            errorResult.put("error", "Exception: " + e.getMessage());
            future.complete(errorResult);
        }
        
        return future;
    }
    
    private Bitmap decodeBase64ToBitmap(String base64String) {
        try {
            String base64Data = base64String;
            
            // Handle data URI format (data:image/jpeg;base64,...)
            if (base64String.startsWith("data:image/")) {
                String[] parts = base64String.split(",");
                if (parts.length == 2) {
                    base64Data = parts[1];
                    Logger.info("Extracted base64 data from data URI");
                } else {
                    Logger.error("Invalid data URI format");
                    return null;
                }
            }
            
            // Decode base64 to byte array
            byte[] decodedBytes = Base64.decode(base64Data, Base64.DEFAULT);
            
            // Create bitmap from byte array
            Bitmap bitmap = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
            
            if (bitmap != null) {
                Logger.info("Successfully decoded base64 to bitmap: " + bitmap.getWidth() + "x" + bitmap.getHeight());
            } else {
                Logger.error("Failed to create bitmap from decoded bytes");
            }
            
            return bitmap;
            
        } catch (Exception e) {
            Logger.error("Failed to decode base64 to bitmap", e.getMessage(), e);
            return null;
        }
    }
    
    public CompletableFuture<JSObject> generateText(String prompt, int maxTokens, float temperature) {
        Logger.info("generateText called on Android with prompt: " + prompt);
        
        return CompletableFuture.supplyAsync(() -> {
            JSObject result = new JSObject();
            
            try {
                // Initialize LLM Inference if not already done
                if (llmInference == null) {
                    // Note: For a real implementation, you would need to download and specify a model file
                    // For now, we'll provide a meaningful error about the missing model
                    LlmInferenceOptions options = LlmInferenceOptions.builder()
                            .setMaxTokens(maxTokens)
                            .setTemperature(temperature)
                            .setTopK(40)
                            .setRandomSeed(101)
                            // .setModelPath("/data/local/tmp/llm/model.task") // Path to your downloaded model
                            .build();
                            
                    // This will fail without a real model, so we'll catch and provide a meaningful error
                    try {
                        llmInference = LlmInference.createFromOptions(null, options);
                        Logger.info("LLM Inference initialized successfully");
                    } catch (Exception e) {
                        Logger.error("Failed to initialize LLM Inference", e.getMessage(), e);
                        result.put("error", "LLM model not found. Please download a compatible model file (e.g., gemma-3-1b-it.task) and set the correct path.");
                        return result;
                    }
                }
                
                // Generate response using MediaPipe LLM Inference
                String response = llmInference.generateResponse(prompt);
                
                result.put("response", response);
                result.put("tokensUsed", response.length() / 4); // Rough estimate of token count
                
                Logger.info("LLM generation completed successfully");
                return result;
                
            } catch (Exception e) {
                Logger.error("LLM generation failed", e.getMessage(), e);
                result.put("error", "Text generation failed: " + e.getMessage());
                return result;
            }
        });
    }
}
