import UIKit

/// Centralizes Liquid Glass availability and the legacy material fallback.
///
/// Keeping the availability check here prevents individual controls from
/// drifting into subtly different materials as the package evolves.
enum AdaptiveGlassMaterial {
    static func effect(
        styleRawValue: Int = 0,
        tintColor: UIColor? = nil,
        interactive: Bool = false,
        fallback: UIBlurEffect.Style = .systemUltraThinMaterial
    ) -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let style = UIGlassEffect.Style(rawValue: styleRawValue) ?? .regular
            let glass = UIGlassEffect(style: style)
            glass.isInteractive = interactive
            glass.tintColor = tintColor
            return glass
        }
        return UIBlurEffect(style: fallback)
    }

    /// A container effect lets adjacent native glass elements blend and merge
    /// at the configured distance. On older iOS versions it degrades to blur.
    static func containerEffect(
        spacing: CGFloat = 16,
        fallback: UIBlurEffect.Style = .systemUltraThinMaterial
    ) -> UIVisualEffect {
        if #available(iOS 26.0, *) {
            let container = UIGlassContainerEffect()
            container.spacing = spacing
            return container
        }
        return UIBlurEffect(style: fallback)
    }
}
