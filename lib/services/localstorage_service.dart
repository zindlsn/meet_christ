import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const storage = FlutterSecureStorage();
  static Future<void> saveData<T>(String key, T? value) async {
    if (value is bool) {
      await storage.write(key: key, value: value.toString());
      return;
    }
    await storage.write(key: key, value: value as String?);
  }

  static Future<void> saveDateTime(String key, DateTime? value) async {
    await storage.write(key: key, value: value?.toIso8601String());
  }

  Future<T?> getFromDisk<T>(String key) async {
    final rawValue = await storage.read(key: key);

    if (rawValue == null) return null;

    if (T == String) {
      return rawValue as T;
    } else if (T == bool) {
      // Convert 'true' or 'false' strings to bool
      return (rawValue.toLowerCase() == 'true') as T;
    } else if (T == int) {
      return int.tryParse(rawValue) as T?;
    } else if (T == double) {
      return double.tryParse(rawValue) as T?;
    } else {
      // For complex types, try to decode JSON string
      try {} catch (e) {
        // fallback or throw
        throw Exception('Error decoding value from storage: $e');
      }
    }
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
  static const String rememberMe = "remember_me";
  static const String password = "password";
  static const String loggedInUserId = "logged_in_user_id";
}
