import Foundation
import UIKit
import MLKitImageLabeling
import MLKitVision
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

@objc public class MLPlugin: NSObject {
    
    private var imageLabeler: ImageLabeler
    private var llmInference: LlmInference?
    private var currentLLMModelName: String?
    private var modelInitializationTask: Task<Void, Never>?
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    override init() {
        // Initialize MLKit Image Labeler with default options (same as Android)
        let options = ImageLabelerOptions()
        options.confidenceThreshold = 0.7
        imageLabeler = ImageLabeler.imageLabeler(options: options)
        
        // Initialize LLM Inference as nil initially
        llmInference = nil
        
        super.init()
        
        print("MLPlugin initialized - using MLKit Image Labeling")
        
        // Start model initialization in background
        initializeDefaultModel()
    }
    
    private func initializeDefaultModel() {
        modelInitializationTask = Task {
            await initializeLLMModel(
                downloadAtRuntime: true,
                downloadUrl: "https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/model.litertlm",
                modelFileName: "gemma-3n-2b.litertlm",
                maxTokens: 1000,
                authToken: nil, // Will need to be provided by user for restricted models
                headers: nil
            )
        }
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
                    "confidence": Double(label.confidence),
                    "modelName": "Google MLKit Image Labeler"
                ]
            }
            
            print("MLKit classification completed with \(labels.count) predictions")
            completion(.success(predictions))
        }
    }
    
    public func generateText(prompt: String, maxTokens: Int = 100, temperature: Float = 0.7, topK: Int? = nil, topP: Float? = nil, randomSeed: Int? = nil, downloadAtRuntime: Bool = false, downloadUrl: String? = nil, modelFileName: String? = nil, authToken: String? = nil, headers: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) async {
        print("generateText called on iOS with prompt: \(prompt)")
        
        // Wait for default model initialization if still in progress
        if llmInference == nil {
            print("LLM not ready, waiting for initialization...")
            await modelInitializationTask?.value
            
            // If still nil after default initialization, try to initialize with custom parameters
            if llmInference == nil {
                await initializeLLMModel(
                    downloadAtRuntime: downloadAtRuntime,
                    downloadUrl: downloadUrl,
                    modelFileName: modelFileName,
                    maxTokens: maxTokens,
                    authToken: authToken,
                    headers: headers
                )
            }
        }
        
        // Check if initialization was successful
        guard let llmInference = llmInference else {
            completion(.failure(NSError(domain: "MLPlugin", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize LLM model"])))
            return
        }
        
        // Generate response using MediaPipe LLM Inference
        do {
            let result = try llmInference.generateResponse(inputText: prompt)
            
            let response: [String: Any] = [
                "response": result,
                "tokensUsed": result.count / 4, // Rough estimate of token count
                "modelName": currentLLMModelName ?? "MediaPipe LLM"
            ]
            
            print("LLM generation completed successfully")
            completion(.success(response))
        } catch {
            print("LLM generation failed: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    private func initializeLLMModel(downloadAtRuntime: Bool, downloadUrl: String?, modelFileName: String?, maxTokens: Int, authToken: String? = nil, headers: [String: String]? = nil) async {
        do {
            var modelPath: String?
            var currentModelName: String
            
            if downloadAtRuntime, let url = downloadUrl {
                // Download model at runtime
                print("Downloading model from: \(url)")
                modelPath = try await downloadModel(from: url, fileName: modelFileName, authToken: authToken, headers: headers)
                currentModelName = modelFileName ?? URL(string: url)?.lastPathComponent ?? "Downloaded Model"
            } else {
                // Use bundled model
                let fileName = modelFileName ?? "gemma-3n-2b"
                let fileExtension = (fileName.contains(".") ? "" : "litertlm")
                modelPath = Bundle.main.path(forResource: fileName, ofType: fileExtension)
                currentModelName = fileName
                print("Using bundled model: \(fileName)")
            }
            
            guard let validModelPath = modelPath else {
                let errorMsg = downloadAtRuntime ? 
                    "Failed to download model from \(downloadUrl ?? "unknown URL")" :
                    "Bundled model not found. Please add a compatible model file to your iOS app bundle."
                print("Model initialization failed: \(errorMsg)")
                return
            }
            
            let options = LlmInference.Options(modelPath: validModelPath)
            options.maxTokens = maxTokens
            
            llmInference = try LlmInference(options: options)
            currentLLMModelName = currentModelName
            print("LLM Inference initialized successfully with model: \(currentModelName)")
        } catch {
            print("Failed to initialize LLM Inference: \(error)")
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
    
    private func downloadModel(from urlString: String, fileName: String?, authToken: String? = nil, headers: [String: String]? = nil) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "MLPlugin", code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid download URL: \(urlString)"])
        }
        
        // Determine file name
        let finalFileName = fileName ?? (url.lastPathComponent.isEmpty ? "downloaded_model.litertlm" : url.lastPathComponent)
        
        // Get documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localFileURL = documentsPath.appendingPathComponent(finalFileName)
        
        // Check if file already exists
        if FileManager.default.fileExists(atPath: localFileURL.path) {
            print("Model already exists at: \(localFileURL.path)")
            return localFileURL.path
        }
        
        print("Downloading model to: \(localFileURL.path)")
        
        // Create URL request with authentication if needed
        var request = URLRequest(url: url)
        request.timeoutInterval = 600 // 10 minutes for large model downloads
        
        // Add authentication token if provided (for Hugging Face gated models)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Added authentication token for restricted model access")
        }
        
        // Add custom headers if provided
        if let customHeaders = headers {
            for (key, value) in customHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Download the file using data task
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Verify response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "MLPlugin", code: 6, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage: String
            switch httpResponse.statusCode {
            case 401:
                errorMessage = "Authentication failed. Please check your access token."
            case 403:
                errorMessage = "Access forbidden. You may need to request access to this gated model."
            case 404:
                errorMessage = "Model not found at the specified URL."
            default:
                errorMessage = "Download failed with HTTP status code: \(httpResponse.statusCode)"
            }
            throw NSError(domain: "MLPlugin", code: 6, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // Write data to local file
        try data.write(to: localFileURL)
        
        print("Model downloaded successfully to: \(localFileURL.path)")
        return localFileURL.path
    }
}
