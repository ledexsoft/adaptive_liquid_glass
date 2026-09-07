import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSSliderViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {
        return MacOSSliderView(
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

// MARK: - macOS Native Slider

class MacOSSliderView: NSView {
    private let slider: NSSlider
    private let channel: FlutterMethodChannel

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        slider = NSSlider(frame: .zero)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_slider_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)
        wantsLayer = true

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.target = self
        slider.action = #selector(sliderChanged)
        slider.isContinuous = true

        if let params = args as? [String: Any] {
            slider.minValue = params["min"] as? Double ?? 0.0
            slider.maxValue = params["max"] as? Double ?? 1.0
            slider.doubleValue = params["value"] as? Double ?? 0.5
        }

        addSubview(slider)

        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func sliderChanged() {
        channel.invokeMethod("onChanged", arguments: ["value": slider.doubleValue])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setValue":
            if let args = call.arguments as? [String: Any], let value = args["value"] as? Double {
                slider.doubleValue = value
            }
            result(nil)
        case "setRange":
            if let args = call.arguments as? [String: Any] {
                slider.minValue = args["min"] as? Double ?? slider.minValue
                slider.maxValue = args["max"] as? Double ?? slider.maxValue
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
