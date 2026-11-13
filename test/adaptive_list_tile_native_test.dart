import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:adaptive_liquid_glass/src/widgets/android/android_m3e_platform_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(PlatformInfo.resetDebugOverrides);

  testWidgets('native one-line list item uses the Compose minimum height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdaptiveListTile(title: Text('One'))),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'listTile');
    expect(tester.getSize(find.byType(AndroidView)).height, 56);
  });

  testWidgets('native two-line item reserves extra custom vertical padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdaptiveListTile(
              title: Text('Two'),
              subtitle: Text('Supporting text'),
              selected: true,
              padding: EdgeInsets.fromLTRB(24, 15, 8, 15),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'listTile');
    expect(properties['selected'], isTrue);
    expect(properties['padding'], [24.0, 15.0, 8.0, 15.0]);
    expect(tester.getSize(find.byType(AndroidView)).height, 82);
  });

  testWidgets('native list item rejects negative resolved padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Item'),
            padding: EdgeInsets.only(left: -1),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native list item rejects nonfinite resolved padding', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Item'),
            padding: EdgeInsets.only(top: double.infinity),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('native list item follows its measured wrapped height', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Announcements'),
            subtitle: Text('Long supporting text that can wrap'),
          ),
        ),
      ),
    );

    final viewState = tester.state(find.byType(AndroidView));
    final bridge = tester.widget<AndroidM3EPlatformView>(
      find.byType(AndroidM3EPlatformView),
    );
    bridge.onEvent('measuredHeight', 110.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 110);
    expect(tester.state(find.byType(AndroidView)), same(viewState));

    bridge.onEvent('measuredHeight', 72.0);
    await tester.pump();
    expect(tester.getSize(find.byType(AndroidView)).height, 72);
  });

  testWidgets('styled text keeps the native expressive list item', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text(
              'Updates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Recent changes',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'listTile');
    expect(properties['titleTextOptions'], {
      'fontSize': 18.0,
      'fontWeight': 600,
      'maxLines': 2,
      'overflow': 'ellipsis',
    });
    expect(properties['titleColor'], Colors.red.toARGB32());
    expect(properties['subtitleTextOptions'], {'fontStyle': 'italic'});
  });

  testWidgets('native list item preserves explicit icon appearance and label', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Saved'),
            leading: Icon(
              Icons.favorite,
              size: 32,
              color: Colors.red,
              semanticLabel: 'Favorite article',
            ),
            trailing: Icon(
              Icons.info,
              size: 20,
              color: Colors.blue,
              semanticLabel: 'Details',
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['leadingIconSize'], 32.0);
    expect(properties['leadingIconColor'], Colors.red.toARGB32());
    expect(properties['leadingIconSemanticLabel'], 'Favorite article');
    expect(properties['trailingIconSize'], 20.0);
    expect(properties['trailingIconColor'], Colors.blue.toARGB32());
    expect(properties['trailingIconSemanticLabel'], 'Details');
  });

  testWidgets('icon effects unsupported by Compose keep the Flutter item', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Saved'),
            leading: Icon(Icons.favorite, fill: 1),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('custom font reaches the native expressive list item', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Brand', style: TextStyle(fontFamily: 'CustomBrand')),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'listTile');
    expect(properties['titleTextOptions'], {'fontFamily': 'CustomBrand'});
  });

  testWidgets('explicit font variations reach the native text slot', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text(
              'Brand',
              style: TextStyle(
                fontFamily: 'CustomBrand',
                fontVariations: [
                  FontVariation('wght', 650),
                  FontVariation('wdth', 85),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['titleTextOptions'], {
      'fontFamily': 'CustomBrand',
      'fontVariations': [
        {'axis': 'wght', 'value': 650.0},
        {'axis': 'wdth', 'value': 85.0},
      ],
    });
  });

  testWidgets('unqualified font variations retain Flutter rendering', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text(
              'Brand',
              style: TextStyle(fontVariations: [FontVariation('wght', 650)]),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AndroidView), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('generic serif font keeps the native expressive list item', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Editorial', style: TextStyle(fontFamily: 'serif')),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['component'], 'listTile');
    expect(properties['titleTextOptions'], {'fontFamily': 'serif'});
  });

  testWidgets('OpenType features keep the native expressive list item', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text(
              '12:30',
              style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['titleTextOptions'], {'fontFeatureSettings': "'tnum' 1"});
  });

  testWidgets('segmented item forwards its position and reserves native gap', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('First'),
            androidSegmentIndex: 0,
            androidSegmentCount: 2,
          ),
        ),
      ),
    );

    final view = tester.widget<AndroidView>(find.byType(AndroidView));
    final properties = view.creationParams! as Map<Object?, Object?>;
    expect(properties['segmentIndex'], 0);
    expect(properties['segmentCount'], 2);
    expect(tester.getSize(find.byType(AndroidView)).height, 58);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(
            title: Text('Last'),
            androidSegmentIndex: 1,
            androidSegmentCount: 2,
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AndroidView)).height, 56);
  });

  testWidgets('incomplete segmented position is rejected on Android', (
    tester,
  ) async {
    PlatformInfo.debugPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveListTile(title: Text('First'), androidSegmentIndex: 0),
        ),
      ),
    );

    expect(tester.takeException(), isFlutterError);
  });
}
