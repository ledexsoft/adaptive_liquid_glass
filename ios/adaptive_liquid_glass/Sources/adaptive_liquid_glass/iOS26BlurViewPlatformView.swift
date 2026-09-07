import UIKit
import Flutter

/// Factory for creating iOS 26 native blur view platform views
class iOS26BlurViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return iOS26BlurViewPlatformView(
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

/// Native iOS 26 blur view using Liquid Glass (UIGlassEffect) on iOS 26+,
/// falling back to UIVisualEffectView + UIBlurEffect on iOS < 26.
///
/// Liquid Glass bends light (refraction) and adapts to surrounding content:
/// light from colorful content nearby spills onto the glass surface, which is
/// the signature adaptive behavior of the macOS 26 / iOS 26 material.
class iOS26BlurViewPlatformView: NSObject, FlutterPlatformView {
    private var _blurView: UIVisualEffectView
    private var _channel: FlutterMethodChannel
    private var _viewId: Int64
    private var isDark: Bool = false
    private var _lastBlurStyle: UIBlurEffect.Style = .systemUltraThinMaterial
    // Raw value of UIGlassEffect.Style (0 = regular, 1 = clear).
    // Stored as Int so the class compiles for deployment targets < iOS 26.
    private var _lastGlassStyleRaw: Int = 0
    private var _tintColor: UIColor?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _viewId = viewId

        // Parse blur style and brightness from arguments
        var blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial
        if let params = args as? [String: Any] {
            if let styleString = params["blurStyle"] as? String {
                blurStyle = iOS26BlurViewPlatformView.parseBlurStyle(styleString)
            }
            isDark = params["isDark"] as? Bool ?? false
            if let tintHex = params["tintColor"] as? String, !tintHex.isEmpty {
                _tintColor = iOS26BlurViewPlatformView.color(fromHex: tintHex)
            }
        }
        _lastBlurStyle = blurStyle
        _lastGlassStyleRaw = iOS26BlurViewPlatformView.glassStyleRawValue(blurStyle)

        // iOS 26+: real Liquid Glass material (refraction + adaptive light spill)
        _blurView = UIVisualEffectView(effect: AdaptiveGlassMaterial.effect(
            styleRawValue: _lastGlassStyleRaw,
            tintColor: _tintColor,
            interactive: true,
            fallback: blurStyle
        ))
        _blurView.frame = frame
        _blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Apply Flutter's brightness override
        if #available(iOS 13.0, *) {
            _blurView.overrideUserInterfaceStyle = isDark ? .dark : .light
        }

        // Setup method channel
        _channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/ios26_blur_view_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        // Setup method channel handler
        _channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call, result: result)
        }
    }

    func view() -> UIView {
        return _blurView
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateBlurStyle":
            if let args = call.arguments as? [String: Any],
               let styleString = args["blurStyle"] as? String {
                let blurStyle = iOS26BlurViewPlatformView.parseBlurStyle(styleString)
                _lastBlurStyle = blurStyle
                _lastGlassStyleRaw = iOS26BlurViewPlatformView.glassStyleRawValue(blurStyle)
                applyEffect()
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            }
        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let dark = args["isDark"] as? Bool {
                isDark = dark
                if #available(iOS 13.0, *) {
                    _blurView.overrideUserInterfaceStyle = dark ? .dark : .light
                }
            }
            result(nil)
        case "setTintColor":
            if let args = call.arguments as? [String: Any],
               let tintHex = args["tintColor"] as? String {
                _tintColor = tintHex.isEmpty ? nil : Self.color(fromHex: tintHex)
                applyEffect()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// (Re)apply the current effect: Liquid Glass on iOS 26+, blur otherwise.
    private func applyEffect() {
        _blurView.effect = AdaptiveGlassMaterial.effect(
            styleRawValue: _lastGlassStyleRaw,
            tintColor: _tintColor,
            interactive: true,
            fallback: _lastBlurStyle
        )
    }

    /// Parse blur style string to UIBlurEffect.Style
    private static func parseBlurStyle(_ styleString: String) -> UIBlurEffect.Style {
        switch styleString {
        case "systemUltraThinMaterial":
            if #available(iOS 13.0, *) {
                return .systemUltraThinMaterial
            } else {
                return .light
            }
        case "systemThinMaterial":
            if #available(iOS 13.0, *) {
                return .systemThinMaterial
            } else {
                return .light
            }
        case "systemMaterial":
            if #available(iOS 13.0, *) {
                return .systemMaterial
            } else {
                return .light
            }
        case "systemThickMaterial":
            if #available(iOS 13.0, *) {
                return .systemThickMaterial
            } else {
                return .dark
            }
        case "systemChromeMaterial":
            if #available(iOS 13.0, *) {
                return .systemChromeMaterial
            } else {
                return .dark
            }
        default:
            if #available(iOS 13.0, *) {
                return .systemUltraThinMaterial
            } else {
                return .light
            }
        }
    }

    /// Map a blur style to a Liquid Glass style raw value (iOS 26+).
    /// All standard materials map to .regular (0). Kept as Int to avoid
    /// referencing UIGlassEffect outside #available(iOS 26.0, *) checks.
    private static func glassStyleRawValue(_ style: UIBlurEffect.Style) -> Int {
        return 0 // UIGlassEffect.Style.regular.rawValue
    }

    /// Hex string (#RRGGBB or #RRGGBBAA) to UIColor.
    private static func color(fromHex hex: String) -> UIColor? {
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
