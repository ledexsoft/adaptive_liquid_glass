package com.ledexsoft.adaptive_liquid_glass

import android.graphics.BitmapFactory
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext

private val imageDecodeSlots = Semaphore(2)

internal data class M3EImageBitmapResult(val image: ImageBitmap?, val complete: Boolean)

private fun decodeM3ESampledImage(bytes: ByteArray, targetWidthPx: Int, targetHeightPx: Int): ImageBitmap? {
  val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
  BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
  if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

  val width = targetWidthPx.coerceAtLeast(1)
  val height = targetHeightPx.coerceAtLeast(1)
  val halfWidth = bounds.outWidth / 2
  val halfHeight = bounds.outHeight / 2
  var sampleSize = 1
  while (halfWidth / sampleSize >= width && halfHeight / sampleSize >= height) {
    sampleSize *= 2
  }
  val options = BitmapFactory.Options().apply { inSampleSize = sampleSize }
  return BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)?.asImageBitmap()
}

@Composable
internal fun rememberM3EImageBitmapResult(
  bytes: ByteArray?,
  targetWidthPx: Int,
  targetHeightPx: Int,
): M3EImageBitmapResult {
  val image = remember(bytes, targetWidthPx, targetHeightPx) {
    mutableStateOf(M3EImageBitmapResult(null, bytes == null))
  }
  LaunchedEffect(bytes, targetWidthPx, targetHeightPx) {
    if (bytes != null) {
      val bitmap = withContext(Dispatchers.IO) {
        imageDecodeSlots.withPermit {
          decodeM3ESampledImage(bytes, targetWidthPx, targetHeightPx)
        }
      }
      image.value = M3EImageBitmapResult(bitmap, true)
    }
  }
  return image.value
}

@Composable
internal fun rememberM3EImageBitmap(bytes: ByteArray?, targetWidthPx: Int, targetHeightPx: Int): ImageBitmap? =
  rememberM3EImageBitmapResult(bytes, targetWidthPx, targetHeightPx).image
