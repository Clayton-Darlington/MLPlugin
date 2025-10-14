import Foundation
import Vision
import UIKit

@objc public class MLPlugin: NSObject {
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    override init() {
        super.init()
        print("MLPlugin initialized - using default Vision framework classification")
    }
    

    
    public func classifyImage(base64Image: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        // Convert base64 string to UIImage
        guard let image = loadImageFromBase64(base64Image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not decode base64 image data"])))
            return
        }
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to CIImage"])))
            return
        }
        
        // Use Vision's built-in image classification
        if #available(iOS 13.0, *) {
            // Create a VNClassifyImageRequest for built-in classification
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    completion(.failure(NSError(domain: "MLPlugin", code: 3, userInfo: [NSLocalizedDescriptionKey: "No classification results"])))
                    return
                }
                
                // Convert results to the expected format
                let predictions = results.prefix(5).map { result in
                    return [
                        "label": result.identifier,
                        "confidence": Double(result.confidence)
                    ] as [String: Any]
                }
                
                completion(.success(Array(predictions)))
            }
        
            // VNClassifyImageRequest doesn't have imageCropAndScaleOption
            // It handles image scaling automatically
            
            // Perform the request
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    completion(.failure(error))
                }
            }
        } else {
            // Fallback for iOS < 13.0
            completion(.failure(NSError(domain: "MLPlugin", code: 4, userInfo: [NSLocalizedDescriptionKey: "VNClassifyImageRequest requires iOS 13.0 or later"])))
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
