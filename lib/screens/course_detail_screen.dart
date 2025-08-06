import 'package:flutter/material.dart';
import 'package:istudy_courses/helpers/course_item_type_enum.dart';
import 'package:istudy_courses/models/course_item.dart';
import 'package:istudy_courses/models/course_lesson.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/videos.dart';
import 'package:istudy_courses/screens/video_play_screen.dart';
import 'package:istudy_courses/services/api_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<Courses> _course;
  late Future<List<Videos>> _videos;
  late List<CourseLesson> sampleLessons = [];

  @override
  void initState() {
    super.initState();
    _course = ApiService.getCourseById(widget.courseId);
    _videos = ApiService.fetchVideosbyCourseId(widget.courseId);
    //khoi tao lessons
    // Khởi tạo sample data trong initState
    sampleLessons = [
      CourseLesson(
        id: 'lesson1',
        title: 'Bài 1: Tổng quan khóa học',
        isExpanded: true, // Mở rộng để dễ thấy items
        items: [
          CourseItem(
            id: 'video1',
            title: 'Video 1: Giới thiệu khóa học',
            type: CourseItemType.video,
            duration: Duration(minutes: 15, seconds: 30),
            isCompleted: true,
          ),
          CourseItem(
            id: 'video2',
            title: 'Video 2: Thiết lập môi trường',
            type: CourseItemType.video,
            duration: Duration(minutes: 8, seconds: 45),
            isCompleted: false,
          ),
          CourseItem(
            id: 'exercise1',
            title: 'Bài tập 1: Tạo project đầu tiên',
            type: CourseItemType.exercise,
            isCompleted: false,
          ),
        ],
      ),
      CourseLesson(
        id: 'lesson2',
        title: 'Bài 2: HTML cơ bản',
        isExpanded: false,
        items: [
          CourseItem(
            id: 'video3',
            title: 'Video 1: Cấu trúc HTML',
            type: CourseItemType.video,
            duration: Duration(minutes: 12, seconds: 20),
            isCompleted: false,
          ),
          CourseItem(
            id: 'video4',
            title: 'Video 2: Thẻ HTML phổ biến',
            type: CourseItemType.video,
            duration: Duration(minutes: 18, seconds: 15),
            isCompleted: false,
          ),
          CourseItem(
            id: 'quiz1',
            title: 'Quiz: Kiểm tra kiến thức HTML',
            type: CourseItemType.quiz,
            isCompleted: false,
          ),
          CourseItem(
            id: 'exercise2',
            title: 'Bài tập 2: Tạo trang web đơn giản',
            type: CourseItemType.exercise,
            isCompleted: false,
          ),
        ],
      ),
      CourseLesson(
        id: 'lesson3',
        title: 'Bài 3: CSS Styling',
        isExpanded: false,
        items: [
          CourseItem(
            id: 'video5',
            title: 'Video 1: CSS Selectors',
            type: CourseItemType.video,
            duration: Duration(minutes: 14, seconds: 30),
            isCompleted: false,
            isLocked: true,
          ),
          CourseItem(
            id: 'video6',
            title: 'Video 2: Layout với Flexbox',
            type: CourseItemType.video,
            duration: Duration(minutes: 22, seconds: 45),
            isCompleted: false,
            isLocked: true,
          ),
          CourseItem(
            id: 'document1',
            title: 'Tài liệu: CSS Cheat Sheet',
            type: CourseItemType.document,
            isCompleted: false,
            isLocked: true,
          ),
        ],
      ),
    ];

    print(
      'Sample lessons initialized: ${sampleLessons.length} lessons',
    ); // Debug
  }

  void markVideoAsWatched(int videoId) {
    setState(() {
      _videos = _videos.then((videos) {
        return videos.map((video) {
          if (video.id == videoId) {
            return video.copyWith(isWatched: true);
          }
          return video;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết khoá học")),
      body: FutureBuilder<Courses>(
        future: _course,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final course = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(course.img),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Videos>>(
                    future: _videos,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final videos = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: videos.length,
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
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text("Lỗi: ${snapshot.error}");
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Lỗi: ${snapshot.error}");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
