import 'package:flutter/material.dart';
import 'package:istudy_courses/screens/courses_screen.dart';
import 'package:istudy_courses/screens/login_screen.dart';
import 'package:istudy_courses/screens/main_screen.dart';
import 'package:istudy_courses/screens/profile_screen.dart';
import 'package:istudy_courses/screens/register_screen.dart';
import 'package:istudy_courses/screens/splash_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String registeredCourses = '/registered-courses';
  static const String splash = '/splash';
  static const String courses = '/courses';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => HomeScreen(),
    login: (context) => const LoginPage(),
    profile: (context) => const ProfileScreen(),
    registeredCourses: (context) => const RegisterPage(),
    courses: (context) => const CoursesScreen(),
  };
}
