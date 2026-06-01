package com.example.starterapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.starterapp/accessibility"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAccessibilityEnabled" -> {
                        result.success(MacroAccessibilityService.isServiceEnabled)
                    }
                    "openAccessibilitySettings" -> {
                        MacroAccessibilityService.openAccessibilitySettings(this)
                        result.success(true)
                    }
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName") ?: ""
                        MacroAccessibilityService.instance?.launchApp(packageName)
                        result.success(true)
                    }
                    "tapAtCoordinates" -> {
                        val x = call.argument<Double>("x") ?: 0.0
                        val y = call.argument<Double>("y") ?: 0.0
                        MacroAccessibilityService.instance?.tapAtCoordinates(
                            x.toFloat(), 
                            y.toFloat()
                        )
                        result.success(true)
                    }
                    "swipe" -> {
                        val x1 = call.argument<Double>("x1") ?: 0.0
                        val y1 = call.argument<Double>("y1") ?: 0.0
                        val x2 = call.argument<Double>("x2") ?: 0.0
                        val y2 = call.argument<Double>("y2") ?: 0.0
                        val duration = call.argument<Long>("duration") ?: 300L
                        MacroAccessibilityService.instance?.swipe(
                            x1.toFloat(), y1.toFloat(),
                            x2.toFloat(), y2.toFloat(),
                            duration
                        )
                        result.success(true)
                    }
                    "inputText" -> {
                        val text = call.argument<String>("text") ?: ""
                        MacroAccessibilityService.instance?.inputText(text)
                        result.success(true)
                    }
                    "pressBack" -> {
                        MacroAccessibilityService.instance?.pressBack()
                        result.success(true)
                    }
                    "pressHome" -> {
                        MacroAccessibilityService.instance?.pressHome()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
