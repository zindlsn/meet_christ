abstract class DatabaseService2<K, T> {
  Future<List<T>> getAll();
  Future<List<T>?> getAllById(K id);
  Future<T?> getById(K id);
  Future<bool> update(T data);
  Future<T> create(T data);
  Future<List<T>> createAll(List<T> allData);
}