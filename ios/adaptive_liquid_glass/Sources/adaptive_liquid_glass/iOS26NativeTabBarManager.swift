import Flutter
import UIKit

/// Manager for iOS 26+ Native Tab Bar with Search Support
/// This class manages a native UITabBarController at the app level
/// and coordinates with Flutter for content display
@available(iOS 14.0, *)
class iOS26NativeTabBarManager: NSObject {

    static let shared = iOS26NativeTabBarManager()

    private var tabBarController: UITabBarController?
    private var flutterViewController: FlutterViewController?
    private var searchController: UISearchController?
    private var methodChannel: FlutterMethodChannel?

    private var tabConfigurations: [TabConfig] = []
    private var searchTabIndex: Int = -1
    private var isEnabled: Bool = false

    struct TabConfig {
        let title: String
        let sfSymbol: String?
        let isSearchTab: Bool
        let badgeCount: Int?
    }

    private override init() {
        super.init()
    }

    /// Setup native tab bar with Flutter
    func setup(messenger: FlutterBinaryMessenger) {
        // Setup method channel
        self.methodChannel = FlutterMethodChannel(
            name: "adaptive_liquid_glass/native_tab_bar",
            binaryMessenger: messenger
        )

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    /// Find Flutter view controller
    private func getFlutterViewController() -> FlutterViewController? {
        if let flutterVC = flutterViewController {
            return flutterVC
        }

        // Try to find it from the key window of the active scene
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        if let window = keyWindow {
            if let flutterVC = window.rootViewController as? FlutterViewController {
                self.flutterViewController = flutterVC
                return flutterVC
            }
        }

        return nil
    }

    /// Enable native tab bar mode
    private func enableNativeTabBar(tabs: [TabConfig], selectedIndex: Int) {
        guard let flutterVC = getFlutterViewController() else {
            return
        }

        if #available(iOS 18.0, *) {
            enableModernTabBar(tabs: tabs, selectedIndex: selectedIndex, flutterVC: flutterVC)
            return
        }

        // Create tab bar controller if needed
        if tabBarController == nil {
            let tabBar = UITabBarController()
            tabBarController = tabBar

            // Setup iOS 26 appearance
            setupTabBarAppearance(tabBar)
        }

        guard let tabBar = tabBarController else { return }

        // Store configuration
        self.tabConfigurations = tabs
        self.searchTabIndex = tabs.firstIndex(where: { $0.isSearchTab }) ?? -1

        // Create view controllers for each tab
        var viewControllers: [UIViewController] = []

        for (index, config) in tabs.enumerated() {
            if config.isSearchTab {
                // Create search tab with navigation controller
                let searchVC = SearchTabViewController()
                searchVC.tabIndex = index
                searchVC.onTabSelected = { [weak self] idx in
                    self?.notifyTabSelected(idx)
                }

                let navController = UINavigationController(rootViewController: searchVC)

                // Setup search controller
                let search = UISearchController(searchResultsController: nil)
                search.searchResultsUpdater = self
                search.searchBar.delegate = self
                search.obscuresBackgroundDuringPresentation = false
                search.searchBar.placeholder = "Search"
                search.hidesNavigationBarDuringPresentation = false

                searchVC.navigationItem.searchController = search
                searchVC.navigationItem.hidesSearchBarWhenScrolling = false

                self.searchController = search

                // Setup tab bar item with search system item
                navController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: index)
                if !config.title.isEmpty {
                    navController.tabBarItem.title = config.title
                }

                viewControllers.append(navController)
            } else {
                // Regular tab - use Flutter view
                let tabVC = FlutterTabViewController()
                tabVC.tabIndex = index
                tabVC.onTabSelected = { [weak self] idx in
                    self?.notifyTabSelected(idx)
                }

                // Setup tab bar item
                var image: UIImage?
                if let symbol = config.sfSymbol {
                    image = UIImage(systemName: symbol) ?? UIImage(named: symbol)
                }
                tabVC.tabBarItem = UITabBarItem(
                    title: config.title,
                    image: image,
                    selectedImage: image
                )
                tabVC.tabBarItem.tag = index
                
                // Set badge value if provided
                if let count = config.badgeCount, count > 0 {
                    tabVC.tabBarItem.badgeValue = count > 99 ? "99+" : String(count)
                } else {
                    tabVC.tabBarItem.badgeValue = nil
                }

                viewControllers.append(tabVC)
            }
        }

        tabBar.viewControllers = viewControllers
        tabBar.selectedIndex = selectedIndex
        tabBar.delegate = self

        // Replace root view controller
        if let window = flutterVC.view.window {
            // Embed Flutter view in the first non-search tab
            if let firstTab = viewControllers.first(where: { !($0 is UINavigationController) }) as? FlutterTabViewController {
                firstTab.embedFlutterView(flutterVC.view)
            }

            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = tabBar
            }

            self.isEnabled = true
        }
    }

    @available(iOS 18.0, *)
    private func enableModernTabBar(tabs: [TabConfig], selectedIndex: Int, flutterVC: FlutterViewController) {
        if tabBarController == nil {
            let tabBar = UITabBarController()
            tabBarController = tabBar
        }

        guard let tabBar = tabBarController else { return }

        self.tabConfigurations = tabs
        self.searchTabIndex = tabs.firstIndex(where: { $0.isSearchTab }) ?? -1

        var modernTabs: [UITab] = []

        for (index, config) in tabs.enumerated() {
            if config.isSearchTab {
                let searchVC = SearchTabViewController()
                searchVC.tabIndex = index
                searchVC.onTabSelected = { [weak self] idx in
                    self?.notifyTabSelected(idx)
                }

                let navController = UINavigationController(rootViewController: searchVC)
                let search = UISearchController(searchResultsController: nil)
                search.searchResultsUpdater = self
                search.searchBar.delegate = self
                search.obscuresBackgroundDuringPresentation = false
                search.searchBar.placeholder = "Search"
                search.hidesNavigationBarDuringPresentation = false

                searchVC.navigationItem.searchController = search
                searchVC.navigationItem.hidesSearchBarWhenScrolling = false
                self.searchController = search

                let searchTab = UISearchTab(
                    title: config.title.isEmpty ? "Search" : config.title,
                    image: UIImage(systemName: "magnifyingglass"),
                    identifier: "tab_\(index)"
                ) { _ in
                    return navController
                }

                if let count = config.badgeCount, count > 0 {
                    searchTab.badgeValue = count > 99 ? "99+" : String(count)
                }
                modernTabs.append(searchTab)
            } else {
                let tabVC = FlutterTabViewController()
                tabVC.tabIndex = index
                tabVC.onTabSelected = { [weak self] idx in
                    self?.notifyTabSelected(idx)
                }

                let symbol = config.sfSymbol ?? "circle"
                let image = UIImage(systemName: symbol) ?? UIImage(named: symbol)
                let tab = UITab(
                    title: config.title,
                    image: image,
                    identifier: "tab_\(index)"
                ) { _ in
                    return tabVC
                }

                if let count = config.badgeCount, count > 0 {
                    tab.badgeValue = count > 99 ? "99+" : String(count)
                }
                modernTabs.append(tab)
            }
        }

        tabBar.tabs = modernTabs
        if selectedIndex < modernTabs.count {
            tabBar.selectedTab = modernTabs[selectedIndex]
        }
        tabBar.delegate = self

        if let window = flutterVC.view.window {
            if let firstTabVC = tabBar.tabs.first(where: { !($0 is UISearchTab) })?.viewController as? FlutterTabViewController {
                firstTabVC.embedFlutterView(flutterVC.view)
            }

            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = tabBar
            }

            self.isEnabled = true
        }
    }

    /// Disable native tab bar and return to Flutter-only mode
    private func disableNativeTabBar() {
        guard let flutterVC = getFlutterViewController(),
              let window = flutterVC.view.window else {
            return
        }

        // Remove Flutter view from tab if embedded
        if let tabBar = tabBarController {
            if #available(iOS 18.0, *) {
                if let selectedVC = tabBar.selectedTab?.viewController as? FlutterTabViewController {
                    selectedVC.removeFlutterView()
                }
            } else if let selectedVC = tabBar.selectedViewController as? FlutterTabViewController {
                selectedVC.removeFlutterView()
            }
        }

        // Restore Flutter as root
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = flutterVC
        }

        self.isEnabled = false
        self.tabBarController = nil
    }

    private func setupTabBarAppearance(_ tabBar: UITabBarController) {
        let appearance = UITabBarAppearance()

        // iOS 26 Liquid Glass design
        appearance.configureWithDefaultBackground()

        // On iOS 26, UITabBar applies Apple's native Liquid Glass appearance
        // when configured with the default background. Its public
        // backgroundEffect property is still typed as UIBlurEffect, so do not
        // replace the system material with a manually forced blur here.
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        tabBar.tabBar.standardAppearance = appearance
        tabBar.tabBar.scrollEdgeAppearance = appearance
    }

    private func notifyTabSelected(_ index: Int) {
        methodChannel?.invokeMethod("onTabSelected", arguments: ["index": index])

        // Move Flutter view to selected tab if not search tab
        if index != searchTabIndex,
           let flutterView = getFlutterViewController()?.view,
           let tabBar = tabBarController {
            
            if #available(iOS 18.0, *) {
                if index < tabBar.tabs.count,
                   let selectedVC = tabBar.tabs[index].viewController as? FlutterTabViewController {
                    selectedVC.embedFlutterView(flutterView)
                }
            } else if let selectedVC = tabBar.selectedViewController as? FlutterTabViewController {
                selectedVC.embedFlutterView(flutterView)
            }
        }
    }

    private func notifySearchQueryChanged(_ query: String) {
        methodChannel?.invokeMethod("onSearchQueryChanged", arguments: ["query": query])
    }

    private func notifySearchSubmitted(_ query: String) {
        methodChannel?.invokeMethod("onSearchSubmitted", arguments: ["query": query])
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableNativeTabBar":
            guard let args = call.arguments as? [String: Any],
                  let tabsData = args["tabs"] as? [[String: Any]] else {
                result(FlutterError(code: "invalid_args", message: "Invalid tabs data", details: nil))
                return
            }

            let tabs = tabsData.compactMap { data -> TabConfig? in
                guard let title = data["title"] as? String else { return nil }
                let symbol = data["sfSymbol"] as? String
                let isSearch = (data["isSearch"] as? Bool) ?? false
                let badgeCount = data["badgeCount"] as? Int
                return TabConfig(title: title, sfSymbol: symbol, isSearchTab: isSearch, badgeCount: badgeCount)
            }

            let selectedIndex = (args["selectedIndex"] as? Int) ?? 0
            enableNativeTabBar(tabs: tabs, selectedIndex: selectedIndex)
            result(nil)

        case "disableNativeTabBar":
            disableNativeTabBar()
            result(nil)

        case "setSelectedIndex":
            guard let args = call.arguments as? [String: Any],
                  let index = args["index"] as? Int else {
                result(FlutterError(code: "invalid_args", message: "Invalid index", details: nil))
                return
            }
            if #available(iOS 18.0, *), let tabs = tabBarController?.tabs, index < tabs.count {
                tabBarController?.selectedTab = tabs[index]
            } else {
                tabBarController?.selectedIndex = index
            }
            result(nil)

        case "showSearch":
            searchController?.isActive = true
            result(nil)

        case "hideSearch":
            searchController?.isActive = false
            result(nil)

        case "isEnabled":
            result(isEnabled)

        case "setBadgeCounts":
            guard let args = call.arguments as? [String: Any],
                  let badgeCounts = args["badgeCounts"] as? [Int?] else {
                result(FlutterError(code: "invalid_args", message: "Invalid badge counts", details: nil))
                return
            }

            // Update badge counts for existing tab bar items
            if let tabBar = tabBarController {
                if #available(iOS 18.0, *) {
                    for (index, tab) in tabBar.tabs.enumerated() {
                        if index < badgeCounts.count {
                            let count = badgeCounts[index]
                            tab.badgeValue = (count != nil && count! > 0) ? (count! > 99 ? "99+" : String(count!)) : nil
                        }
                    }
                } else if let viewControllers = tabBar.viewControllers {
                    for (index, viewController) in viewControllers.enumerated() {
                        if index < badgeCounts.count {
                            let count = badgeCounts[index]
                            if let count = count, count > 0 {
                                viewController.tabBarItem.badgeValue = count > 99 ? "99+" : String(count)
                            } else {
                                viewController.tabBarItem.badgeValue = nil
                            }
                        }
                    }
                }
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - UITabBarControllerDelegate

@available(iOS 14.0, *)
extension iOS26NativeTabBarManager: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController) ?? 0
        notifyTabSelected(index)
    }
}

// MARK: - UISearchResultsUpdating

@available(iOS 14.0, *)
extension iOS26NativeTabBarManager: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        notifySearchQueryChanged(query)
    }
}

// MARK: - UISearchBarDelegate

@available(iOS 14.0, *)
extension iOS26NativeTabBarManager: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        notifySearchSubmitted(query)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        methodChannel?.invokeMethod("onSearchCancelled", arguments: nil)
    }
}

// MARK: - Tab View Controllers

private class FlutterTabViewController: UIViewController {
    var tabIndex: Int = 0
    var onTabSelected: ((Int) -> Void)?
    private var embeddedFlutterView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onTabSelected?(tabIndex)
    }

    func embedFlutterView(_ flutterView: UIView) {
        // Remove from previous parent
        flutterView.removeFromSuperview()

        // Add to this view controller
        flutterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flutterView)
        NSLayoutConstraint.activate([
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flutterView.topAnchor.constraint(equalTo: view.topAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        embeddedFlutterView = flutterView
    }

    func removeFlutterView() {
        embeddedFlutterView?.removeFromSuperview()
        embeddedFlutterView = nil
    }
}

private class SearchTabViewController: UIViewController {
    var tabIndex: Int = 0
    var onTabSelected: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"

        // Add placeholder content
        let label = UILabel()
        label.text = "Search results will appear here\n\nSearch functionality is controlled by Flutter"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onTabSelected?(tabIndex)
    }
}
