import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSSwitchViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSSwitchView(
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

// MARK: - macOS Native Switch

class MacOSSwitchView: NSView {
    private let switchControl: NSSwitch
    private let channel: FlutterMethodChannel

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        switchControl = NSSwitch(frame: .zero)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_switch_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)
        wantsLayer = true

        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.target = self
        switchControl.action = #selector(switchChanged)

        if let params = args as? [String: Any] {
            switchControl.state = (params["value"] as? Bool ?? false) ? .on : .off
        }

        addSubview(switchControl)

        NSLayoutConstraint.activate([
            switchControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func switchChanged() {
        channel.invokeMethod("onChanged", arguments: ["value": switchControl.state == .on])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setValue", let args = call.arguments as? [String: Any], let value = args["value"] as? Bool {
            switchControl.state = value ? .on : .off
        }
        result(nil)
    }
}
