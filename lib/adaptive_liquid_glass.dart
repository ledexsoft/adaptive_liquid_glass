/// A Flutter package that provides adaptive platform-specific widgets
///
/// This package automatically renders native-looking widgets based on the platform:
/// - iOS 26+: Modern iOS 26 native designs with latest visual styles
/// - iOS <26 (iOS 18 and below): Traditional Cupertino widgets
/// - Android: Material 3 Expressive widgets where an adaptive equivalent exists
///
/// ## Features
///
/// - Automatic platform detection
/// - iOS version-specific widget rendering
/// - Native iOS 26 designs following Apple's Human Interface Guidelines
/// - Seamless fallback to appropriate widgets for older iOS versions
/// - Native Android Material 3 Expressive widgets where an adaptive wrapper exists
///
/// ## Usage
///
/// ```dart
/// import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
///
/// AdaptiveButton(
///   onPressed: () {
///     print('Button pressed');
///   },
///   child: Text('Click Me'),
/// )
/// ```
library;

// Platform utilities
export 'src/platform/platform_info.dart';

// Animation utilities
export 'src/utils/animation.dart';

// Styles
export 'src/style/sf_symbol.dart';
export 'src/theme/adaptive_material_expressive_theme.dart';

// Widgets
export 'src/widgets/adaptive_app.dart';
export 'src/widgets/adaptive_app_bar.dart';
export 'src/widgets/adaptive_bottom_navigation_bar.dart';
export 'src/widgets/adaptive_button.dart';
export 'src/widgets/adaptive_button_group.dart';
export 'src/widgets/android/android_m3e_native_icon.dart';
export 'src/widgets/adaptive_carousel.dart';
export 'src/widgets/adaptive_switch.dart';
export 'src/widgets/adaptive_checkbox.dart';
export 'src/widgets/adaptive_radio.dart';
export 'src/widgets/adaptive_card.dart';
export 'src/widgets/adaptive_badge.dart';
export 'src/widgets/adaptive_tooltip.dart';
export 'src/widgets/adaptive_toolbar.dart';
export 'src/widgets/adaptive_slider.dart';
export 'src/widgets/adaptive_segmented_control.dart';
export 'src/widgets/adaptive_alert_dialog.dart';
export 'src/widgets/adaptive_popup_menu_button.dart';
export 'src/widgets/adaptive_context_menu.dart';
export 'src/widgets/adaptive_scaffold.dart';
export 'src/widgets/adaptive_app_bar_action.dart';
export 'src/widgets/adaptive_ai_sparkle_icon.dart';
export 'src/widgets/adaptive_expressive_shape.dart';
export 'src/widgets/adaptive_snackbar.dart';
export 'src/widgets/adaptive_split_button.dart';
export 'src/widgets/adaptive_date_picker.dart';
export 'src/widgets/adaptive_time_picker.dart';
export 'src/widgets/adaptive_list_tile.dart';
export 'src/widgets/adaptive_text_field.dart';
export 'src/widgets/adaptive_text_form_field.dart';
export 'src/widgets/adaptive_tab_view.dart';
export 'src/widgets/adaptive_floating_action_button.dart';
export 'src/widgets/adaptive_extended_floating_action_button.dart';
export 'src/widgets/adaptive_fab_menu.dart';
export 'src/widgets/adaptive_icon_button.dart';
export 'src/widgets/adaptive_form_section.dart';
export 'src/widgets/adaptive_expansion_tile.dart';
export 'src/widgets/adaptive_blur_view.dart';
export 'src/widgets/adaptive_divider.dart';
export 'src/widgets/adaptive_search_bar.dart';
export 'src/widgets/adaptive_switch_list_tile.dart';
export 'src/widgets/adaptive_navigation_rail.dart';
export 'src/widgets/adaptive_navigation_drawer.dart';
export 'src/widgets/adaptive_progress_indicator.dart';
export 'src/widgets/adaptive_loading_indicator.dart';
export 'src/widgets/adaptive_refresh_indicator.dart';
export 'src/widgets/adaptive_action_sheet.dart';

// iOS 26 specific widgets (for advanced usage)
export 'src/widgets/ios26/ios26_button.dart';
export 'src/widgets/ios26/ios26_switch.dart';
export 'src/widgets/ios26/ios26_slider.dart';
export 'src/widgets/ios26/ios26_segmented_control.dart';
export 'src/widgets/ios26/ios26_alert_dialog.dart';
export 'src/widgets/ios26/ios26_glass_grid.dart';
export 'src/widgets/ios26/ios26_native_search_tab_bar.dart';
export 'src/widgets/ios26/ios26_native_tab_bar.dart';
export 'src/widgets/ios26/ios26_scaffold_legacy.dart';
