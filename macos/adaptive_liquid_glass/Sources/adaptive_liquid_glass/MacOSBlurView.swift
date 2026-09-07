import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSBlurViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSBlurView(
            frame: NSRect.zero,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class MacOSBlurView: NSView {
    private let channel: FlutterMethodChannel

    // Backing views for different OS versions
    private var glassView26: AnyObject? // NSGlassEffectView (macOS 26+)
    private var visualEffectView: NSVisualEffectView? // Fallback for older macOS
    private var tintOverlayView: NSView?

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_blur_\(viewId)",
            binaryMessenger: messenger
        )
        super.init(frame: frame)

        wantsLayer = true

        if #available(macOS 26.0, *) {
            // Use NSGlassEffectView dynamically to avoid compile-time availability on the class
            let view = NSClassFromString("NSGlassEffectView") as? NSView.Type
            let glass = view?.init(frame: .zero)
            glass?.translatesAutoresizingMaskIntoConstraints = false
            addSubview(glass!)
            NSLayoutConstraint.activate([
                glass!.leadingAnchor.constraint(equalTo: leadingAnchor),
                glass!.trailingAnchor.constraint(equalTo: trailingAnchor),
                glass!.topAnchor.constraint(equalTo: topAnchor),
                glass!.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            self.glassView26 = glass

            // Apply defaults and args
            if let params = args as? [String: Any] {
                if let cr = params["cornerRadius"] as? CGFloat {
                    glass?.setValue(cr, forKey: "cornerRadius")
                }
                if let tintValue = params["tintColor"] as? Int64 {
                    let color = colorFromARGB(tintValue)
                    glass?.setValue(color, forKey: "tintColor")
                }
                if let styleStr = params["style"] as? String {
                    let styleValue = (styleStr == "clear") ? 0 : 1 // 0->clear, 1->regular
                    glass?.setValue(styleValue, forKey: "style")
                }
                if let dark = params["isDark"] as? Bool {
                    appearance = dark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
                }
            }
        } else {
            let effect = NSVisualEffectView(frame: .zero)
            effect.translatesAutoresizingMaskIntoConstraints = false
            effect.blendingMode = .behindWindow
            effect.state = .active
            effect.material = .sidebar
            effect.wantsLayer = true
            effect.layer?.cornerRadius = 0
            effect.layer?.masksToBounds = true
            addSubview(effect)
            NSLayoutConstraint.activate([
                effect.leadingAnchor.constraint(equalTo: leadingAnchor),
                effect.trailingAnchor.constraint(equalTo: trailingAnchor),
                effect.topAnchor.constraint(equalTo: topAnchor),
                effect.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            self.visualEffectView = effect

            if let params = args as? [String: Any] {
                if let cr = params["cornerRadius"] as? CGFloat {
                    effect.layer?.cornerRadius = cr
                }
                if let tintValue = params["tintColor"] as? Int64 {
                    let color = colorFromARGB(tintValue)
                    ensureTintOverlay(on: effect, color: color)
                }
                if let styleStr = params["style"] as? String {
                    applyStyle(styleStr, to: effect)
                }
                if let dark = params["isDark"] as? Bool {
                    appearance = dark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
                }
            }
        }

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setCornerRadius":
            if let args = call.arguments as? [String: Any], let cr = args["cornerRadius"] as? CGFloat {
                if #available(macOS 26.0, *), let glass = glassView26 as? NSView {
                    glass.setValue(cr, forKey: "cornerRadius")
                } else {
                    visualEffectView?.layer?.cornerRadius = cr
                }
            }
            result(nil)
        case "setTintColor":
            if let args = call.arguments as? [String: Any], let tintValue = args["tintColor"] as? Int64 {
                let color = colorFromARGB(tintValue)
                if #available(macOS 26.0, *), let glass = glassView26 as? NSView {
                    glass.setValue(color, forKey: "tintColor")
                } else if let effect = visualEffectView {
                    ensureTintOverlay(on: effect, color: color)
                }
            }
            result(nil)
        case "setStyle":
            if let args = call.arguments as? [String: Any], let styleStr = args["style"] as? String {
                if #available(macOS 26.0, *), let glass = glassView26 as? NSView {
                    let styleValue = (styleStr == "clear") ? 0 : 1
                    glass.setValue(styleValue, forKey: "style")
                } else if let effect = visualEffectView {
                    applyStyle(styleStr, to: effect)
                }
            }
            result(nil)
        case "setBrightness":
            if let args = call.arguments as? [String: Any], let dark = args["isDark"] as? Bool {
                appearance = dark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers for NSVisualEffectView fallback

    private func applyStyle(_ styleStr: String, to effectView: NSVisualEffectView) {
        if styleStr == "clear" {
            effectView.material = .underWindowBackground
            effectView.state = .active
            removeTintOverlay(from: effectView)
        } else {
            effectView.material = .sidebar
            effectView.state = .active
        }
    }

    private func ensureTintOverlay(on effectView: NSVisualEffectView, color: NSColor) {
        if let overlay = tintOverlayView {
            overlay.layer?.backgroundColor = color.withAlphaComponent(0.25).cgColor
            return
        }
        let overlay = NSView(frame: .zero)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.wantsLayer = true
        overlay.layer?.backgroundColor = color.withAlphaComponent(0.25).cgColor
        effectView.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: effectView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: effectView.bottomAnchor)
        ])
        self.tintOverlayView = overlay
    }

    private func removeTintOverlay(from effectView: NSVisualEffectView) {
        tintOverlayView?.removeFromSuperview()
        tintOverlayView = nil
    }
}
