import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _course = ApiService.getCourseById(widget.courseId);
    _videos = ApiService.fetchVideosbyCourseId(widget.courseId);
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
