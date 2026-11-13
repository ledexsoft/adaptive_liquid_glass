import 'dart:collection';

/// Gives each position of a repeated object a distinct stable native ID.
///
/// A single object can be reused in a widget's item list, including through
/// canonical `const` instances. Its first, second, and later occurrences keep
/// their own IDs across rebuilds. Identical occurrences are distinguished by
/// their order because the object alone cannot identify them further.
class NativeOccurrenceIds<T extends Object> {
  final Expando<List<int>> _idsByObject = Expando<List<int>>('nativeItemIds');
  int _nextId = 0;

  List<int> forItems(Iterable<T> items) {
    final occurrences = HashMap<T, int>.identity();
    final result = <int>[];
    for (final item in items) {
      final occurrence = occurrences.update(
        item,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      final ids = _idsByObject[item] ??= <int>[];
      while (ids.length <= occurrence) {
        ids.add(++_nextId);
      }
      result.add(ids[occurrence]);
    }
    return result;
  }
}
