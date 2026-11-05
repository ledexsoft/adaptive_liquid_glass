import 'package:adaptive_liquid_glass/adaptive_liquid_glass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSplitButtonSize', () {
    test('matches the five official Material 3 Expressive heights', () {
      expect(
        AdaptiveSplitButtonSize.values
            .map((size) => size.containerHeight)
            .toList(),
        [32, 40, 56, 96, 136],
      );
    });

    test('keeps extra small and small touch targets at least 48 dp tall', () {
      expect(
        AdaptiveSplitButtonSize.values
            .map((size) => size.minimumTouchTargetHeight)
            .toList(),
        [48, 48, 56, 96, 136],
      );
    });
  });

  test('defaults to the recommended small size', () {
    final button = AdaptiveSplitButton<int>(
      items: const [AdaptiveSplitButtonItem(value: 1, label: 'More')],
      label: 'Run',
      onPressed: () {},
    );

    expect(button.size, AdaptiveSplitButtonSize.small);
  });
}
