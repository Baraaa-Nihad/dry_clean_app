// lib/extensions/list_extensions.dart

extension IterableExtensions<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keySelector) {
    final Map<K, List<E>> map = {};
    for (var element in this) {
      final key = keySelector(element);
      if (map.containsKey(key)) {
        map[key]!.add(element);
      } else {
        map[key] = [element];
      }
    }
    return map;
  }
}
