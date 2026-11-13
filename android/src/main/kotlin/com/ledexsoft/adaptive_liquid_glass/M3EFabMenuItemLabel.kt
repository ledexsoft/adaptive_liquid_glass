package com.ledexsoft.adaptive_liquid_glass

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.layout
import androidx.compose.ui.text.TextLayoutResult
import kotlin.math.ceil
import kotlin.math.floor

/** Matches the visible longest line of the real Material 3 FAB menu text slot. */
@Composable
internal fun M3EFabMenuItemLabel(label: String) {
  var textLayout by remember(label) { mutableStateOf<TextLayoutResult?>(null) }
  Text(
    text = label,
    onTextLayout = { textLayout = it },
    modifier = Modifier.layout { measurable, constraints ->
      val placeable = measurable.measure(constraints)
      val result = textLayout
      if (label.isBlank() || result == null || result.lineCount == 0) {
        layout(placeable.width, placeable.height) { placeable.place(0, 0) }
      } else {
        val left = (0 until result.lineCount).minOf(result::getLineLeft)
        val right = (0 until result.lineCount).maxOf(result::getLineRight)
        val width = ceil(right - left).toInt().coerceIn(constraints.minWidth, constraints.maxWidth)
        layout(width, placeable.height) { placeable.place(-floor(left).toInt(), 0) }
      }
    },
  )
}
