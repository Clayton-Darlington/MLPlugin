package com.mycompany.plugins.example;

import com.getcapacitor.Logger;
import com.getcapacitor.JSObject;
import com.getcapacitor.JSArray;

public class MLPlugin {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }

    public JSObject classifyImage(String base64Image) {
        Logger.info("classifyImage called on Android with base64 image length: " + base64Image.length());
        
        // Stub implementation for Android
        JSObject result = new JSObject();
        JSArray predictions = new JSArray();
        
        JSObject prediction = new JSObject();
        prediction.put("label", "android-stub-prediction");
        prediction.put("confidence", 0.95);
        predictions.put(prediction);
        
        result.put("predictions", predictions);
        return result;
    }
}
