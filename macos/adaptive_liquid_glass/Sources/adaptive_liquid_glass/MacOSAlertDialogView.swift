import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSAlertDialogViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSAlertDialogView(
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

// MARK: - macOS Native Alert View

class MacOSAlertDialogView: NSView {
    private let channel: FlutterMethodChannel
    private var pendingArgs: [String: Any]?

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_alert_\(viewId)",
            binaryMessenger: messenger
        )
        super.init(frame: frame)
        wantsLayer = true
        pendingArgs = args as? [String: Any]

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func showAlert(with params: [String: Any]) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        if let title = params["title"] as? String { alert.messageText = title }
        if let message = params["message"] as? String { alert.informativeText = message }
        if #available(macOS 11.0, *) {
            if let iconName = params["icon"] as? String,
               let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                alert.icon = image
            }
        }
        if let actions = params["actions"] as? [[String: Any]] {
            for action in actions {
                let btn = alert.addButton(withTitle: action["title"] as? String ?? "OK")
                if (action["style"] as? String) == "destructive" {
                    if #available(macOS 11.0, *) {
                        btn.hasDestructiveAction = true
                    }
                }
            }
        }
        if let window = NSApplication.shared.mainWindow {
            alert.beginSheetModal(for: window) { [weak self] response in
                let index = response.rawValue - 1000
                self?.channel.invokeMethod("onAction", arguments: ["index": index])
            }
        } else {
            let response = alert.runModal()
            channel.invokeMethod("onAction", arguments: ["index": response.rawValue - 1000])
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "show" {
            if let args = call.arguments as? [String: Any] { showAlert(with: args)
            } else if let pendingArgs { showAlert(with: pendingArgs) }
        }
        result(nil)
    }
}
