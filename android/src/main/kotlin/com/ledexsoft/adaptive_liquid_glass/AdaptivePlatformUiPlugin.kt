package com.ledexsoft.adaptive_liquid_glass

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** AdaptivePlatformUiPlugin */
class AdaptivePlatformUiPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Android uses Material Design widgets directly in Dart
    // No platform views needed for Android
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
