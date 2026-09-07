import UIKit
import Flutter

/// Factory for the iOS 26 native glass category grid.
class iOS26GlassGridFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return iOS26GlassGridPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// Container del grid: reconstruye las tarjetas cuando el view recibe su
/// ancho REAL. Los platform views de Flutter se crean con frame 0 dentro de
/// un ListView; construir en `init` deja el grid vacío (bug 22/08).
private class GlassGridContainerView: UIVisualEffectView {
    var onLayout: ((CGFloat) -> Void)?
    private var lastWidth: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        guard w > 0, w != lastWidth else { return }
        lastWidth = w
        onLayout?(w)
    }
}

/// Native grid of glass category cards (OneBlink → Alimentos, 22/08).
///
/// All cards are nested inside a single UIVisualEffectView configured with
/// `UIGlassContainerEffect`, so adjacent glass elements MERGE and spill
/// color onto each other (the signature Liquid Glass behavior that does NOT
/// work between separate Flutter platform views).
///
/// Card layout mirrors the Flutter `paddedBleed` design: image full-bleed
/// with rounded TOP corners only (bottom square), then name + count below
/// with a gap. The first item may be `fullWidth` (16:9 banner card,
/// "Ofertas variadas").
class iOS26GlassGridPlatformView: NSObject, FlutterPlatformView {
    private var _container: GlassGridContainerView
    private var _channel: FlutterMethodChannel
    private var _items: [[String: Any]] = []
    private var _columns: Int = 2
    private var _spacing: CGFloat = 12
    private var _cornerRadius: CGFloat = 16
    private var _textBlockHeight: CGFloat = 58
    private var _tintHex: String = ""
    // Estilo de tarjeta: "bleed" (Alimentos: imagen a sangre, radio solo
    // arriba) o "padded" (Electrónicos: imagen con margen, radio completo).
    private var _style: String = "bleed"

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger: FlutterBinaryMessenger
    ) {
        _channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/ios26_glass_grid_\(viewId)",
            binaryMessenger: binaryMessenger
        )

        if let params = args as? [String: Any] {
            _items = params["items"] as? [[String: Any]] ?? []
            _columns = params["columns"] as? Int ?? 2
            _spacing = params["spacing"] as? CGFloat ?? 12
            _cornerRadius = params["cornerRadius"] as? CGFloat ?? 16
            _textBlockHeight = params["textBlockHeight"] as? CGFloat ?? 58
            _tintHex = params["tintColor"] as? String ?? ""
            _style = params["style"] as? String ?? "bleed"
        }

        // Container effect: merges all nested glass cards (fusion + spill).
        _container = GlassGridContainerView(
            effect: AdaptiveGlassMaterial.containerEffect(
                spacing: 12,
                fallback: .systemThinMaterial
            )
        )
        super.init()

        _container.frame = frame
        _container.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        _channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call, result: result)
        }

        // El frame del init puede ser 0 (ListView): construir recién cuando
        // el contenedor tenga su ancho real (primer layout).
        _container.onLayout = { [weak self] width in
            self?.rebuildGrid(width: width)
        }
        if frame.width > 0 {
            rebuildGrid(width: frame.width)
        }
    }

    func view() -> UIView {
        return _container
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setTintColor":
            if let args = call.arguments as? [String: Any],
               let tintHex = args["tintColor"] as? String {
                _tintHex = tintHex
                rebuildGrid(width: _container.bounds.width)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Borra las tarjetas previas y reconstruye con el ancho dado.
    private func rebuildGrid(width: CGFloat) {
        _container.contentView.subviews.forEach { $0.removeFromSuperview() }
        buildGrid(width: width)
    }


    /// Layout + create all glass cards inside the container's contentView.
    /// Geometry must match the Dart-side `GlassCategoryGrid.computeHeight`.
    private func buildGrid(width: CGFloat) {
        guard width > 0 else { return }
        let columns = max(1, _columns)
        let tileWidth = (width - _spacing * CGFloat(columns - 1)) / CGFloat(columns)

        // Estilo padded (Electrónicos): imagen con margen (inset) y radio
        // completo; bleed (Alimentos): imagen a sangre, radio solo arriba.
        let isPadded = _style == "padded"
        let inset: CGFloat = isPadded ? 10 : 0

        var x: CGFloat = 0
        var y: CGFloat = 0
        var col = 0
        var rowHeight: CGFloat = 0

        for (index, item) in _items.enumerated() {
            let isFullWidth = item["fullWidth"] as? Bool ?? false

            if isFullWidth {
                // Close the current row first.
                if rowHeight > 0 {
                    y += rowHeight + _spacing
                    rowHeight = 0
                    col = 0
                }
                let cardWidth = width
                let imageHeight = cardWidth * 9.0 / 16.0
                let cardHeight = imageHeight + _textBlockHeight
                let cardFrame = CGRect(x: 0, y: y, width: cardWidth, height: cardHeight)
                addCard(item: item, frame: cardFrame, imageHeight: imageHeight, inset: inset, isPadded: isPadded, index: index)
                y += cardHeight + _spacing
            } else {
                let cardWidth = tileWidth
                // La tarjeta conserva su tamaño CUADRADO (pedido 22/08:
                // "las tarjetas tienen que tener el tamaño que estaba
                // antes"). La imagen DENTRO se ajusta a la altura del
                // contenedor (fitHeight) — ver addCard.
                let imageWidth = cardWidth - inset * 2
                let imageHeight = imageWidth // cuadrado, como antes
                let cardHeight = inset + imageHeight + _textBlockHeight
                let cardFrame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
                addCard(item: item, frame: cardFrame, imageHeight: imageHeight, inset: inset, isPadded: isPadded, index: index)

                rowHeight = max(rowHeight, cardHeight)
                col += 1
                if col >= columns {
                    y += rowHeight + _spacing
                    rowHeight = 0
                    col = 0
                    x = 0
                } else {
                    x += cardWidth + _spacing
                }
            }
        }
    }

    /// One glass card: UIVisualEffectView with UIGlassEffect nested in the
    /// container's contentView.
    /// - bleed: image full-bleed with rounded top corners only.
    /// - padded: image inset with full rounded corners.
    private func addCard(item: [String: Any], frame: CGRect, imageHeight: CGFloat, inset: CGFloat, isPadded: Bool, index: Int) {
        let name = item["name"] as? String ?? ""
        let countLabel = item["countLabel"] as? String ?? ""
        let imageBytes = (item["imageBytes"] as? FlutterStandardTypedData)?.data

        let glass = AdaptiveGlassMaterial.effect(
            styleRawValue: 0, // .regular
            tintColor: Self.color(fromHex: _tintHex),
            interactive: true,
            fallback: .systemThinMaterial
        )
        let card = UIVisualEffectView(effect: glass)
        card.frame = frame
        card.layer.cornerRadius = _cornerRadius
        card.clipsToBounds = true
        card.tag = index

        let content = card.contentView

        // Image. padded (Electrónicos 22/08): FIT HEIGHT — la imagen llena
        // la ALTURA del contenedor y el ancho se escala con su proporción
        // real (BoxFit.fitHeight). El exceso de ancho lo recorta la tarjeta
        // (clipsToBounds); el defecto queda transparente (cutout con alfa).
        // 23/08: con aspect > 1 (fotos landscape, ej. 1.29) el frame
        // sobresalía de la tarjeta → recorte lateral. Ahora el ancho se
        // LIMITA al interior del tile: la imagen llena el área (cover,
        // recorte mínimo centrado) y nunca invade las tarjetas vecinas.
        let imageView: UIImageView
        if isPadded, let aspect = (item["imageAspectRatio"] as? Double), aspect > 0 {
            let maxWidth = frame.width - inset * 2
            let imageWidth = min(imageHeight * CGFloat(aspect), maxWidth)
            let x = (frame.width - imageWidth) / 2
            imageView = UIImageView(
                frame: CGRect(x: x, y: inset, width: imageWidth, height: imageHeight)
            )
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView = UIImageView(
                frame: CGRect(x: inset, y: inset, width: frame.width - inset * 2, height: imageHeight)
            )
            imageView.contentMode = .scaleAspectFill
        }
        imageView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            if isPadded {
                // Radio completo (4 esquinas), como el ClipRRect de Flutter.
                imageView.layer.cornerRadius = 12
                imageView.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
                ]
            } else {
                // Bleed: radio solo arriba (sigue el radio del contenedor).
                imageView.layer.cornerRadius = _cornerRadius
                imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        } else {
            imageView.layer.cornerRadius = 0
        }
        if let data = imageBytes, !data.isEmpty, let uiImage = UIImage(data: data) {
            imageView.image = uiImage
        } else {
            imageView.backgroundColor = UIColor.secondarySystemFill
        }
        content.addSubview(imageView)

        // Text block: name + count below the image with a top gap.
        let textX: CGFloat = 12
        let textWidth = frame.width - textX * 2
        let textTop = inset + imageHeight + (isPadded ? 8 : 12)
        let nameLabel = UILabel(frame: CGRect(x: textX, y: textTop, width: textWidth, height: 17))
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor.label
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        content.addSubview(nameLabel)

        let countLabelView = UILabel(
            frame: CGRect(x: textX, y: textTop + 17 + 2, width: textWidth, height: 14)
        )
        countLabelView.text = countLabel
        countLabelView.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        countLabelView.textColor = UIColor.secondaryLabel
        countLabelView.numberOfLines = 1
        countLabelView.lineBreakMode = .byTruncatingTail
        content.addSubview(countLabelView)

        // Tap → Flutter callback.
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tap)

        _container.contentView.addSubview(card)
    }

    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let card = sender.view else { return }
        let index = card.tag
        _channel.invokeMethod("onTap", arguments: ["index": index])
    }

    /// Hex string (#RRGGBB or #RRGGBBAA) to UIColor. Returns nil for
    /// empty/invalid input (glass uses its natural adaptive tint then).
    private static func color(fromHex hex: String) -> UIColor? {
        guard !hex.isEmpty else { return nil }
        var value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if value.count == 6 { value += "FF" }
        guard value.count == 8, let intVal = UInt64(value, radix: 16) else { return nil }
        let r = CGFloat((intVal >> 24) & 0xFF) / 255.0
        let g = CGFloat((intVal >> 16) & 0xFF) / 255.0
        let b = CGFloat((intVal >> 8) & 0xFF) / 255.0
        let a = CGFloat(intVal & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
