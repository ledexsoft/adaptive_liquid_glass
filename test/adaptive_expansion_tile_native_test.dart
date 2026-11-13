import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  test('expansion tiles reject baseline child alignment', () {
    expect(
      () => AdaptiveExpansionTile(
        title: const Text('Section'),
        expandedCrossAxisAlignment: CrossAxisAlignment.baseline,
        children: const [],
      ),
      throwsAssertionError,
    );
  });

  testWidgets(
    'native expansion header uses Compose height and internal padding',
    (tester) async {
      PlatformInfo.debugPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: AdaptiveExpansionTile(
                title: Text('Section'),
                subtitle: Text('Details'),
                tilePadding: EdgeInsetsDirectional.fromSTEB(24, 15, 8, 15),
                collapsedBackgroundColor: Colors.blue,
                children: [Text('Child')],
              ),
            ),
          ),
        ),
      );

      final view = tester.widget<AndroidView>(find.byType(AndroidView));
      final properties = view.creationParams! as Map<Object?, Object?>;
      expect(properties['component'], 'expansionTile');
      expect(properties['expanded'], isFalse);
      expect(
        properties['stateDescription'],
        MaterialLocalizations.of(
          tester.element(find.byType(AdaptiveExpansionTile)),
        ).expandedHint,
      );
      expect(properties['padding'], [8.0, 15.0, 24.0, 15.0]);
      expect(properties['backgroundColor'], Colors.blue.toARGB32());
      expect(tester.getSize(find.byType(AndroidView)).height, 82);
    },
  );

  testWidgets('native expansion header rejects negative tile padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            tilePadding: EdgeInsets.only(right: -2),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native expansion header inherits themed tile padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          expansionTileTheme: const ExpansionTileThemeData(
            tilePadding: EdgeInsetsDirectional.fromSTEB(24, 15, 8, 15),
          ),
        ),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveExpansionTile(
              title: Text('Section'),
              subtitle: Text('Details'),
              children: [Text('Child')],
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['padding'], [8.0, 15.0, 24.0, 15.0]);
    expect(tester.getSize(find.byType(AndroidView)).height, 82);
  });

  testWidgets('native expansion header inherits themed state colors', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.red,
            collapsedBackgroundColor: Colors.blue,
            textColor: Colors.white,
            collapsedTextColor: Colors.black,
            iconColor: Colors.yellow,
            collapsedIconColor: Colors.green,
          ),
        ),
        home: const Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            subtitle: Text('Details'),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    AndroidM3EPlatformView bridge() => tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    expect(bridge().properties['backgroundColor'], Colors.blue.toARGB32());
    expect(bridge().properties['textColor'], Colors.black.toARGB32());
    expect(bridge().properties['subtitleColor'], Colors.black.toARGB32());
    expect(bridge().properties['iconColor'], Colors.green.toARGB32());

    bridge().onEvent('tapped', null);
    await tester.pump();
    expect(bridge().properties['backgroundColor'], Colors.red.toARGB32());
    expect(bridge().properties['textColor'], Colors.white.toARGB32());
    expect(bridge().properties['subtitleColor'], Colors.white.toARGB32());
    expect(bridge().properties['iconColor'], Colors.yellow.toARGB32());
  });

  testWidgets('expanded native tile colors its Flutter children background', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.red,
          ),
        ),
        home: const Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            initiallyExpanded: true,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('Child'),
        matching: find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == Colors.red,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('native expansion header follows Compose measured height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('A long heading that can wrap'),
            subtitle: Text('Supporting detail'),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final originalState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 120.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 120);
    expect(tester.state(find.byType(AndroidView)), same(originalState));
  });

  testWidgets('expanded native header announces its localized state', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            initiallyExpanded: true,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['expanded'], isTrue);
    expect(
      properties['stateDescription'],
      MaterialLocalizations.of(
        tester.element(find.byType(AdaptiveExpansionTile)),
      ).collapsedHint,
    );
  });

  testWidgets('native expansion applies custom shapes to the whole tile', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const collapsedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.red, width: 2),
    );
    const expandedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      side: BorderSide(color: Colors.blue, width: 2),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: AdaptiveExpansionTile(
              title: Text('Section'),
              collapsedShape: collapsedShape,
              shape: expandedShape,
              collapsedBackgroundColor: Colors.blue,
              backgroundColor: Colors.red,
              clipBehavior: Clip.hardEdge,
              children: [Text('Child')],
            ),
          ),
        ),
      ),
    );

    Material shapeMaterial() => tester.widget<Material>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.shape == collapsedShape ||
            widget is Material && widget.shape == expandedShape,
      ),
    );

    final originalNativeState = tester.state(find.byType(AndroidView));
    expect(shapeMaterial().shape, collapsedShape);
    expect(shapeMaterial().clipBehavior, Clip.hardEdge);
    expect(shapeMaterial().color, Colors.blue);

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('tapped', null);
    await tester.pump();

    expect(shapeMaterial().shape, expandedShape);
    expect(shapeMaterial().color, Colors.red);
    expect(tester.state(find.byType(AndroidView)), same(originalNativeState));
    expect(find.text('Child'), findsOneWidget);
  });

  testWidgets('native expansion inherits shape and clipping from its theme', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const collapsedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpansionTileTheme(
            data: ExpansionTileThemeData(
              collapsedShape: collapsedShape,
              clipBehavior: Clip.hardEdge,
            ),
            child: AdaptiveExpansionTile(
              title: Text('Section'),
              children: [Text('Child')],
            ),
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.byWidgetPredicate(
        (widget) => widget is Material && widget.shape == collapsedShape,
      ),
    );
    expect(material.clipBehavior, Clip.hardEdge);
    expect(find.byType(AndroidView), findsOneWidget);
  });

  testWidgets('custom tile border follows the expansion spring', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('tapped', null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final material = tester.widget<Material>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.animationDuration == Duration.zero,
      ),
    );
    final border = material.shape! as RoundedRectangleBorder;
    final radius = border.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    expect(radius, greaterThan(8));
    expect(radius, lessThan(24));
  });

  testWidgets('native tile removes children after collapse by default', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: false),
            child: AdaptiveExpansionTile(
              title: Text('Section'),
              children: [Text('Child')],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Child'), findsNothing);

    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('tapped', null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Child'), findsOneWidget);

    bridge.onEvent('tapped', null);
    await tester.pump();
    expect(find.text('Child'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsNothing);
  });

  testWidgets('native tile maintains children while collapsed when requested', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            maintainState: true,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    expect(find.text('Child', skipOffstage: false), findsOneWidget);
  });

  testWidgets('collapsed maintained children stay out of the semantics tree', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    final semantics = tester.ensureSemantics();
    final actionFocusNode = FocusNode();
    addTearDown(actionFocusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: const Text('Section'),
            maintainState: true,
            children: [
              Semantics(
                label: 'Hidden action',
                child: TextButton(
                  focusNode: actionFocusNode,
                  onPressed: () {},
                  child: const Text('Open details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Open details', skipOffstage: false), findsOneWidget);
    expect(find.bySemanticsLabel('Hidden action'), findsNothing);
    actionFocusNode.requestFocus();
    await tester.pump();
    expect(actionFocusNode.hasFocus, isFalse);
    semantics.dispose();
  });

  testWidgets('native expanded children honor alignment and outer padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const wideChild = Key('wide-child');
    const narrowChild = Key('narrow-child');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: AdaptiveExpansionTile(
                title: Text('Section'),
                initiallyExpanded: true,
                expandedAlignment: Alignment.centerRight,
                expandedCrossAxisAlignment: CrossAxisAlignment.end,
                childrenPadding: EdgeInsets.only(left: 12, right: 8),
                children: [
                  SizedBox(key: wideChild, width: 40, height: 20),
                  SizedBox(key: narrowChild, width: 20, height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(AdaptiveExpansionTile));
    final wide = tester.getRect(find.byKey(wideChild));
    final narrow = tester.getRect(find.byKey(narrowChild));
    expect(wide.right, tile.right - 8);
    expect(narrow.right, wide.right);
  });

  testWidgets('native expanded children inherit theme alignment and padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const childKey = Key('theme-child');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ExpansionTileTheme(
                data: ExpansionTileThemeData(
                  expandedAlignment: Alignment.centerLeft,
                  childrenPadding: EdgeInsets.only(left: 6, right: 10),
                ),
                child: AdaptiveExpansionTile(
                  title: Text('Section'),
                  initiallyExpanded: true,
                  children: [SizedBox(key: childKey, width: 40, height: 20)],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(AdaptiveExpansionTile));
    final child = tester.getRect(find.byKey(childKey));
    expect(child.left, tile.left + 6);
  });

  testWidgets('native expanded alignment resolves directional start in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    const childKey = Key('rtl-child');
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AdaptiveExpansionTile(
                  title: Text('Section'),
                  initiallyExpanded: true,
                  expandedAlignment: AlignmentDirectional.centerStart,
                  children: [SizedBox(key: childKey, width: 40, height: 20)],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(AdaptiveExpansionTile));
    final child = tester.getRect(find.byKey(childKey));
    expect(child.right, tile.right);
  });

  testWidgets('iOS expanded children honor directional alignment in RTL', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.iOS;
    const childKey = Key('ios-rtl-child');
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AdaptiveExpansionTile(
                  title: Text('Section'),
                  initiallyExpanded: true,
                  expandedAlignment: AlignmentDirectional.centerStart,
                  childrenPadding: EdgeInsets.only(left: 8, right: 12),
                  children: [SizedBox(key: childKey, width: 40, height: 20)],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(AdaptiveExpansionTile));
    final child = tester.getRect(find.byKey(childKey));
    expect(child.right, closeTo(tile.right - 12, 0.6));
  });

  testWidgets('native expansion title forwards supported text styling', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text(
              'Section',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.2,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Details',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.normal),
              textAlign: TextAlign.right,
            ),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['titleTextOptions'], {
      'fontSize': 22.0,
      'fontWeight': 700,
      'fontStyle': 'italic',
      'letterSpacing': 1.2,
      'height': 1.3,
      'maxLines': 2,
      'overflow': 'ellipsis',
    });
    expect(properties['subtitleTextOptions'], {
      'fontSize': 14.0,
      'fontStyle': 'normal',
      'textAlign': 'right',
    });
  });

  testWidgets('native expansion icons keep explicit style and descriptions', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            leading: Icon(
              Icons.home,
              size: 32,
              color: Colors.green,
              semanticLabel: 'Home section',
            ),
            trailing: Icon(
              Icons.info,
              size: 20,
              color: Colors.blue,
              semanticLabel: 'More information',
            ),
            collapsedIconColor: Colors.red,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingIconSize'], 32.0);
    expect(properties['leadingIconColor'], Colors.green.toARGB32());
    expect(properties['leadingIconSemanticLabel'], 'Home section');
    expect(properties['trailingIconSize'], 20.0);
    expect(properties['trailingIconColor'], Colors.blue.toARGB32());
    expect(properties['trailingIconSemanticLabel'], 'More information');
    expect(properties['iconColor'], Colors.red.toARGB32());
  });

  testWidgets('unsupported icon effect preserves Flutter expansion tile', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section'),
            leading: Icon(Icons.home, shadows: [Shadow(blurRadius: 2)]),
            children: [Text('Child')],
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(ExpansionTile), findsOneWidget);
  });

  testWidgets('custom Flutter font reaches the native expansion header', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text('Section', style: TextStyle(fontFamily: 'CustomBrand')),
            enabled: false,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'expansionTile');
    expect(properties['titleTextOptions'], {'fontFamily': 'CustomBrand'});
    expect(properties['enabled'], false);
  });

  testWidgets('glyph fallback list keeps the Material expansion tile', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveExpansionTile(
            title: Text(
              'Section',
              style: TextStyle(fontFamilyFallback: ['FallbackBrand']),
            ),
            enabled: false,
            children: [Text('Child')],
          ),
        ),
      ),
    );

    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(
      tester.widget<ExpansionTile>(find.byType(ExpansionTile)).enabled,
      false,
    );
    expect(find.byType(AndroidView), findsNothing);
  });
}
