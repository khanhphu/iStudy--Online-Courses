import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  static String? currentUID;
  static String _prefix(String key) => '${currentUID ?? "guest"}_$key';

  static String? get email => _box.read(_prefix('email'));
  static String? get password => _box.read(_prefix('password'));
  //onboarding
  static bool get hasSeenOnboarding => _box.read('hasSeenOnboarding') ?? false;
  static void setOnboardingSeen() => _box.write('hasSeenOnboarding', true);

  //remember me
  static bool get isRemembered => _box.read(_prefix('remember_me')) ?? false;
  static void setRememberMe(bool value) =>
      _box.write(_prefix('remember_me'), value);

  static void saveCredentials(String email, String password) {
    _box.write(_prefix('email'), email);
    _box.write(_prefix('password'), password);
  }

  static void clearCredentials() {
    _box.remove(_prefix('email'));
    _box.remove(_prefix('password'));
    setRememberMe(false);
  }

  void saveUserData(String uid, Map<String, dynamic> data) {
    _box.write(uid, data);
  }

  Map<String, dynamic>? getUserData(String uid) {
    return _box.read(uid);
  }

  void saveQuizResult(String uid, Map<String, dynamic> result) {
    final existing = _box.read(uid) ?? {};
    existing['quizResults'] = result;
    _box.write(uid, existing);
  }

  Map<String, dynamic>? getQuizResult(String uid) {
    final data = _box.read(uid);
    return data != null ? data['quizResults'] : null;
  }

  void clearUser(String uid) {
    _box.remove(uid);
  }

  //reset all user data
  static Future<void> wipeOut() async {
    for (var key in _box.getKeys()) {
      if (key is String && key.startsWith(currentUID ?? "guest")) {
        await _box.remove(key);
      }
    }
  }

  static Future<void> resetAll() async {
    await _box.erase(); // Xoá toàn bộ dữ liệu GetStorage
  }
}
