package com.ledexsoft.adaptive_liquid_glass

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Shapes
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TriStateCheckbox
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.state.ToggleableState

internal typealias M3EAndroidEvent = (String, Any?) -> Unit

@Composable
internal fun M3EAndroidTheme(
  properties: Map<String, Any?>,
  content: @Composable () -> Unit,
) {
  val dark = properties.boolean("isDark")
  val primary = properties.color("primaryColor") ?: Color(0xFF6750A4)
  val foreground = if (primary.luminance() > 0.5f) Color.Black else Color.White
  val colors = if (dark) {
    darkColorScheme(primary = primary, onPrimary = foreground)
  } else {
    lightColorScheme(primary = primary, onPrimary = foreground)
  }
  val shapes = Shapes(
    extraSmall = RoundedCornerShape(12.dp),
    small = RoundedCornerShape(16.dp),
    medium = RoundedCornerShape(24.dp),
    large = RoundedCornerShape(32.dp),
    extraLarge = RoundedCornerShape(40.dp),
  )

  // Material 3 1.4 supplies stable motion APIs and remains compatible with
  // the package's Flutter/AGP baseline. Use expressive shape and color tokens
  // here until MaterialExpressiveTheme is available outside the 1.5 prerelease.
  val resolvedColors = colors

  MaterialTheme(
    colorScheme = resolvedColors,
    shapes = shapes,
    content = content,
  )
}

@Composable
internal fun M3EAndroidContent(
  properties: Map<String, Any?>,
  onEvent: M3EAndroidEvent,
) {
  val enabled = properties.boolean("enabled", true)
  val hasCallback = properties.boolean("hasCallback", true)

  Box(
    modifier = Modifier.fillMaxSize(),
    contentAlignment = Alignment.Center,
  ) {
    when (properties["component"] as? String) {
      "button" -> NativeM3EButton(properties, enabled && hasCallback, onEvent)
      "switch" -> NativeM3ESwitch(properties, enabled && hasCallback, onEvent)
      "checkbox" -> NativeM3ECheckbox(properties, enabled && hasCallback, onEvent)
      "radio" -> NativeM3ERadio(properties, enabled && hasCallback, onEvent)
      "slider" -> NativeM3ESlider(properties, enabled && hasCallback, onEvent)
    }
  }
}

@Composable
private fun NativeM3EButton(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val style = properties["style"] as? String ?: "filled"
  val label = properties["label"] as? String ?: ""
  val radius = properties.number("borderRadius")?.dp
  val shape = radius?.let { RoundedCornerShape(it) } ?: MaterialTheme.shapes.medium
  val foreground = properties.color("foregroundColor")
  val background = properties.color("backgroundColor")
  val minHeight = (properties.number("minHeight") ?: 40.0).dp
  val modifier = Modifier.heightIn(min = minHeight)
  val contentPadding = properties.number("horizontalPadding")?.let {
    PaddingValues(horizontal = it.dp)
  } ?: ButtonDefaults.ContentPadding
  val click = { if (enabled) onEvent("pressed", null) }

  when (style) {
    "plain" -> TextButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.textButtonColors(
        contentColor = foreground ?: MaterialTheme.colorScheme.primary,
      ),
      contentPadding = contentPadding,
    ) { Text(label, fontSize = (properties.number("fontSize") ?: 14.0).sp) }

    "bordered" -> OutlinedButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      border = BorderStroke(1.dp, background ?: MaterialTheme.colorScheme.outline),
      colors = ButtonDefaults.outlinedButtonColors(
        contentColor = foreground ?: MaterialTheme.colorScheme.primary,
      ),
      contentPadding = contentPadding,
    ) { Text(label, fontSize = (properties.number("fontSize") ?: 14.0).sp) }

    "tinted", "gray", "glass" -> FilledTonalButton(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.filledTonalButtonColors(
        containerColor = background ?: MaterialTheme.colorScheme.secondaryContainer,
        contentColor = foreground ?: MaterialTheme.colorScheme.onSecondaryContainer,
      ),
      contentPadding = contentPadding,
    ) { Text(label, fontSize = (properties.number("fontSize") ?: 14.0).sp) }

    else -> Button(
      onClick = click,
      enabled = enabled,
      modifier = modifier,
      shape = shape,
      colors = ButtonDefaults.buttonColors(
        containerColor = background ?: MaterialTheme.colorScheme.primary,
        contentColor = foreground ?: MaterialTheme.colorScheme.onPrimary,
      ),
      contentPadding = contentPadding,
    ) { Text(label, fontSize = (properties.number("fontSize") ?: 14.0).sp) }
  }
}

@Composable
private fun NativeM3ESwitch(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  Switch(
    checked = properties.boolean("value"),
    onCheckedChange = { onEvent("changed", it) },
    enabled = enabled,
    modifier = Modifier.size(width = 64.dp, height = 48.dp),
    colors = SwitchDefaults.colors(
      checkedTrackColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
      checkedThumbColor = properties.color("thumbColor") ?: MaterialTheme.colorScheme.onPrimary,
    ),
  )
}

@Composable
private fun NativeM3ECheckbox(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val value = properties["value"] as? Boolean
  val colors = CheckboxDefaults.colors(
    checkedColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
    checkmarkColor = properties.color("checkColor") ?: MaterialTheme.colorScheme.onPrimary,
  )
  if (properties.boolean("tristate") || value == null) {
    val state = when (value) {
      true -> ToggleableState.On
      null -> ToggleableState.Indeterminate
      false -> ToggleableState.Off
    }
    TriStateCheckbox(
      state = state,
      onClick = {
        onEvent("changed", when (state) {
          ToggleableState.Off -> true
          ToggleableState.On -> null
          ToggleableState.Indeterminate -> false
        })
      },
      enabled = enabled,
      modifier = Modifier.size(48.dp),
      colors = colors,
    )
  } else {
    Checkbox(
      checked = value,
      onCheckedChange = { onEvent("changed", it) },
      enabled = enabled,
      modifier = Modifier.size(48.dp),
      colors = colors,
    )
  }
}

@Composable
private fun NativeM3ERadio(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val selected = properties.boolean("selected")
  val toggleable = properties.boolean("toggleable")
  RadioButton(
    selected = selected,
    onClick = {
      onEvent("changed", if (selected && toggleable) false else true)
    },
    enabled = enabled,
    modifier = Modifier.size(48.dp),
    colors = RadioButtonDefaults.colors(
      selectedColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
    ),
  )
}

@Composable
private fun NativeM3ESlider(
  properties: Map<String, Any?>,
  enabled: Boolean,
  onEvent: M3EAndroidEvent,
) {
  val min = properties.number("min") ?: 0.0
  val max = properties.number("max") ?: 1.0
  val divisions = properties.number("divisions")?.toInt()?.let { (it - 1).coerceAtLeast(0) } ?: 0
  val value = (properties.number("value") ?: min).coerceIn(min, max)
  var latestValue by remember(value) { mutableFloatStateOf(value.toFloat()) }
  Slider(
    value = value.toFloat(),
    onValueChange = {
      latestValue = it
      onEvent("changed", it.toDouble())
    },
    enabled = enabled,
    modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp),
    valueRange = min.toFloat()..max.toFloat(),
    steps = divisions,
    onValueChangeFinished = { onEvent("finished", latestValue.toDouble()) },
    colors = SliderDefaults.colors(
      thumbColor = properties.color("thumbColor") ?: MaterialTheme.colorScheme.primary,
      activeTrackColor = properties.color("activeColor") ?: MaterialTheme.colorScheme.primary,
    ),
  )
}

private fun Map<String, Any?>.boolean(key: String, default: Boolean = false): Boolean =
  this[key] as? Boolean ?: default

private fun Map<String, Any?>.number(key: String): Double? =
  (this[key] as? Number)?.toDouble()

private fun Map<String, Any?>.color(key: String): Color? {
  val argb = (this[key] as? Number)?.toLong()?.toInt() ?: return null
  return Color(argb)
}
