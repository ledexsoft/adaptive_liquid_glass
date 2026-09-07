import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSSegmentedControlViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSSegmentedControlView(
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

// MARK: - macOS Native Segmented Control

class MacOSSegmentedControlView: NSView {
    private let segmented: NSSegmentedControl
    private let channel: FlutterMethodChannel

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        segmented = NSSegmentedControl(frame: .zero)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_segmented_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)
        wantsLayer = true

        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.target = self
        segmented.action = #selector(segmentedChanged)
        segmented.segmentStyle = .texturedSquare

        if let params = args as? [String: Any] {
            if let labels = params["labels"] as? [String] {
                segmented.segmentCount = labels.count
                for (i, label) in labels.enumerated() { segmented.setLabel(label, forSegment: i) }
            }
            if let symbols = params["sfSymbols"] as? [String] {
                if segmented.segmentCount == 0 { segmented.segmentCount = symbols.count }
                for (i, symbol) in symbols.enumerated() where i < segmented.segmentCount {
                    if #available(macOS 11.0, *) {
                        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
                            segmented.setImage(image, forSegment: i)
                            segmented.setImageScaling(.scaleProportionallyDown, forSegment: i)
                        }
                    }
                }
            }
            segmented.selectedSegment = params["selectedIndex"] as? Int ?? 0
        }

        addSubview(segmented)

        NSLayoutConstraint.activate([
            segmented.centerXAnchor.constraint(equalTo: centerXAnchor),
            segmented.centerYAnchor.constraint(equalTo: centerYAnchor),
            segmented.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            segmented.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func segmentedChanged() {
        channel.invokeMethod("onValueChanged", arguments: ["index": segmented.selectedSegment])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setSelectedIndex",
           let args = call.arguments as? [String: Any],
           let index = args["index"] as? Int {
            segmented.selectedSegment = index
        }
        result(nil)
    }
}
