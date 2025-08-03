import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:istudy_courses/screens/splashscreen.dart';
import 'package:istudy_courses/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iStudy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashScreen(),
      //test ui- home_screen
      //home: const CoursesScreen(),
      //test course_detail_screen
      //  home: CourseDetailScreen(),
    );
  }
}
