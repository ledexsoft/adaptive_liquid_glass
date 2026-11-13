package com.ledexsoft.adaptive_liquid_glass

import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import android.view.ContextThemeWrapper
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedDispatcherOwner
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.SavedStateRegistryController
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.Locale
import kotlinx.coroutines.channels.Channel

internal data class M3ECardPressEvent(
  val id: Long,
  val position: Offset? = null,
  val cancelled: Boolean = false,
)

internal data class M3EToolbarScrollEvent(
  val logicalDelta: Float = 0f,
  val settle: Boolean = false,
  val reset: Boolean = false,
  val resetToken: Long = 0L,
)

internal class M3EPlatformViewFactory(
  private val messenger: BinaryMessenger,
  private val assetPath: (String) -> String,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  private var flutterFonts: M3EFlutterFonts? = null

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val fonts = flutterFonts ?: M3EFlutterFonts(context.assets, assetPath).also {
      flutterFonts = it
    }
    return M3EPlatformView(context.withPickerLocale(args), viewId, args, messenger, fonts)
  }

  companion object {
    const val VIEW_TYPE = "adaptive_liquid_glass/m3e_android"
  }
}

private fun Context.withPickerLocale(creationParams: Any?): Context {
  val properties = asStringMap(creationParams)
  if (properties["component"] != "datePicker" && properties["component"] != "timePicker") return this
  val tag = (properties["localeTag"] as? String)?.takeIf { it.isNotBlank() } ?: return this
  val locale = Locale.forLanguageTag(tag)
  if (locale.language.isBlank()) return this
  return ContextThemeWrapper(this, 0).apply {
    applyOverrideConfiguration(Configuration().apply { setLocale(locale) })
  }
}

private class M3EPlatformView(
  context: Context,
  viewId: Int,
  creationParams: Any?,
  messenger: BinaryMessenger,
  flutterFonts: M3EFlutterFonts,
) : PlatformView {
  private val hostOwner = ComposeViewTreeOwner(
    context.findLifecycleOwner()
    ?: throw IllegalStateException(
      "M3 Expressive platform views require a LifecycleOwner in the host Context.",
    ),
  )
  private val properties = mutableStateOf(asStringMap(creationParams))
  private val cardPressEvents = Channel<M3ECardPressEvent>(Channel.UNLIMITED)
  private val cardHoverEvents = Channel<Boolean>(Channel.UNLIMITED)
  private val cardFocusEvents = Channel<Boolean>(Channel.UNLIMITED)
  private val toolbarScrollEvents = Channel<M3EToolbarScrollEvent>(Channel.UNLIMITED)
  private val channel = MethodChannel(
    messenger,
    "adaptive_liquid_glass/m3e_android_$viewId",
  )
  private var triggerSize: Any? = null
  private val composeView = ComposeView(context).apply {
    setComposeViewTreeOwners(this, hostOwner)
    layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT,
      ViewGroup.LayoutParams.MATCH_PARENT,
    )
    setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
    setContent {
      val currentProperties = properties.value
      M3EAndroidTheme(currentProperties, flutterFonts) {
        M3EAndroidContent(currentProperties, cardPressEvents, cardHoverEvents, cardFocusEvents, toolbarScrollEvents) { event, value ->
          if (event == "triggerSize") triggerSize = value
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
        "getTriggerSize" -> result.success(triggerSize)
        "cardPressStart" -> {
          val arguments = asStringMap(call.arguments)
          val id = (arguments["id"] as? Number)?.toLong()
          val x = (arguments["x"] as? Number)?.toFloat()
          val y = (arguments["y"] as? Number)?.toFloat()
          if (id == null || x == null || y == null || !x.isFinite() || !y.isFinite()) {
            result.error("invalid_card_press", "Expected a finite card press position and id.", null)
          } else {
            cardPressEvents.trySend(M3ECardPressEvent(id, Offset(x, y)))
            result.success(null)
          }
        }
        "cardPressEnd" -> {
          val arguments = asStringMap(call.arguments)
          val id = (arguments["id"] as? Number)?.toLong()
          val cancelled = arguments["cancelled"] as? Boolean
          if (id == null || cancelled == null) {
            result.error("invalid_card_press", "Expected a card press id and cancellation flag.", null)
          } else {
            cardPressEvents.trySend(M3ECardPressEvent(id, cancelled = cancelled))
            result.success(null)
          }
        }
        "cardHoverStart" -> {
          cardHoverEvents.trySend(true)
          result.success(null)
        }
        "cardHoverEnd" -> {
          cardHoverEvents.trySend(false)
          result.success(null)
        }
        "cardFocusStart" -> {
          cardFocusEvents.trySend(true)
          result.success(null)
        }
        "cardFocusEnd" -> {
          cardFocusEvents.trySend(false)
          result.success(null)
        }
        "toolbarScrollBy" -> {
          val delta = (call.arguments as? Number)?.toFloat()
          if (delta == null || !delta.isFinite()) {
            result.error("invalid_toolbar_scroll", "Expected a finite scroll delta.", null)
          } else {
            toolbarScrollEvents.trySend(M3EToolbarScrollEvent(logicalDelta = delta))
            result.success(null)
          }
        }
        "toolbarScrollEnd" -> {
          toolbarScrollEvents.trySend(M3EToolbarScrollEvent(settle = true))
          result.success(null)
        }
        "toolbarScrollReset" -> {
          val token = (call.arguments as? Number)?.toLong()
          if (token == null || token < 0L) {
            result.error("invalid_toolbar_scroll", "Expected a nonnegative reset token.", null)
          } else {
            toolbarScrollEvents.trySend(M3EToolbarScrollEvent(reset = true, resetToken = token))
            result.success(null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  override fun getView(): View = composeView

  override fun dispose() {
    channel.setMethodCallHandler(null)
    cardPressEvents.close()
    cardHoverEvents.close()
    cardFocusEvents.close()
    toolbarScrollEvents.close()
    composeView.disposeComposition()
    hostOwner.dispose()
  }
}

private fun Context.findLifecycleOwner(): LifecycleOwner? {
  var current: Context? = this
  while (current != null) {
    if (current is LifecycleOwner) return current
    current = (current as? ContextWrapper)?.baseContext
  }
  return null
}

private fun setLifecycleOwner(view: View, lifecycleOwner: LifecycleOwner) {
  val ownerClass = Class.forName("androidx.lifecycle.ViewTreeLifecycleOwner")
  ownerClass
    .getMethod("set", View::class.java, LifecycleOwner::class.java)
    .invoke(null, view, lifecycleOwner)
}

private fun setComposeViewTreeOwners(view: View, lifecycleOwner: LifecycleOwner) {
  setLifecycleOwner(view, lifecycleOwner)
  val savedStateOwner = lifecycleOwner as? SavedStateRegistryOwner
    ?: throw IllegalStateException("M3 Expressive views require a SavedStateRegistryOwner.")
  setTreeOwner(
    "androidx.savedstate.ViewTreeSavedStateRegistryOwner",
    "androidx.savedstate.SavedStateRegistryOwner",
    view,
    savedStateOwner,
  )
  val viewModelStoreOwner = lifecycleOwner as? ViewModelStoreOwner
    ?: throw IllegalStateException("M3 Expressive views require a ViewModelStoreOwner.")
  setTreeOwner(
    "androidx.lifecycle.ViewTreeViewModelStoreOwner",
    "androidx.lifecycle.ViewModelStoreOwner",
    view,
    viewModelStoreOwner,
  )
  val backDispatcherOwner = view.context.findOnBackPressedDispatcherOwner()
  if (backDispatcherOwner != null) {
    setTreeOwner(
      "androidx.activity.ViewTreeOnBackPressedDispatcherOwner",
      "androidx.activity.OnBackPressedDispatcherOwner",
      view,
      backDispatcherOwner,
    )
  }
}

private fun Context.findOnBackPressedDispatcherOwner(): OnBackPressedDispatcherOwner? {
  var current: Context? = this
  while (current != null) {
    if (current is OnBackPressedDispatcherOwner) return current
    current = (current as? ContextWrapper)?.baseContext
  }
  return null
}

private class ComposeViewTreeOwner(
  private val parent: LifecycleOwner,
) : LifecycleOwner, SavedStateRegistryOwner, ViewModelStoreOwner {
  private val lifecycleRegistry = LifecycleRegistry(this)
  private val savedStateController = SavedStateRegistryController.create(this)
  override val lifecycle: Lifecycle get() = lifecycleRegistry
  override val savedStateRegistry get() = savedStateController.savedStateRegistry
  override val viewModelStore = ViewModelStore()
  private val lifecycleObserver = LifecycleEventObserver { _, event ->
    lifecycleRegistry.handleLifecycleEvent(event)
  }

  init {
    savedStateController.performAttach()
    savedStateController.performRestore(null)
    parent.lifecycle.addObserver(lifecycleObserver)
  }

  fun dispose() {
    parent.lifecycle.removeObserver(lifecycleObserver)
    lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
    viewModelStore.clear()
  }
}

private fun setTreeOwner(
  treeOwnerClassName: String,
  ownerClassName: String,
  view: View,
  owner: Any,
) {
  val ownerClass = Class.forName(ownerClassName)
  Class.forName(treeOwnerClassName)
    .getMethod("set", View::class.java, ownerClass)
    .invoke(null, view, owner)
}

private fun asStringMap(value: Any?): Map<String, Any?> {
  val map = value as? Map<*, *> ?: return emptyMap()
  return map.entries.associate { (key, entryValue) -> key.toString() to entryValue }
}
