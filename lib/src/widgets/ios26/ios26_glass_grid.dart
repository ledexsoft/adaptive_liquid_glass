import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/platform_info.dart';

/// Estilo de tarjeta del grid nativo (22/08).
/// - [bleed]: imagen a sangre, radio solo arriba (Alimentos).
/// - [padded]: imagen con margen (inset 10) y radio completo (Electrónicos).
enum GlassGridCardStyle { bleed, padded }

/// A category item rendered inside the native glass grid.
class GlassCategoryItem {
  const GlassCategoryItem({
    required this.name,
    required this.countLabel,
    required this.imageBytes,
    this.fullWidth = false,
    this.imageAspectRatio = 1.0,
  });

  final String name;
  final String countLabel;
  final Uint8List? imageBytes;
  final bool fullWidth;

  /// Proporción ancho/alto real de la foto (Electrónicos 22/08): con
  /// 1.0 la imagen es cuadrada (cover recorta); con la proporción real el
  /// contenedor se ajusta a la altura de la imagen (sin recorte lateral).
  final double imageAspectRatio;
}

/// Native iOS 26 glass grid of category cards (OneBlink → Alimentos y
/// Electrónicos, 22/08).
///
/// Renders ALL cards inside a single native UIVisualEffectView configured
/// with `UIGlassContainerEffect`: adjacent glass cards merge and spill color
/// onto each other (Liquid Glass signature). This is impossible with
/// separate Flutter platform views, hence the whole grid is one UiKitView.
///
/// iOS 26+ only. On any other platform this widget builds nothing — the
/// caller must keep its Flutter fallback (the regular padded/paddedBleed
/// grid).
///
/// Card geometry mirrors the Flutter variants: `bleed` = paddedBleed
/// (image full-bleed, rounded TOP corners only, name + count below with a
/// gap); `padded` = padded (image inset 10 with full rounded corners).
/// The first item may be `fullWidth` (16:9, occupies the whole row).
class GlassCategoryGrid extends StatefulWidget {
  const GlassCategoryGrid({
    super.key,
    required this.items,
    required this.maxWidth,
    this.columns = 2,
    this.spacing = 12,
    this.cornerRadius = 16,
    this.textBlockHeight = 58,
    this.style = GlassGridCardStyle.bleed,
    this.tintColor,
    required this.onTap,
  });

  final List<GlassCategoryItem> items;
  final double maxWidth;
  final int columns;
  final double spacing;
  final double cornerRadius;
  final double textBlockHeight;
  final GlassGridCardStyle style;
  final Color? tintColor;
  final ValueChanged<int> onTap;

  /// Total height of the grid, must match the native layout exactly.
  /// Mirrors iOS26GlassGridPlatformView.buildGrid.
  double computeHeight() {
    final columns = this.columns < 1 ? 1 : this.columns;
    final tileWidth = (maxWidth - spacing * (columns - 1)) / columns;
    // padded: imagen con margen (inset 10) — el alto de la imagen es
    // tileWidth - 2*inset y el contenedor suma inset arriba.
    final inset = style == GlassGridCardStyle.padded ? 10.0 : 0.0;

    double y = 0;
    int col = 0;
    double rowHeight = 0;

    for (final item in items) {
      if (item.fullWidth) {
        if (rowHeight > 0) {
          y += rowHeight + spacing;
          rowHeight = 0;
          col = 0;
        }
        final cardHeight = maxWidth * 9 / 16 + textBlockHeight;
        y += cardHeight + spacing;
      } else {
        // Tarjeta CUADRADA como antes (22/08): la imagen dentro se ajusta
        // por altura (fitHeight), pero el contenedor conserva su tamaño.
        final cardHeight = inset + (tileWidth - inset * 2) + textBlockHeight;
        rowHeight = rowHeight > cardHeight ? rowHeight : cardHeight;
        col += 1;
        if (col >= columns) {
          y += rowHeight + spacing;
          rowHeight = 0;
          col = 0;
        }
      }
    }
    if (rowHeight > 0) {
      y += rowHeight;
    } else if (y > 0) {
      y -= spacing; // trailing spacing after the last full row
    }
    return y;
  }

  @override
  State<GlassCategoryGrid> createState() => _GlassCategoryGridState();
}

class _GlassCategoryGridState extends State<GlassCategoryGrid> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (!PlatformInfo.isIOS || !PlatformInfo.isIOSVersionInRange(26, 99)) {
      // Not iOS 26+: native grid unavailable, caller must fall back.
      return const SizedBox.shrink();
    }

    final items = [
      for (final item in widget.items)
        {
          'name': item.name,
          'countLabel': item.countLabel,
          'fullWidth': item.fullWidth,
          'imageAspectRatio': item.imageAspectRatio,
          // Uint8List (NO ByteData): StandardMessageCodec no serializa
          // ByteData — Invalid argument: _UnmodifiableByteDataView (22/08).
          'imageBytes': item.imageBytes,
        },
    ];

    return SizedBox(
      width: widget.maxWidth,
      height: widget.computeHeight(),
      child: UiKitView(
        viewType: 'adaptive_liquid_glass/ios26_glass_grid',
        creationParams: {
          'items': items,
          'columns': widget.columns,
          'spacing': widget.spacing,
          'cornerRadius': widget.cornerRadius,
          'textBlockHeight': widget.textBlockHeight,
          'tintColor': widget.tintColor == null
              ? ''
              : _colorToRgbaHex(widget.tintColor!),
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _channel = MethodChannel(
            'adaptive_liquid_glass/ios26_glass_grid_$id',
          );
          _channel?.setMethodCallHandler((call) async {
            if (call.method == 'onTap') {
              final index = (call.arguments as Map)['index'] as int? ?? 0;
              widget.onTap(index);
            }
          });
        },
      ),
    );
  }
}

String _colorToRgbaHex(Color color) {
  String byte(int value) => value.toRadixString(16).padLeft(2, '0');
  final r = (color.r * 255).round().clamp(0, 255);
  final g = (color.g * 255).round().clamp(0, 255);
  final b = (color.b * 255).round().clamp(0, 255);
  final a = (color.a * 255).round().clamp(0, 255);
  return '#${byte(r)}${byte(g)}${byte(b)}${byte(a)}';
}
