import 'package:istudy_courses/helpers/course_item_type_enum.dart';

class CourseItem {
  final String id;
  final String title;
  final CourseItemType type;
  final Duration? duration;
  bool isCompleted;
  final bool isLocked;

  CourseItem({
    required this.id,
    required this.title,
    required this.type,
    this.duration,
    this.isCompleted = false,
    this.isLocked = false,
  });
}

extension CourseItemExtension on CourseItem {
  String? get videoUrl {
    // Bạn có thể thêm field videoUrl vào model CourseItem
    // Hoặc return URL dựa trên id hoặc logic khác
    switch (id) {
      case 'video1':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
      case 'video2':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4';
      case 'video3':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
      case 'video4':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4';
      case 'video5':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
      case 'video6':
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4';
      default:
        return null;
    }
  }
}
