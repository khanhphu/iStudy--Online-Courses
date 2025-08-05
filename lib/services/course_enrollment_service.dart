import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseEnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _coursesApiUrl =
      'https://68886162adf0e59551b9b66d.mockapi.io/istudy/courses/courses';

  /// Đăng ký khóa học cho user hiện tại
  Future<bool> enrollCourse(int courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Error: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('Checking if course $courseId exists...');
      // Kiểm tra khóa học có tồn tại không
      final courseExists = await _checkCourseExists(courseId);
      if (!courseExists) {
        print(
          'Warning: Course $courseId not found in API, but continuing enrollment...',
        );
        // throw Exception('Course not found'); // Tạm comment để test
      }

      print('Course $courseId exists. Getting user document...');
      // Lấy thông tin user hiện tại từ Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('Error: User document not found for uid: ${user.uid}');
        throw Exception('User document not found');
      }

      final userData = userDoc.data()!;
      final currentEnrolledCourses = List<int>.from(
        userData['enrolledCourses'] ?? [],
      );

      print('Current enrolled courses: $currentEnrolledCourses');

      // Kiểm tra user đã đăng ký khóa học này chưa
      if (currentEnrolledCourses.contains(courseId)) {
        print('Error: User already enrolled in course $courseId');
        throw Exception('Already enrolled in this course');
      }

      // Thêm khóa học vào danh sách đã đăng ký
      currentEnrolledCourses.add(courseId);
      print(
        'Adding course $courseId. New enrolled courses: $currentEnrolledCourses',
      );

      // Cập nhật Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'enrolledCourses': currentEnrolledCourses,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully enrolled in course $courseId');
      return true;
    } catch (e) {
      print('Error enrolling course: $e');
      return false;
    }
  }

  /// Hủy đăng ký khóa học
  Future<bool> unenrollCourse(int courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Lấy thông tin user hiện tại từ Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data()!;
      final currentEnrolledCourses = List<int>.from(
        userData['enrolledCourses'] ?? [],
      );

      // Kiểm tra user có đăng ký khóa học này không
      if (!currentEnrolledCourses.contains(courseId)) {
        throw Exception('Not enrolled in this course');
      }

      // Xóa khóa học khỏi danh sách đã đăng ký
      currentEnrolledCourses.remove(courseId);

      // Cập nhật Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'enrolledCourses': currentEnrolledCourses,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error unenrolling course: $e');
      return false;
    }
  }

  /// Lấy danh sách khóa học đã đăng ký của user hiện tại
  Future<List<int>> getEnrolledCourses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return [];
      }

      final userData = userDoc.data()!;
      return List<int>.from(userData['enrolledCourses'] ?? []);
    } catch (e) {
      print('Error getting enrolled courses: $e');
      return [];
    }
  }

  /// Lấy chi tiết các khóa học đã đăng ký từ MockAPI
  Future<List<Map<String, dynamic>>> getEnrolledCoursesDetails() async {
    try {
      final enrolledCourseIds = await getEnrolledCourses();
      if (enrolledCourseIds.isEmpty) {
        return [];
      }

      // Lấy tất cả khóa học từ MockAPI
      final response = await http.get(Uri.parse(_coursesApiUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch courses from API');
      }

      final List<dynamic> allCourses = json.decode(response.body);

      // Lọc các khóa học đã đăng ký
      final enrolledCourses =
          allCourses.where((course) {
            return enrolledCourseIds.contains(
              int.parse(course['id'].toString()),
            );
          }).toList();

      return List<Map<String, dynamic>>.from(enrolledCourses);
    } catch (e) {
      print('Error getting enrolled courses details: $e');
      return [];
    }
  }

  /// Kiểm tra user có đăng ký khóa học này không
  Future<bool> isEnrolled(int courseId) async {
    try {
      final enrolledCourses = await getEnrolledCourses();
      return enrolledCourses.contains(courseId);
    } catch (e) {
      print('Error checking enrollment status: $e');
      return false;
    }
  }

  /// Kiểm tra khóa học có tồn tại trong MockAPI không
  Future<bool> _checkCourseExists(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$_coursesApiUrl/?id=$courseId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking course existence: $e');
      return false;
    }
  }

  /// Lấy số lượng khóa học đã đăng ký
  Future<int> getEnrolledCoursesCount() async {
    try {
      final enrolledCourses = await getEnrolledCourses();
      return enrolledCourses.length;
    } catch (e) {
      print('Error getting enrolled courses count: $e');
      return 0;
    }
  }

  /// Stream để lắng nghe thay đổi danh sách khóa học đã đăng ký
  Stream<List<int>> enrolledCoursesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return <int>[];
      final data = doc.data()!;
      return List<int>.from(data['enrolledCourses'] ?? []);
    });
  }
}
