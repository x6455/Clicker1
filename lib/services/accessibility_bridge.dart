// lib/services/accessibility_bridge.dart
import 'package:flutter/services.dart';

class AccessibilityBridge {
  static const _channel = MethodChannel('com.macrorunner/accessibility');

  /// Check if accessibility service is enabled
  static Future<bool> isServiceEnabled() async {
    try {
      return await _channel.invokeMethod('isAccessibilityEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open accessibility settings
  static Future<void> openSettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }

  /// Launch a target app
  static Future<void> launchApp(String packageName) async {
    await _channel.invokeMethod('launchApp', {
      'packageName': packageName,
    });
  }

  /// Tap at coordinates
  static Future<void> tap(double x, double y) async {
    await _channel.invokeMethod('tapAtCoordinates', {
      'x': x,
      'y': y,
    });
  }

  /// Swipe gesture
  static Future<void> swipe({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    int duration = 300,
  }) async {
    await _channel.invokeMethod('swipe', {
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'duration': duration,
    });
  }

  /// Input text into focused field
  static Future<void> inputText(String text) async {
    await _channel.invokeMethod('inputText', {'text': text});
  }

  /// Press back button
  static Future<void> pressBack() async {
    await _channel.invokeMethod('pressBack');
  }

  /// Press home button
  static Future<void> pressHome() async {
    await _channel.invokeMethod('pressHome');
  }
}
