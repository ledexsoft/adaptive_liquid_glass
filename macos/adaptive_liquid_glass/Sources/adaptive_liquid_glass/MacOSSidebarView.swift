import FlutterMacOS
import AppKit

// MARK: - Factory

class MacOSSidebarViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return MacOSSidebarView(
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

// MARK: - Sidebar View Controller (contenido del sidebar)

@available(macOS 26.0, *)
class SidebarContentViewController: NSViewController {
    let tableView: NSTableView
    let scrollView: NSScrollView
    let glassView: NSGlassEffectView

    var items: [[String: Any]] = []
    var onItemSelected: ((Int) -> Void)?
    private var _selectedIndex: Int = 0

    var selectedIndex: Int {
        get { _selectedIndex }
        set {
            _selectedIndex = newValue
            let set = IndexSet(integer: newValue)
            tableView.selectRowIndexes(set, byExtendingSelection: false)
        }
    }

    init() {
        scrollView = NSScrollView(frame: .zero)
        tableView = NSTableView(frame: .zero)
        glassView = NSGlassEffectView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // El contenedor principal es directamente la glassView
        // para que NSSplitViewItem(sidebarWithViewController:) maneje el layout correctamente
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.style = .regular
        glassView.cornerRadius = 0

        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.contentView.drawsBackground = false

        // Table view (source list style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .sourceList
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.rowHeight = 36
        tableView.allowsMultipleSelection = false
        tableView.target = self
        tableView.action = #selector(tableViewClicked(_:))

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("sidebarColumn"))
        column.title = ""
        column.isEditable = false
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)
        tableView.sizeLastColumnToFit()

        // Scroll view content
        scrollView.documentView = tableView

        // Asignar scrollView como contentView del glass
        glassView.contentView = scrollView

        // La view del controller es la glassView directamente
        self.view = glassView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        if _selectedIndex >= 0, _selectedIndex < items.count {
            let set = IndexSet(integer: _selectedIndex)
            tableView.selectRowIndexes(set, byExtendingSelection: false)
        }
    }

    @objc func tableViewClicked(_ sender: Any) {
        let row = tableView.clickedRow
        if row >= 0 {
            _selectedIndex = row
            onItemSelected?(row)
        }
    }

    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - NSTableViewDataSource

@available(macOS 26.0, *)
extension SidebarContentViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
}

// MARK: - NSTableViewDelegate

@available(macOS 26.0, *)
extension SidebarContentViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < items.count else { return nil }
        let item = items[row]

        let identifier = NSUserInterfaceItemIdentifier("modernSidebarCell")
        var cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ModernSidebarCell

        if cell == nil {
            cell = ModernSidebarCell(identifier: identifier)
        }

        guard let modernCell = cell else { return nil }

        // Icon
        if let symbol = item["sfSymbol"] as? String, !symbol.isEmpty {
            if #available(macOS 11.0, *) {
                modernCell.iconView.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
            }
            modernCell.iconView.isHidden = false
        } else {
            modernCell.iconView.isHidden = true
        }

        // Label
        modernCell.labelField.stringValue = item["label"] as? String ?? ""

        // Badge
        if let badgeNum = item["badgeCount"] as? Int, badgeNum > 0 {
            modernCell.badgeField.stringValue = badgeNum > 99 ? "99+" : "\(badgeNum)"
            modernCell.badgeField.isHidden = false
        } else {
            modernCell.badgeField.isHidden = true
        }

        return modernCell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row >= 0, row < items.count {
            _selectedIndex = row
            onItemSelected?(row)
        }
    }
}

// MARK: - Modern Sidebar Cell with Auto Layout

@available(macOS 26.0, *)
class ModernSidebarCell: NSTableCellView {
    let iconView: NSImageView
    let labelField: NSTextField
    let badgeField: NSTextField

    init(identifier: NSUserInterfaceItemIdentifier) {
        iconView = NSImageView()
        labelField = NSTextField(labelWithString: "")
        badgeField = NSTextField(labelWithString: "")

        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 36))

        self.identifier = identifier
        wantsLayer = true

        // ── Icon ──
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyDown
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(iconView)

        // ── Label ──
        labelField.translatesAutoresizingMaskIntoConstraints = false
        labelField.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        labelField.textColor = .labelColor
        labelField.lineBreakMode = .byTruncatingTail
        labelField.maximumNumberOfLines = 1
        labelField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(labelField)

        // ── Badge ──
        badgeField.translatesAutoresizingMaskIntoConstraints = false
        badgeField.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        badgeField.alignment = .center
        badgeField.textColor = .white
        badgeField.wantsLayer = true
        badgeField.layer?.cornerRadius = 9
        badgeField.layer?.backgroundColor = NSColor.systemRed.cgColor
        badgeField.setContentHuggingPriority(.required, for: .horizontal)
        badgeField.setContentCompressionResistancePriority(.required, for: .horizontal)
        badgeField.isHidden = true
        addSubview(badgeField)

        // ── Constraints ──
        NSLayoutConstraint.activate([
            // Icon: leading 12, centerY, 20x20
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            // Label: trailing icon + 8, leading badge - 6  (o trailing superview - 12 si no hay badge)
            labelField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            labelField.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelField.trailingAnchor.constraint(lessThanOrEqualTo: badgeField.leadingAnchor, constant: -6),

            // Badge: trailing 12, centerY, minWidth 20, height 18
            badgeField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            badgeField.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            badgeField.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - Main Sidebar View (FlutterPlatformView wrapper)

@available(macOS 26.0, *)
class MacOSSidebarView: NSView {
    private let splitViewController: NSSplitViewController
    private let sidebarContentVC: SidebarContentViewController
    private let channel: FlutterMethodChannel
    private let contentPlaceholderVC: NSViewController
    private var sidebarWidth: CGFloat = 220

    init(
        frame: NSRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        splitViewController = NSSplitViewController()
        sidebarContentVC = SidebarContentViewController()
        contentPlaceholderVC = NSViewController()
        channel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/macos_sidebar_\(viewId)",
            binaryMessenger: messenger
        )

        super.init(frame: frame)

        wantsLayer = true

        // ── Setup Split View ──
        splitViewController.view.translatesAutoresizingMaskIntoConstraints = false

        // Sidebar item usando API nativa NSSplitViewItem(sidebarWithViewController:)
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarContentVC)
        sidebarItem.canCollapse = true
        sidebarItem.canCollapseFromWindowResize = true
        sidebarItem.allowsFullHeightLayout = true
        sidebarItem.minimumThickness = 180
        sidebarItem.maximumThickness = 320
        sidebarItem.preferredThicknessFraction = 0.25
        sidebarItem.titlebarSeparatorStyle = .none

        // Content item (placeholder para el contenido Flutter)
        let contentPlaceholder = NSView(frame: .zero)
        contentPlaceholder.wantsLayer = true
        contentPlaceholder.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        contentPlaceholderVC.view = contentPlaceholder
        let contentItem = NSSplitViewItem(viewController: contentPlaceholderVC)
        contentItem.minimumThickness = 200

        splitViewController.addSplitViewItem(sidebarItem)
        splitViewController.addSplitViewItem(contentItem)

        addSubview(splitViewController.view)

        NSLayoutConstraint.activate([
            splitViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            splitViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            splitViewController.view.topAnchor.constraint(equalTo: topAnchor),
            splitViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // ── Configurar desde argumentos ──
        if let params = args as? [String: Any] {
            sidebarWidth = params["width"] as? CGFloat ?? 220
            sidebarItem.minimumThickness = min(sidebarWidth - 40, 180)
            sidebarItem.maximumThickness = max(sidebarWidth + 100, 320)

            if let itemsData = params["items"] as? [[String: Any]] {
                sidebarContentVC.items = itemsData
            }

            let selectedIdx = params["selectedIndex"] as? Int ?? 0
            sidebarContentVC.selectedIndex = selectedIdx

            // Dark mode
            if let isDark = params["isDark"] as? Bool {
                appearance = isDark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
                sidebarContentVC.view.appearance = appearance
            }
        }

        sidebarContentVC.onItemSelected = { [weak self] index in
            self?.channel.invokeMethod("onItemSelected", arguments: ["index": index])
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
        case "setSelectedIndex":
            if let args = call.arguments as? [String: Any], let index = args["index"] as? Int {
                sidebarContentVC.selectedIndex = index
            }
            result(nil)
        case "setCollapsed":
            if let args = call.arguments as? [String: Any], let collapsed = args["collapsed"] as? Bool {
                if let sidebarItem = splitViewController.splitViewItems.first {
                    sidebarItem.isCollapsed = collapsed
                }
            }
            result(nil)
        case "toggleSidebar":
            if let sidebarItem = splitViewController.splitViewItems.first {
                sidebarItem.isCollapsed.toggle()
                result(sidebarItem.isCollapsed)
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
