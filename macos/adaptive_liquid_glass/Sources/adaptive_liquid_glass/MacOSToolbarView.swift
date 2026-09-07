import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSToolbarFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        guard #available(macOS 26.0, *) else { return NSView() }
        return MacOSToolbarView(
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

// MARK: - macOS Native Toolbar with Liquid Glass (NSGlassEffectView API macOS 26.0+)

@available(macOS 26.0, *)
class MacOSToolbarView: NSView {
    private let glassView: NSGlassEffectView
    private let contentContainer: NSView
    private let titleLabel: NSTextField
    private var trailingButtons: [NSButton] = []
    private let channel: FlutterMethodChannel
    private var isDark: Bool = false

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        glassView = NSGlassEffectView(frame: .zero)
        contentContainer = NSView(frame: .zero)
        titleLabel = NSTextField(labelWithString: "")
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_toolbar_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)

        wantsLayer = true

        // NSGlassEffectView with contentView (API macOS 26.0+)
        // Only contentView is guaranteed inside the glass effect
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.style = .regular
        glassView.cornerRadius = 0
        glassView.contentView = contentContainer
        addSubview(glassView)

        // Container inside glass
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        contentContainer.addSubview(titleLabel)

        if let params = args as? [String: Any] {
            isDark = params["isDark"] as? Bool ?? false
            if isDark { appearance = NSAppearance(named: .darkAqua) }
            if let tintValue = params["tintColor"] as? Int64 {
                glassView.tintColor = colorFromARGB(tintValue)
            }
            buildToolbar(params)
        }

        NSLayoutConstraint.activate([
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentContainer.leadingAnchor.constraint(equalTo: glassView.leadingAnchor, constant: 12),
            contentContainer.trailingAnchor.constraint(equalTo: glassView.trailingAnchor, constant: -12),
            contentContainer.topAnchor.constraint(equalTo: glassView.topAnchor, constant: 2),
            contentContainer.bottomAnchor.constraint(equalTo: glassView.bottomAnchor, constant: -2),

            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildToolbar(_ params: [String: Any]) {
        // Remove previous action buttons (keep titleLabel)
        for subview in contentContainer.subviews where subview is NSButton {
            subview.removeFromSuperview()
        }
        trailingButtons.removeAll()

        if let title = params["title"] as? String {
            titleLabel.stringValue = title
        }

        if let actions = params["actions"] as? [[String: Any]] {
            var previousView: NSView = titleLabel

            for (index, action) in actions.enumerated() {
                let button = NSButton(frame: .zero)
                button.tag = index
                button.target = self
                button.action = #selector(actionTapped(_:))
                button.bezelStyle = .texturedRounded
                button.font = NSFont.systemFont(ofSize: 13)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.setContentCompressionResistancePriority(.required, for: .horizontal)

                if let iconName = action["icon"] as? String, !iconName.isEmpty {
                    if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                        button.image = image
                        button.imagePosition = .imageOnly
                    }
                } else if let title = action["title"] as? String {
                    button.title = title
                }

                if let tintValue = action["tint"] as? Int64 {
                    button.contentTintColor = colorFromARGB(tintValue)
                }

                contentContainer.addSubview(button)
                trailingButtons.append(button)

                NSLayoutConstraint.activate([
                    button.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                    button.trailingAnchor.constraint(equalTo: previousView == titleLabel
                        ? contentContainer.trailingAnchor
                        : previousView.leadingAnchor, constant: -8)
                ])

                previousView = button
            }
        }
    }

    @objc private func actionTapped(_ sender: NSButton) {
        channel.invokeMethod("onActionTapped", arguments: ["index": sender.tag])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateTitle":
            if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
                titleLabel.stringValue = title
            }
            result(nil)
        case "setBrightness":
            if let args = call.arguments as? [String: Any], let dark = args["isDark"] as? Bool {
                isDark = dark
                appearance = dark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
            }
            result(nil)
        case "setTintColor":
            if let args = call.arguments as? [String: Any], let tintValue = args["tintColor"] as? Int64 {
                glassView.tintColor = colorFromARGB(tintValue)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
