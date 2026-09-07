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

        if let params = args as? [String: Any] {
            if let title = params["title"] as? String { button.title = title }
            if let iconName = params["icon"] as? String {
                if #available(macOS 11.0, *) {
                    if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                        button.image = image
                        button.imagePosition = .imageOnly
                    }
                }
            }
            if let style = params["style"] as? String {
                switch style {
                case "bordered": button.bezelStyle = .rounded
                case "plain": button.bezelStyle = .inline
                default: button.bezelStyle = .texturedRounded
                }
            }
            button.isEnabled = params["enabled"] as? Bool ?? true
        }

        addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            button.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 4),
            button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func buttonPressed() {
        channel.invokeMethod("onPressed", arguments: nil)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setEnabled", let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? Bool {
            button.isEnabled = enabled
        }
        result(nil)
    }
}
