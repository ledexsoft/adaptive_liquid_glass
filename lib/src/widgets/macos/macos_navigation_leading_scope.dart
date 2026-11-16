import 'package:flutter/widgets.dart';

/// Opt-in macOS leading control for descendant AdaptiveScaffold app bars.
///
/// The builder receives the scaffold context beneath its route, so navigation
/// state is resolved for that page. An explicit app-bar leading takes priority.
/// Other platforms and custom Cupertino navigation bars are unchanged.
class MacOSNavigationLeadingScope extends InheritedWidget {
  const MacOSNavigationLeadingScope({
    super.key,
    required this.builder,
    required super.child,
  });

  /// Returning null preserves the navigation bar automatic leading behavior.
  final Widget? Function(BuildContext) builder;

  static MacOSNavigationLeadingScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MacOSNavigationLeadingScope>();

  @override
  bool updateShouldNotify(MacOSNavigationLeadingScope oldWidget) =>
      builder != oldWidget.builder;
}
