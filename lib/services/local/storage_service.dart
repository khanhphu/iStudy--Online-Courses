import 'package:get_storage/get_storage.dart';

class StorageService {
  final _box = GetStorage();

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
}
