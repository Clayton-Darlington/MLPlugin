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

        JSObject result = implementation.classifyImage(base64Image);
        call.resolve(result);
    }
}
