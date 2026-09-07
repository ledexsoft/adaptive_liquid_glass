import FlutterMacOS
import AppKit

/// Main plugin class for Adaptive Platform UI on macOS
/// Registers platform views using native AppKit components
/// with Liquid Glass (NSVisualEffectView) blur effects.
public class AdaptivePlatformUiPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Register macOS Toolbar factory (macOS 26.0+)
        if #available(macOS 26.0, *) {
            let toolbarFactory = MacOSToolbarFactory(messenger: registrar.messenger)
            registrar.register(
                toolbarFactory,
                withId: "adaptive_liquid_glass/ios26_toolbar"
            )
        }

        // Register macOS TabBar factory (macOS 26.0+)
        if #available(macOS 26.0, *) {
            let tabBarFactory = MacOSTabBarViewFactory(messenger: registrar.messenger)
            registrar.register(
                tabBarFactory,
                withId: "adaptive_liquid_glass/ios26_tab_bar"
            )
        }

        // Register macOS Blur View factory
        let blurFactory = MacOSBlurViewFactory(messenger: registrar.messenger)
        registrar.register(
            blurFactory,
            withId: "adaptive_liquid_glass/ios26_blur_view"
        )

        // Register macOS Button factory
        let buttonFactory = MacOSButtonViewFactory(messenger: registrar.messenger)
        registrar.register(
            buttonFactory,
            withId: "adaptive_liquid_glass/ios26_button"
        )

        // Register macOS SegmentedControl factory
        let segmentedFactory = MacOSSegmentedControlViewFactory(messenger: registrar.messenger)
        registrar.register(
            segmentedFactory,
            withId: "adaptive_liquid_glass/ios26_segmented_control"
        )

        // Register macOS Switch factory
        let switchFactory = MacOSSwitchViewFactory(messenger: registrar.messenger)
        registrar.register(
            switchFactory,
            withId: "adaptive_liquid_glass/ios26_switch"
        )

        // Register macOS Slider factory
        let sliderFactory = MacOSSliderViewFactory(messenger: registrar.messenger)
        registrar.register(
            sliderFactory,
            withId: "adaptive_liquid_glass/ios26_slider"
        )

        // Register macOS AlertDialog factory
        let alertFactory = MacOSAlertDialogViewFactory(messenger: registrar.messenger)
        registrar.register(
            alertFactory,
            withId: "adaptive_liquid_glass/ios26_alert_dialog"
        )

        // Register macOS PopupMenuButton factory
        let popupFactory = MacOSPopupMenuButtonViewFactory(messenger: registrar.messenger)
        registrar.register(
            popupFactory,
            withId: "adaptive_liquid_glass/ios26_popup_menu_button"
        )

        // Register macOS Sidebar factory (NSSplitView + source list, macOS 26.0+)
        if #available(macOS 26.0, *) {
            let sidebarFactory = MacOSSidebarViewFactory(messenger: registrar.messenger)
            registrar.register(
                sidebarFactory,
                withId: "adaptive_liquid_glass/ios26_sidebar"
            )
        }
    }
}

// MARK: - Color Helper

func colorFromARGB(_ argb: Int64) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(red: r, green: g, blue: b, alpha: a)
}

func argbFromColor(_ color: NSColor) -> Int64 {
    guard let rgb = color.usingColorSpace(.sRGB) else { return 0 }
    let r = Int64(rgb.redComponent * 255)
    let g = Int64(rgb.greenComponent * 255)
    let b = Int64(rgb.blueComponent * 255)
    let a = Int64(rgb.alphaComponent * 255)
    return (a << 24) | (r << 16) | (g << 8) | b
}
