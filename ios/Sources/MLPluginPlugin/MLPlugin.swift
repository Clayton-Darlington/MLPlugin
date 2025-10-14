import Foundation
import UIKit
import MLKitImageLabeling
import MLKitVision

@objc public class MLPlugin: NSObject {
    
    private var imageLabeler: ImageLabeler
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    override init() {
        // Initialize MLKit Image Labeler with default options (same as Android)
        let options = ImageLabelerOptions()
        options.confidenceThreshold = 0.7
        imageLabeler = ImageLabeler.imageLabeler(options: options)
        
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
