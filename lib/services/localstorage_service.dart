import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const storage = FlutterSecureStorage();
  static Future<void> saveData<T>(String key, T? value) async {
    await storage.write(key: key, value: value as String?);
  }

  static Future<void> saveDateTime(String key, DateTime? value) async {
    await storage.write(key: key, value: value?.toIso8601String());
  }

  Future<T> getFromDisk<T>(String key) async {
    return await storage.read(key: key) as T;
  }

  Future<DateTime?> getDateTimeFromDisk(String key) async {
    final dateStr = await storage.read(key: key);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}

class LocalStorageKeys {
  static const String firstName = "firstname";
  static const String lastName = "lastname";
  static const String birthDate = "birthday";
  static const String email = "email";
}
