class _CacheEntry {
  _CacheEntry(this.value, this.expiresAt);

  final Object? value;
  final DateTime expiresAt;
}

class TtlCache {
  TtlCache({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<String, _CacheEntry> _entries = {};

  T? get<T>(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (!_clock().isBefore(entry.expiresAt)) {
      _entries.remove(key);
      return null;
    }
    final value = entry.value;
    if (value is T) return value;
    return null;
  }

  void set(String key, Object? value, Duration ttl) {
    _entries[key] = _CacheEntry(value, _clock().add(ttl));
  }

  void clear() => _entries.clear();
}

Future<T> remember<T>({
  required TtlCache cache,
  required String key,
  required Duration ttl,
  required bool force,
  required Future<T> Function() load,
}) async {
  if (!force) {
    final cached = cache.get<T>(key);
    if (cached != null) return cached;
  }
  final value = await load();
  cache.set(key, value, ttl);
  return value;
}
