import Flutter
import UIKit

/// Main plugin class for Adaptive Platform UI
/// Registers platform views and handles plugin lifecycle
public class AdaptivePlatformUiPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Initialize iOS Native Tab Bar Manager
        if #available(iOS 14.0, *) {
            iOS26NativeTabBarManager.shared.setup(messenger: registrar.messenger())
        }

        // Register iOS 26 Button platform view factory
        let ios26ButtonFactory = iOS26ButtonViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26ButtonFactory,
            withId: "adaptive_liquid_glass/ios26_button"
        )

        // Register iOS 26 Switch platform view factory
        let ios26SwitchFactory = iOS26SwitchViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SwitchFactory,
            withId: "adaptive_liquid_glass/ios26_switch"
        )

        // Register iOS 26 Slider platform view factory
        let ios26SliderFactory = iOS26SliderViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SliderFactory,
            withId: "adaptive_liquid_glass/ios26_slider"
        )

        // Register iOS 26 SegmentedControl platform view factory
        let ios26SegmentedControlFactory = iOS26SegmentedControlViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26SegmentedControlFactory,
            withId: "adaptive_liquid_glass/ios26_segmented_control"
        )

        // Register iOS 26 AlertDialog platform view factory
        let ios26AlertDialogFactory = iOS26AlertDialogViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26AlertDialogFactory,
            withId: "adaptive_liquid_glass/ios26_alert_dialog"
        )

        // Register iOS 26 PopupMenuButton platform view factory
        let ios26PopupMenuButtonFactory = iOS26PopupMenuButtonViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26PopupMenuButtonFactory,
            withId: "adaptive_liquid_glass/ios26_popup_menu_button"
        )

        // Register iOS 26 TabBar platform view factory
        let ios26TabBarFactory = iOS26TabBarViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26TabBarFactory,
            withId: "adaptive_liquid_glass/ios26_tab_bar"
        )

        // Register iOS 26 Toolbar platform view factory
        let ios26ToolbarFactory = iOS26ToolbarFactory(messenger: registrar.messenger())
        registrar.register(
            ios26ToolbarFactory,
            withId: "adaptive_liquid_glass/ios26_toolbar"
        )

        // Register iOS 26 Blur View platform view factory
        let ios26BlurViewFactory = iOS26BlurViewFactory(messenger: registrar.messenger())
        registrar.register(
            ios26BlurViewFactory,
            withId: "adaptive_liquid_glass/ios26_blur_view"
        )

        // Register iOS 26 Glass Grid platform view factory (OneBlink →
        // Alimentos, 22/08): all category cards nested in one
        // UIGlassContainerEffect so adjacent glass elements merge/spill.
        let ios26GlassGridFactory = iOS26GlassGridFactory(messenger: registrar.messenger())
        registrar.register(
            ios26GlassGridFactory,
            withId: "adaptive_liquid_glass/ios26_glass_grid"
        )
    }
}
