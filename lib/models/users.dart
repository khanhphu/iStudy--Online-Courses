import 'package:firebase_auth/firebase_auth.dart';

class Users {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? bio; //gioi thieu ban than
  final List<int> enrolledCourses;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.enrolledCourses = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth']?.toDate(),
      bio: map['bio'],
      enrolledCourses: List<int>.from(map['enrolledCourses'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'bio': bio,
      'enrolledCourses': enrolledCourses,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Users copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    List<int>? enrolledCourses,
  }) {
    return Users(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
