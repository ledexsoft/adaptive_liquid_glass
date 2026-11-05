package com.ledexsoft.adaptive_liquid_glass

import android.content.Context
import android.view.View
import android.view.ViewGroup
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class M3EPlatformViewFactory(
  private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    return M3EPlatformView(context, viewId, args, messenger)
  }

  companion object {
    const val VIEW_TYPE = "adaptive_liquid_glass/m3e_android"
  }
}

private class M3EPlatformView(
  context: Context,
  viewId: Int,
  creationParams: Any?,
  messenger: BinaryMessenger,
) : PlatformView {
  private val properties = mutableStateOf(asStringMap(creationParams))
  private val channel = MethodChannel(
    messenger,
    "adaptive_liquid_glass/m3e_android_$viewId",
  )
  private val composeView = ComposeView(context).apply {
    layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT,
    )
    setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
    setContent {
      val currentProperties = properties.value
      M3EAndroidTheme(currentProperties) {
        M3EAndroidContent(currentProperties) { event, value ->
          channel.invokeMethod(event, value)
        }
      }
    }
  }

  init {
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "setProperties" -> {
          properties.value = asStringMap(call.arguments)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }

  override fun getView(): View = composeView

  override fun dispose() {
    channel.setMethodCallHandler(null)
    composeView.disposeComposition()
  }
}

private fun asStringMap(value: Any?): Map<String, Any?> {
  val map = value as? Map<*, *> ?: return emptyMap()
  return map.entries.associate { (key, entryValue) -> key.toString() to entryValue }
}
