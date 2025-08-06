import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/helpers/course_item_type_enum.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/course_item.dart';
import 'package:istudy_courses/models/course_lesson.dart';
import 'package:istudy_courses/models/users.dart';
import 'package:istudy_courses/models/videos.dart';
import 'package:istudy_courses/screens/video_play_screen.dart';
import 'package:istudy_courses/services/api_service.dart';
import 'package:istudy_courses/services/course_enrollment_service.dart';
import 'package:istudy_courses/services/user_service.dart';
import 'package:istudy_courses/theme/colors.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<Courses> _course;
  late Future<List<Videos>> _videos;
  bool isEnrolled = false;
  bool isEnrolling = false;
  Users? _currentUser;
  List<CourseLesson> sampleLessons = [];
  // final ApiService _apiService = ApiService();
  final CourseEnrollmentService _courseService = CourseEnrollmentService();
  final UserService _userService = UserService();
  @override
  void initState() {
    super.initState();
    _course = ApiService.getCourseById(widget.courseId);
    _videos = ApiService.fetchVideosbyCourseId(widget.courseId);
    _generateSampleLessons();
    _reloadUserData();
  }

  void _generateSampleLessons() {
    sampleLessons = [
      CourseLesson(
        id: "1",
        title: 'Lesson 1: Introduction',
        isExpanded: false,
        items: [
          CourseItem(
            id: "1",
            type: CourseItemType.video,
            title: 'Welcome to the course',
            isCompleted: false,
          ),
          CourseItem(
            id: "2",
            type: CourseItemType.document,
            title: 'Course Overview PDF',
            isCompleted: false,
          ),
        ],
      ),
      CourseLesson(
        id: "2",
        title: 'Lesson 2: Basics',
        isExpanded: false,
        items: [
          CourseItem(
            id: "3",
            type: CourseItemType.video,
            title: 'Basic Concepts',
            isCompleted: true,
          ),
          CourseItem(
            id: "4",
            type: CourseItemType.quiz,
            title: 'Quiz 1',
            isCompleted: false,
          ),
        ],
      ),
    ];
  }

  Future<void> _enrollCourse(Courses course) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đăng ký khóa học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isEnrolling = true;
    });

    try {
      bool success = await _courseService.enrollCourse(course.id);

      if (success) {
        await _reloadUserData();
        setState(() {
          isEnrolled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng ký khóa học: ${course.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đăng ký khóa học. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Enrollment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng ký khóa học: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isEnrolling = false;
      });
    }
  }

  Future<void> _reloadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
        isEnrolled = user?.enrolledCourses.contains(widget.courseId) ?? false;
      });
    } catch (e) {
      print('Error reloading user data: $e');
    }
  }

  IconData _getIconForType(CourseItemType type) {
    switch (type) {
      case CourseItemType.video:
        return Icons.play_circle_outline;
      case CourseItemType.quiz:
        return Icons.quiz;
      case CourseItemType.exercise:
        return Icons.assignment;
      case CourseItemType.document:
        return Icons.description;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: FutureBuilder<Courses>(
        future: _course,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load course'));
          }

          final course = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  course.img ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 80),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.desc ?? '',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:
                            isEnrolled || isEnrolling
                                ? null
                                : () async {
                                  await _enrollCourse(course);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEnrolled ? Colors.grey : AppColors.purple,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child:
                            isEnrolling
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  isEnrolled ? 'Đã đăng ký' : 'Đăng ký ngay',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      const Text(
                        'Course Lessons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...sampleLessons.map((lesson) {
                        return ExpansionTile(
                          title: Text(lesson.title),
                          initiallyExpanded: lesson.isExpanded,
                          children:
                              lesson.items.map((item) {
                                return ListTile(
                                  leading: Icon(_getIconForType(item.type)),
                                  title: Text(item.title),
                                  trailing:
                                      item.isCompleted
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : null,
                                  onTap: () {
                                    // TODO: Navigate to lesson video or content
                                  },
                                );
                              }).toList(),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      const Divider(height: 30, thickness: 1),
                      const Text(
                        'Videos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Videos>>(
                        future: _videos,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Failed to load videos');
                          }

                          final videos = snapshot.data!;
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: videos.length,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              return ListTile(
                                leading: Image.network(
                                  video.thumbnail,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(video.title),
                                subtitle: Text("Thời lượng: ${video.duration}"),
                                trailing:
                                    video.isWatched
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                        : const Icon(Icons.play_circle_outline),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => VideoPlayerScreen(
                                            videoList:
                                                videos
                                                    .map((v) => v.videoUrl)
                                                    .toList(),
                                            lessons: sampleLessons,
                                            initialIndex: index,
                                            onVideoWatched: (watchedIndex) {
                                              setState(() {
                                                videos[watchedIndex].isWatched =
                                                    true;
                                              });
                                            },
                                          ),
                                    ),
                                  );
                                },

                                // return ListTile(
                                //   video: video,
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder:
                                //             (context) => VideoPlayerScreen(
                                //               videoList:
                                //                   videos
                                //                       .map((v) => v.videoUrl)
                                //                       .toList(),
                                //               lessons: sampleLessons,
                                //               initialIndex: index,
                                //               onVideoWatched: (watchedIndex) {
                                //                 setState(() {
                                //                   videos[watchedIndex].isWatched =
                                //                       true;
                                //                 });
                                //               },
                                //             ),
                                //       ),
                                //     );
                                //   },
                                // );
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
