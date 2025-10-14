import Foundation
import UIKit
import MLKitImageLabeling
import MLKitVision
import MediaPipeTasksGenAI

@objc public class MLPlugin: NSObject {
    
    private var imageLabeler: ImageLabeler
    private var llmInference: LlmInference?
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    override init() {
        // Initialize MLKit Image Labeler with default options (same as Android)
        let options = ImageLabelerOptions()
        options.confidenceThreshold = 0.7
        imageLabeler = ImageLabeler.imageLabeler(options: options)
        
        // Initialize LLM Inference (will be configured when first used)
        llmInference = nil
        
        super.init()
        
        print("MLPlugin initialized - using MLKit Image Labeling")
    }
    

    
    public func classifyImage(base64Image: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        print("classifyImage called on iOS with base64 image length: \(base64Image.count)")
        
        // Convert base64 string to UIImage
        guard let image = loadImageFromBase64(base64Image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not decode base64 image data"])))
            return
        }
        
        // Convert UIImage to MLKit VisionImage
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        // Process image with MLKit (same as Android implementation)
        imageLabeler.process(visionImage) { labels, error in
            if let error = error {
                print("MLKit classification failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let labels = labels, !labels.isEmpty else {
                completion(.failure(NSError(domain: "MLPlugin", code: 3, userInfo: [NSLocalizedDescriptionKey: "No classification results from MLKit"])))
                return
            }
            
            // Convert MLKit results to our format (same as Android)
            let predictions: [[String: Any]] = labels.prefix(5).map { label in
                return [
                    "label": label.text,
                    "confidence": Double(label.confidence)
                ]
            }
            
            print("MLKit classification completed with \(labels.count) predictions")
            completion(.success(predictions))
        }
    }
    
    public func generateText(prompt: String, maxTokens: Int = 100, temperature: Float = 0.7, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        print("generateText called on iOS with prompt: \(prompt)")
        
        // Initialize LLM if not already done
        if llmInference == nil {
            do {
                let options = LlmInferenceOptions()
                // Note: For a real implementation, you would need to add a model file to your bundle
                // For now, we'll create a stub that indicates the model is missing
                options.maxTokens = maxTokens
                options.temperature = temperature
                options.randomSeed = 101
                
                // This will fail without a real model, so we'll catch and provide a meaningful error
                llmInference = try LlmInference(options: options)
                print("LLM Inference initialized successfully")
            } catch {
                print("Failed to initialize LLM Inference: \(error)")
                completion(.failure(NSError(domain: "MLPlugin", code: 4, userInfo: [NSLocalizedDescriptionKey: "LLM model not found. Please add a compatible model file (e.g., gemma-2-2b-it-gpu-int8.bin) to your iOS app bundle."])))
                return
            }
        }
        
        // Generate response using MediaPipe LLM Inference
        do {
            let result = try llmInference!.generateResponse(inputText: prompt)
            
            let response: [String: Any] = [
                "response": result,
                "tokensUsed": result.count / 4 // Rough estimate of token count
            ]
            
            print("LLM generation completed successfully")
            completion(.success(response))
        } catch {
            print("LLM generation failed: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    private func loadImageFromBase64(_ base64String: String) -> UIImage? {
        print("Attempting to decode base64 image, length: \(base64String.count)")
        
        var base64Data = base64String
        
        // Handle data URI format (data:image/jpeg;base64,...)
        if base64String.hasPrefix("data:image/") {
            let components = base64String.components(separatedBy: ",")
            if components.count == 2 {
                base64Data = components[1]
                print("Extracted base64 data from data URI")
            } else {
                print("Invalid data URI format")
                return nil
            }
        }
        
        // Decode base64 string to Data
        guard let imageData = Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters) else {
            print("Failed to decode base64 string to Data")
            return nil
        }
        
        // Create UIImage from Data
        guard let image = UIImage(data: imageData) else {
            print("Failed to create UIImage from decoded data")
            return nil
        }
        
        print("Successfully decoded base64 image: \(image.size.width)x\(image.size.height)")
        return image
    }
}
