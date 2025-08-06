import 'package:istudy_courses/models/course_item.dart';

class CourseLesson {
  final String id;
  final String title;
  final List<CourseItem> items;
  final bool isExpanded;

  CourseLesson({
    required this.id,
    required this.title,
    required this.items,
    this.isExpanded = false,
  });
}
