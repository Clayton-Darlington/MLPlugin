import Foundation
import UIKit
import Vision
import CoreML

@objc public class MLPlugin: NSObject {
    
    private var yoloModel: VNCoreMLModel?
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    override init() {
        // Initialize YOLO model as nil initially - will be loaded from app bundle
        yoloModel = nil
        
        super.init()
        
        // Load YOLOv8s model from app bundle
        loadYOLOModel()
        
        print("MLPlugin initialized - using YOLOv8s model")
    }
    
    private func loadYOLOModel() {
        // Look for yolov8s.mlmodel or yolov8s.mlmodelc in the app bundle
        guard let modelURL = Bundle.main.url(forResource: "yolov8s", withExtension: "mlmodelc") 
                ?? Bundle.main.url(forResource: "yolov8s", withExtension: "mlmodel") else {
            print("Warning: yolov8s model not found in app bundle. Please add yolov8s.mlmodel or yolov8s.mlmodelc to your iOS app.")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            yoloModel = try VNCoreMLModel(for: mlModel)
            print("YOLOv8s model loaded successfully from: \(modelURL.lastPathComponent)")
        } catch {
            print("Failed to load YOLOv8s model: \(error.localizedDescription)")
        }
    }
    
    public func detectObjects(base64Image: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        print("detectObjects called on iOS with base64 image length: \(base64Image.count)")
        
        // Check if YOLOv8s model is loaded
        guard let yoloModel = yoloModel else {
            completion(.failure(NSError(domain: "MLPlugin", code: 2, userInfo: [NSLocalizedDescriptionKey: "YOLOv8s model not loaded. Please add yolov8s.mlmodel or yolov8s.mlmodelc to your iOS app bundle."])))
            return
        }
        
        // Convert base64 string to UIImage
        guard let image = loadImageFromBase64(base64Image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not decode base64 image data"])))
            return
        }
        
        // Convert UIImage to CIImage for Vision processing
        guard let ciImage = CIImage(image: image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to CIImage"])))
            return
        }
        
        // Create Vision request with YOLOv8s model for object detection
        let request = VNCoreMLRequest(model: yoloModel) { request, error in
            if let error = error {
                print("YOLOv8s object detection failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let results = request.results else {
                completion(.failure(NSError(domain: "MLPlugin", code: 4, userInfo: [NSLocalizedDescriptionKey: "No detection results from YOLOv8s"])))
                return
            }
            
            // Process YOLOv8s object detection results
            var detections: [[String: Any]] = []
            
            for result in results {
                if let objectObservation = result as? VNRecognizedObjectObservation {
                    // Get the top label for each detected object
                    if let topLabel = objectObservation.labels.first {
                        let bbox = objectObservation.boundingBox
                        detections.append([
                            "label": topLabel.identifier,
                            "confidence": Double(topLabel.confidence),
                            "boundingBox": [
                                "x": bbox.origin.x,
                                "y": bbox.origin.y,
                                "width": bbox.size.width,
                                "height": bbox.size.height
                            ],
                            "modelName": "YOLOv8s"
                        ])
                    }
                }
            }
            
            guard !detections.isEmpty else {
                completion(.failure(NSError(domain: "MLPlugin", code: 5, userInfo: [NSLocalizedDescriptionKey: "No objects detected by YOLOv8s"])))
                return
            }
            
            // Sort by confidence
            let sortedDetections = detections.sorted { 
                ($0["confidence"] as? Double ?? 0) > ($1["confidence"] as? Double ?? 0) 
            }
            
            print("YOLOv8s object detection completed with \(sortedDetections.count) detections")
            completion(.success(sortedDetections))
        }
        
        // Set request parameters for better detection
        request.imageCropAndScaleOption = .scaleFill
        
        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform YOLOv8s object detection: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    public func classifyImage(base64Image: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        print("classifyImage called on iOS with base64 image length: \(base64Image.count)")
        
        // Check if YOLOv8s model is loaded
        guard let yoloModel = yoloModel else {
            completion(.failure(NSError(domain: "MLPlugin", code: 2, userInfo: [NSLocalizedDescriptionKey: "YOLOv8s model not loaded. Please add yolov8s.mlmodel or yolov8s.mlmodelc to your iOS app bundle."])))
            return
        }
        
        // Convert base64 string to UIImage
        guard let image = loadImageFromBase64(base64Image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not decode base64 image data"])))
            return
        }
        
        // Convert UIImage to CIImage for Vision processing
        guard let ciImage = CIImage(image: image) else {
            completion(.failure(NSError(domain: "MLPlugin", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to CIImage"])))
            return
        }
        
        // Create Vision request with YOLOv8s model
        let request = VNCoreMLRequest(model: yoloModel) { request, error in
            if let error = error {
                print("YOLOv8s detection failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let results = request.results else {
                completion(.failure(NSError(domain: "MLPlugin", code: 4, userInfo: [NSLocalizedDescriptionKey: "No detection results from YOLOv8s"])))
                return
            }
            
            // Process YOLOv8s results
            var predictions: [[String: Any]] = []
            
            // YOLOv8s typically returns VNRecognizedObjectObservation for object detection
            for result in results {
                if let objectObservation = result as? VNRecognizedObjectObservation {
                    // Get the top label for each detected object
                    if let topLabel = objectObservation.labels.first {
                        let bbox = objectObservation.boundingBox
                        predictions.append([
                            "label": topLabel.identifier,
                            "confidence": Double(topLabel.confidence),
                            "boundingBox": [
                                "x": bbox.origin.x,
                                "y": bbox.origin.y,
                                "width": bbox.size.width,
                                "height": bbox.size.height
                            ],
                            "modelName": "YOLOv8s"
                        ])
                    }
                } else if let classificationObservation = result as? VNClassificationObservation {
                    // Fallback for classification-style models
                    predictions.append([
                        "label": classificationObservation.identifier,
                        "confidence": Double(classificationObservation.confidence),
                        "modelName": "YOLOv8s"
                    ])
                }
            }
            
            guard !predictions.isEmpty else {
                completion(.failure(NSError(domain: "MLPlugin", code: 5, userInfo: [NSLocalizedDescriptionKey: "No objects detected by YOLOv8s"])))
                return
            }
            
            // Sort by confidence and return top results
            let sortedPredictions = predictions.sorted { 
                ($0["confidence"] as? Double ?? 0) > ($1["confidence"] as? Double ?? 0) 
            }
            
            print("YOLOv8s detection completed with \(sortedPredictions.count) predictions")
            completion(.success(sortedPredictions))
        }
        
        // Set request parameters for better detection
        request.imageCropAndScaleOption = .scaleFill
        
        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform YOLOv8s detection: \(error.localizedDescription)")
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
