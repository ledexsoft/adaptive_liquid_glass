package com.ledexsoft.adaptive_liquid_glass

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialShapes
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Matrix
import androidx.compose.ui.graphics.asComposePath
import androidx.graphics.shapes.Morph
import androidx.graphics.shapes.RoundedPolygon
import androidx.graphics.shapes.toPath

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
internal fun NativeM3EExpressiveShape(properties: Map<String, Any?>) {
  val start = materialShape(properties["shape"] as? String)
  val end = (properties["morphTo"] as? String)?.let(::materialShape)
  val progress = ((properties["morphProgress"] as? Number)?.toFloat() ?: 0f)
    .coerceIn(0f, 1f)
  val color = (properties["color"] as? Number)?.toInt()?.let(::Color)
    ?: Color(0xFF6750A4)

  Canvas(Modifier.fillMaxSize()) {
    val path = if (end == null) {
      start.toPath().asComposePath()
    } else {
      Morph(start, end).toPath(progress).asComposePath()
    }
    val matrix = Matrix()
    matrix.scale(size.width / 2f, size.height / 2f)
    matrix.translate(1f, 1f)
    path.transform(matrix)
    drawPath(path, color)
  }
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
private fun materialShape(name: String?): RoundedPolygon = when (name) {
  "arch" -> MaterialShapes.Arch
  "arrow" -> MaterialShapes.Arrow
  "boom" -> MaterialShapes.Boom
  "bun" -> MaterialShapes.Bun
  "burst" -> MaterialShapes.Burst
  "circle" -> MaterialShapes.Circle
  "clamShell" -> MaterialShapes.ClamShell
  "clover4Leaf" -> MaterialShapes.Clover4Leaf
  "clover8Leaf" -> MaterialShapes.Clover8Leaf
  "cookie12Sided" -> MaterialShapes.Cookie12Sided
  "cookie4Sided" -> MaterialShapes.Cookie4Sided
  "cookie6Sided" -> MaterialShapes.Cookie6Sided
  "cookie7Sided" -> MaterialShapes.Cookie7Sided
  "cookie9Sided" -> MaterialShapes.Cookie9Sided
  "diamond" -> MaterialShapes.Diamond
  "fan" -> MaterialShapes.Fan
  "flower" -> MaterialShapes.Flower
  "gem" -> MaterialShapes.Gem
  "ghostish" -> MaterialShapes.Ghostish
  "heart" -> MaterialShapes.Heart
  "oval" -> MaterialShapes.Oval
  "pentagon" -> MaterialShapes.Pentagon
  "pill" -> MaterialShapes.Pill
  "pixelCircle" -> MaterialShapes.PixelCircle
  "pixelTriangle" -> MaterialShapes.PixelTriangle
  "puffy" -> MaterialShapes.Puffy
  "puffyDiamond" -> MaterialShapes.PuffyDiamond
  "semiCircle" -> MaterialShapes.SemiCircle
  "slanted" -> MaterialShapes.Slanted
  "softBoom" -> MaterialShapes.SoftBoom
  "softBurst" -> MaterialShapes.SoftBurst
  "square" -> MaterialShapes.Square
  "sunny" -> MaterialShapes.Sunny
  "triangle" -> MaterialShapes.Triangle
  "verySunny" -> MaterialShapes.VerySunny
  else -> MaterialShapes.Circle
}
