class TemporaryStorage {
  final Map<String, dynamic> _storage = {};

  void setItem(String key, dynamic value) {
    _storage[key] = value;
  }

  dynamic getItem(String key) {
    return _storage[key];
  }

  void removeItem(String key) {
    _storage.remove(key);
  }

  void clear() {
    _storage.clear();
  }
}