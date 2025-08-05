import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:istudy_courses/models/users.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //lay thong tin nguoi dung hien tai
  Future<Users?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return Users.fromMap(doc.data()!);
      } else {
        //tao user moi neu chua ton tai
        final newUser = Users(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print('error getting current user:$e');
      return null;
    }
  }

  //cap nhat thong tin nguoi dung
  Future<bool> updateUser(Users user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  //dang ky khoa hoc
  Future<bool> enrollCourse(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await _firestore.collection('users').doc(user.uid).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error enrolling course:$e');
      return false;
    }
  }
}
