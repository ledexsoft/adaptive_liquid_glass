import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSPopupMenuButtonViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSPopupMenuButtonView(
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

// MARK: - macOS Native Popup Menu Button

class MacOSPopupMenuButtonView: NSView {
    private let popup: NSPopUpButton
    private let channel: FlutterMethodChannel

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        popup = NSPopUpButton(frame: .zero, pullsDown: true)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_popup_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)
        wantsLayer = true

        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.target = self
        popup.action = #selector(popupChanged)
        popup.bezelStyle = .texturedRounded

        if let params = args as? [String: Any] {
            if let label = params["label"] as? String { popup.title = label }
            if let items = params["items"] as? [[String: Any]] {
                popup.menu?.removeAllItems()
                for item in items {
                    if item["isDivider"] as? Bool == true {
                        popup.menu?.addItem(.separator())
                    } else {
                        popup.addItem(withTitle: item["label"] as? String ?? "")
                    }
                }
            }
        }

        addSubview(popup)

        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: centerYAnchor),
            popup.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            popup.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func popupChanged() {
        channel.invokeMethod("onSelected", arguments: ["index": popup.indexOfSelectedItem])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setItems",
           let args = call.arguments as? [String: Any],
           let items = args["items"] as? [[String: Any]] {
            popup.menu?.removeAllItems()
            for item in items {
                if item["isDivider"] as? Bool == true {
                    popup.menu?.addItem(.separator())
                } else {
                    popup.addItem(withTitle: item["label"] as? String ?? "")
                }
            }
        }
        result(nil)
    }
}
