import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return MacOSTabBarView(
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

// MARK: - macOS Native TabBar with Liquid Glass (NSGlassEffectView API macOS 26.0+)

@available(macOS 26.0, *)
class MacOSTabBarView: NSView {
    private let glassView: NSGlassEffectView
    private let contentContainer: NSView
    private let tabStack: NSStackView
    private var tabButtons: [NSButton] = []
    private let channel: FlutterMethodChannel
    private var _selectedIndex: Int = 0
    private var isDark: Bool = false

    var selectedIndex: Int {
        get { _selectedIndex }
        set { selectTab(newValue, notifyFlutter: false) }
    }

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        glassView = NSGlassEffectView(frame: .zero)
        contentContainer = NSView(frame: .zero)
        tabStack = NSStackView(frame: .zero)
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_tab_bar_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)

        wantsLayer = true

        // NSGlassEffectView — contentView is the only view guaranteed inside glass
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.style = .regular
        glassView.cornerRadius = 0
        glassView.contentView = contentContainer
        addSubview(glassView)

        // Content container inside glass
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        // Tab stack inside content container
        tabStack.translatesAutoresizingMaskIntoConstraints = false
        tabStack.orientation = .horizontal
        tabStack.alignment = .centerY
        tabStack.distribution = .fillEqually
        tabStack.spacing = 0
        contentContainer.addSubview(tabStack)

        if let params = args as? [String: Any] {
            isDark = params["isDark"] as? Bool ?? false
            if isDark { appearance = NSAppearance(named: .darkAqua) }
            if let tintValue = params["tint"] as? Int64 {
                glassView.tintColor = colorFromARGB(tintValue)
            }
            buildTabs(params)
        }

        NSLayoutConstraint.activate([
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentContainer.leadingAnchor.constraint(equalTo: glassView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: glassView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: glassView.topAnchor, constant: 4),
            contentContainer.bottomAnchor.constraint(equalTo: glassView.bottomAnchor, constant: -4),

            tabStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tabStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            tabStack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            tabStack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildTabs(_ params: [String: Any]) {
        tabStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()

        guard let tabs = params["tabs"] as? [[String: Any]] else { return }
        let selectedIdx = params["selectedIndex"] as? Int ?? 0

        for (index, tabData) in tabs.enumerated() {
            let container = NSStackView(frame: .zero)
            container.orientation = .vertical
            container.alignment = .centerX
            container.spacing = 2

            let button = NSButton(frame: .zero)
            button.tag = index
            button.target = self
            button.action = #selector(tabTapped(_:))
            button.isBordered = false
            button.setButtonType(.momentaryChange)

            if let symbol = tabData["sfSymbol"] as? String {
                if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: tabData["title"] as? String) {
                    button.image = image
                    button.imagePosition = .imageAbove
                    button.imageScaling = .scaleProportionallyDown
                }
            }

            if let badgeCount = tabData["badgeCount"] as? Int, badgeCount > 0 {
                let badgeLabel = NSTextField(labelWithString: badgeCount > 99 ? "99+" : "\(badgeCount)")
                badgeLabel.font = NSFont.systemFont(ofSize: 10, weight: .bold)
                badgeLabel.textColor = .white
                badgeLabel.alignment = .center
                badgeLabel.wantsLayer = true
                badgeLabel.layer?.cornerRadius = 8
                badgeLabel.layer?.backgroundColor = NSColor.systemRed.cgColor
                badgeLabel.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(badgeLabel)
                NSLayoutConstraint.activate([
                    badgeLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 4),
                    badgeLabel.topAnchor.constraint(equalTo: container.topAnchor),
                    badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
                    badgeLabel.heightAnchor.constraint(equalToConstant: 16)
                ])
            }

            let label = NSTextField(labelWithString: tabData["title"] as? String ?? "")
            label.font = NSFont.systemFont(ofSize: 10)
            label.alignment = .center
            label.maximumNumberOfLines = 1
            label.lineBreakMode = .byTruncatingTail

            if let tintValue = tabData["tint"] as? Int64 {
                let color = colorFromARGB(tintValue)
                button.contentTintColor = color
                label.textColor = index == selectedIdx ? color : .secondaryLabelColor
            } else {
                button.contentTintColor = index == selectedIdx ? .controlAccentColor : .secondaryLabelColor
                label.textColor = index == selectedIdx ? .controlAccentColor : .secondaryLabelColor
            }

            container.addArrangedSubview(button)
            container.addArrangedSubview(label)
            tabStack.addArrangedSubview(container)
            tabButtons.append(button)
        }

        _selectedIndex = selectedIdx
    }

    @objc private func tabTapped(_ sender: NSButton) {
        selectTab(sender.tag, notifyFlutter: true)
    }

    private func selectTab(_ index: Int, notifyFlutter: Bool) {
        _selectedIndex = index
        for (i, button) in tabButtons.enumerated() {
            button.contentTintColor = i == index ? .controlAccentColor : .secondaryLabelColor
        }
        if notifyFlutter {
            channel.invokeMethod("onTabSelected", arguments: ["index": index])
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSelectedIndex":
            if let args = call.arguments as? [String: Any], let index = args["index"] as? Int {
                selectTab(index, notifyFlutter: false)
            }
            result(nil)
        case "setBrightness":
            if let args = call.arguments as? [String: Any], let dark = args["isDark"] as? Bool {
                isDark = dark
                appearance = dark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
            }
            result(nil)
        case "setTintColor":
            if let args = call.arguments as? [String: Any], let tintValue = args["tint"] as? Int64 {
                glassView.tintColor = colorFromARGB(tintValue)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
