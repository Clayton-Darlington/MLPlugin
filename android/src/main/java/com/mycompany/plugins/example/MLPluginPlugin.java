package com.mycompany.plugins.example;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "MLPlugin")
public class MLPluginPlugin extends Plugin {

    private MLPlugin implementation = new MLPlugin();

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", implementation.echo(value));
        call.resolve(ret);
    }

    @PluginMethod
    public void classifyImage(PluginCall call) {
        String base64Image = call.getString("base64Image");
        
        if (base64Image == null) {
            call.reject("base64Image is required");
            return;
        }

        // Handle async MLKit processing
        implementation.classifyImageAsync(base64Image)
            .thenAccept(result -> {
                if (result.has("error")) {
                    call.reject(result.getString("error"));
                } else {
                    call.resolve(result);
                }
            })
            .exceptionally(throwable -> {
                call.reject("Unexpected error: " + throwable.getMessage());
                return null;
            });
    }

    @PluginMethod
    public void generateText(PluginCall call) {
        String prompt = call.getString("prompt");
        
        if (prompt == null) {
            call.reject("prompt is required");
            return;
        }

        int maxTokens = call.getInt("maxTokens", 100);
        float temperature = call.getFloat("temperature", 0.7f);
        
        // Parse model configuration
        JSObject modelConfig = call.getObject("modelConfig");
        boolean downloadAtRuntime = false;
        String downloadUrl = null;
        String modelFileName = null;
        
        if (modelConfig != null) {
            downloadAtRuntime = modelConfig.getBool("downloadAtRuntime", false);
            downloadUrl = modelConfig.getString("downloadUrl");
            modelFileName = modelConfig.getString("modelFileName");
        }

        // Handle async LLM processing
        implementation.generateText(prompt, maxTokens, temperature, downloadAtRuntime, downloadUrl, modelFileName)
            .thenAccept(result -> {
                if (result.has("error")) {
                    call.reject(result.getString("error"));
                } else {
                    call.resolve(result);
                }
            })
            .exceptionally(throwable -> {
                call.reject("Unexpected error: " + throwable.getMessage());
                return null;
            });
    }
}
