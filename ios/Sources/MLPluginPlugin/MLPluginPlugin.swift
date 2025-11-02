import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(MLPluginPlugin)
public class MLPluginPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MLPluginPlugin"
    public let jsName = "MLPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "classifyImage", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = MLPlugin()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func classifyImage(_ call: CAPPluginCall) {
        guard let base64Image = call.getString("base64Image") else {
            call.reject("base64Image is required")
            return
        }
        
        implementation.classifyImage(base64Image: base64Image) { result in
            switch result {
            case .success(let predictions):
                call.resolve([
                    "predictions": predictions
                ])
            case .failure(let error):
                call.reject("Classification failed: \(error.localizedDescription)")
            }
        }
    }
}
