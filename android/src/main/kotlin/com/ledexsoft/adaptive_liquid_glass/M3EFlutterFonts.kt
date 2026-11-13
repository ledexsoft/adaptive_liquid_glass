package com.ledexsoft.adaptive_liquid_glass

import android.os.Build
import android.content.res.AssetManager
import android.util.Log
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.font.DeviceFontFamilyName
import java.util.Locale
import org.json.JSONArray

/** Loads an app's declared Flutter faces through Compose's Android asset-font API. */
internal class M3EFlutterFonts(
  private val assets: AssetManager,
  private val assetPath: (String) -> String,
) {
  private data class Face(val asset: String, val weight: Int, val italic: Boolean)
  private data class Axis(val name: String, val value: Float)
  private data class CacheKey(
    val name: String,
    val axes: List<Axis>,
    val requestedWeight: Int,
    val requestedItalic: Boolean,
    val allowDeviceFamily: Boolean,
  )

  private val faces: Map<String, List<Face>> by lazy(::readManifest)
  private val cache = object : LinkedHashMap<CacheKey, FontFamily?>(64, 0.75f, true) {
    override fun removeEldestEntry(eldest: MutableMap.MutableEntry<CacheKey, FontFamily?>) =
      size > 64
  }

  fun resolve(
    name: String?,
    variations: Any? = null,
    requestedWeight: Int? = null,
    requestedItalic: Boolean = false,
    allowDeviceFamily: Boolean = false,
  ): FontFamily? {
    if (name.isNullOrBlank()) return null
    val axes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      (variations as? List<*>)?.mapNotNull { raw ->
        val axis = raw as? Map<*, *> ?: return@mapNotNull null
        val tag = (axis["axis"] as? String)?.takeIf {
          it.length == 4 && it.all { character -> character.code in 32..126 }
        } ?: return@mapNotNull null
        val value = (axis["value"] as? Number)?.toFloat()?.takeIf {
          it.isFinite() && it >= -32768f && it < 32768f
        } ?: return@mapNotNull null
        Axis(tag, value)
      }?.takeIf { parsed ->
        parsed.size == variations.size &&
          parsed.map(Axis::name).distinct().size == parsed.size
      }.orEmpty()
    } else emptyList()
    val weight = requestedWeight?.takeIf { it in 1..1000 } ?: 400
    val key = CacheKey(name, axes, weight, requestedItalic, allowDeviceFamily)
    if (cache.containsKey(key)) return cache[key]
    val declared = faces[name]
    val loaded = declared?.mapNotNull { face ->
      try {
        val weight = FontWeight(face.weight)
        val style = if (face.italic) FontStyle.Italic else FontStyle.Normal
        val settings = FontVariation.Settings(*buildList {
          if (axes.none { it.name == "wght" }) add(FontVariation.weight(face.weight))
          if (axes.none { it.name == "ital" }) {
            add(FontVariation.italic(if (face.italic) 1f else 0f))
          }
          axes.forEach { add(FontVariation.Setting(it.name, it.value)) }
        }.toTypedArray())
        Font(
          path = assetPath(face.asset),
          assetManager = assets,
          weight = weight,
          style = style,
          variationSettings = settings,
        )
      } catch (error: Exception) {
        Log.w(TAG, "Unable to load Flutter font asset ${face.asset}", error)
        null
      }
    }.orEmpty()
    val genericName = name.lowercase(Locale.ROOT).takeIf {
      it == "sans-serif" || it == "serif" || it == "monospace" || it == "cursive"
    }
    val genericFamily = when (genericName) {
      "sans-serif" -> FontFamily.SansSerif
      "serif" -> FontFamily.Serif
      "monospace" -> FontFamily.Monospace
      "cursive" -> FontFamily.Cursive
      else -> null
    }
    val family = when {
      loaded.isNotEmpty() -> FontFamily(loaded)
      genericFamily != null && (axes.isEmpty() || !allowDeviceFamily) -> genericFamily
      allowDeviceFamily -> try {
          // OptionalLocal resolves installed OEM families and falls through to
          // an unmodified system family when the requested face is unavailable.
          FontFamily(
            Font(
              familyName = DeviceFontFamilyName(genericName ?: name),
              weight = FontWeight(weight),
              style = if (requestedItalic) FontStyle.Italic else FontStyle.Normal,
              variationSettings = FontVariation.Settings(*axes.map {
                FontVariation.Setting(it.name, it.value)
              }.toTypedArray()),
            ),
            Font(
              familyName = DeviceFontFamilyName(genericName ?: "sans-serif"),
              weight = FontWeight(weight),
              style = if (requestedItalic) FontStyle.Italic else FontStyle.Normal,
            ),
          )
        } catch (error: IllegalArgumentException) {
          Log.w(TAG, "Unable to describe Android font family $name", error)
          null
        }
      else -> null
    }
    cache[key] = family
    return family
  }

  private fun readManifest(): Map<String, List<Face>> {
    return try {
      val manifest = assets.open(assetPath("FontManifest.json"))
        .bufferedReader(Charsets.UTF_8).use { JSONArray(it.readText()) }
      buildMap {
        for (index in 0 until manifest.length()) {
          val entry = manifest.optJSONObject(index) ?: continue
          val family = entry.optString("family").takeIf { it.isNotBlank() } ?: continue
          val fonts = entry.optJSONArray("fonts") ?: continue
          val entries = buildList {
            for (fontIndex in 0 until fonts.length()) {
              val font = fonts.optJSONObject(fontIndex) ?: continue
              val path = font.optString("asset")
              if (path.isBlank() || path.startsWith('/') ||
                path.split('/').any { it == ".." }) continue
              val weight = font.optInt("weight", 400).takeIf { it in 1..1000 } ?: 400
              add(Face(path, weight, font.optString("style") == "italic"))
            }
          }
          if (entries.isNotEmpty()) put(family, entries)
        }
      }
    } catch (error: Exception) {
      Log.w(TAG, "Unable to read Flutter font manifest", error)
      emptyMap()
    }
  }

  private companion object {
    const val TAG = "M3EFlutterFonts"
  }
}
