import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSButtonViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSButtonView(
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

// MARK: - macOS Native Button

class MacOSButtonView: NSView {
    private let button: NSButton
    private let channel: FlutterMethodChannel

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        button = NSButton(frame: .zero)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_button_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)

        wantsLayer = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.target = self
        button.action = #selector(buttonPressed)
        button.bezelStyle = .texturedRounded
        button.font = NSFont.systemFont(ofSize: 13)

        let params = args as? [String: Any] ?? [:]
        applyProperties(params)

        addSubview(button)

        if params["circular"] as? Bool == true {
            // The public wrapper supplies a square 36 pt platform view. Pin the
            // NSButton itself, leaving appearance/hit testing to AppKit.
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: leadingAnchor),
                button.trailingAnchor.constraint(equalTo: trailingAnchor),
                button.topAnchor.constraint(equalTo: topAnchor),
                button.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor),
                button.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
                button.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
                button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 4),
                button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4)
            ])
        }

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    deinit {
        channel.setMethodCallHandler(nil)
    }

    private func applyProperties(_ params: [String: Any]) {
        if let title = params["title"] as? String { button.title = title }
        if let icon = params["icon"] as? String, #available(macOS 11.0, *) {
            button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
            button.imagePosition = .imageOnly
        }
        if let style = params["style"] as? String {
            switch style {
            case "glass":
                if #available(macOS 26.0, *) {
                    button.bezelStyle = .glass
                    button.borderShape = .circle
                } else {
                    button.bezelStyle = .circular
                }
            case "bordered": button.bezelStyle = .rounded
            case "plain": button.bezelStyle = .inline
            default: button.bezelStyle = .texturedRounded
            }
        }
        if let label = params["accessibilityLabel"] as? String {
            button.setAccessibilityLabel(label)
        }
        if let tooltip = params["tooltip"] as? String { button.toolTip = tooltip }
        if let enabled = params["enabled"] as? Bool { button.isEnabled = enabled }
        if let isDark = params["isDark"] as? Bool {
            appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }
    }

    @objc private func buttonPressed() {
        guard button.isEnabled else { return }
        channel.invokeMethod("onPressed", arguments: nil)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setEnabled", "updateProperties":
            if let args = call.arguments as? [String: Any] { applyProperties(args) }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
