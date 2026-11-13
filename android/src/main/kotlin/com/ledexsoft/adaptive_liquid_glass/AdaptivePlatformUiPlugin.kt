package com.ledexsoft.adaptive_liquid_glass

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** AdaptivePlatformUiPlugin */
class AdaptivePlatformUiPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      M3EPlatformViewFactory.VIEW_TYPE,
      M3EPlatformViewFactory(
        flutterPluginBinding.binaryMessenger,
        flutterPluginBinding.flutterAssets::getAssetFilePathByName,
      ),
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
