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
import java.util.concurrent.CompletableFuture;
import java.util.List;

public class MLPlugin {
    
    private ImageLabeler imageLabeler;
    
    public MLPlugin() {
        // Initialize MLKit Image Labeler with default options
        ImageLabelerOptions options = new ImageLabelerOptions.Builder()
                .setConfidenceThreshold(0.7f)
                .build();
        imageLabeler = ImageLabeling.getClient(options);
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
}
