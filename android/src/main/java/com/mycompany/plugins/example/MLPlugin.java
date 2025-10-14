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
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

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
    
    private String downloadModel(String urlString, String fileName) throws IOException {
        URL url = new URL(urlString);
        
        // Determine file name
        String finalFileName = fileName != null ? fileName : 
            url.getPath().substring(url.getPath().lastIndexOf('/') + 1);
        if (finalFileName.isEmpty()) {
            finalFileName = "downloaded_model.litertlm";
        }
        
        // Create download directory
        File downloadDir = new File("/data/local/tmp/llm/");
        if (!downloadDir.exists()) {
            downloadDir.mkdirs();
        }
        
        File localFile = new File(downloadDir, finalFileName);
        
        // Check if file already exists
        if (localFile.exists()) {
            Logger.info("Model already exists at: " + localFile.getAbsolutePath());
            return localFile.getAbsolutePath();
        }
        
        Logger.info("Downloading model to: " + localFile.getAbsolutePath());
        
        // Download the file
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(30000); // 30 seconds
        connection.setReadTimeout(300000);   // 5 minutes
        
        int responseCode = connection.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            throw new IOException("Download failed with response code: " + responseCode);
        }
        
        // Stream the download
        try (InputStream inputStream = connection.getInputStream();
             FileOutputStream outputStream = new FileOutputStream(localFile)) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            long totalBytes = 0;
            
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
                totalBytes += bytesRead;
            }
            
            Logger.info("Model downloaded successfully: " + totalBytes + " bytes to " + localFile.getAbsolutePath());
        }
        
        return localFile.getAbsolutePath();
    }
    
    public CompletableFuture<JSObject> generateText(String prompt, int maxTokens, float temperature, boolean downloadAtRuntime, String downloadUrl, String modelFileName) {
        Logger.info("generateText called on Android with prompt: " + prompt);
        
        return CompletableFuture.supplyAsync(() -> {
            JSObject result = new JSObject();
            
            try {
                // Initialize LLM Inference if not already done
                if (llmInference == null) {
                    String modelPath;
                    
                    if (downloadAtRuntime && downloadUrl != null) {
                        // Download model at runtime
                        Logger.info("Downloading model from: " + downloadUrl);
                        try {
                            modelPath = downloadModel(downloadUrl, modelFileName);
                        } catch (Exception e) {
                            Logger.error("Failed to download model", e.getMessage(), e);
                            result.put("error", "Failed to download model from " + downloadUrl + ": " + e.getMessage());
                            return result;
                        }
                    } else {
                        // Use local model path
                        String fileName = modelFileName != null ? modelFileName : "gemma-3n-e2b.litertlm";
                        modelPath = "/data/local/tmp/llm/" + fileName;
                        Logger.info("Using local model: " + modelPath);
                    }
                    
                    LlmInferenceOptions options = LlmInferenceOptions.builder()
                            .setModelPath(modelPath)
                            .setMaxTokens(maxTokens)
                            .setTemperature(temperature)
                            .setTopK(40)
                            .setRandomSeed(101)
                            .build();
                            
                    try {
                        llmInference = LlmInference.createFromOptions(null, options);
                        Logger.info("LLM Inference initialized successfully with model: " + modelPath);
                    } catch (Exception e) {
                        Logger.error("Failed to initialize LLM Inference", e.getMessage(), e);
                        String errorMsg = downloadAtRuntime ? 
                            "Failed to initialize LLM with downloaded model" :
                            "LLM model not found at " + modelPath + ". Please download a compatible model file or use downloadAtRuntime option.";
                        result.put("error", errorMsg);
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
