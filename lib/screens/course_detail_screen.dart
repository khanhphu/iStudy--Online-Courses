import 'package:flutter/material.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/videos.dart';
import 'package:istudy_courses/services/api_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  State<StatefulWidget> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Courses? course;
  List<Videos> videos = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool isEnrolled = false;
  int selectedTab = 0; // 0: Overview, 1: Videos

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCourseData();
  }

  Future<void> fetchCourseData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      print('Fetching course with ID: ${widget.courseId}');

      // Fetch course and videos in parallel
      final results = await Future.wait([
        ApiService.getCourseById(widget.courseId),
        ApiService.fetchVideosbyCourseId(widget.courseId),
      ]);

      final fetchedCourse = results[0] as Courses?;
      final fetchedVideos = results[1] as List<Videos>;

      if (fetchedCourse != null) {
        setState(() {
          course = fetchedCourse;
          videos = fetchedVideos;
          isLoading = false;
        });
        print('Course loaded successfully: ${course!.name}');
        print('Videos loaded: ${videos.length} videos');
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Course not found';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching course data: $e');
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF6C5CE7),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (hasError || course == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF6C5CE7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Failed to load course',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchCourseData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6C5CE7),
      body: CustomScrollView(
        slivers: [
          // App Bar with course image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF6C5CE7),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child:
                    course!.img.isNotEmpty
                        ? Image.network(
                          course!.img,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF5A4FCF),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 64,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: const Color(0xFF5A4FCF),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
              ),
            ),
          ),

          // Course content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Tab selector
                  Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color:
                                    selectedTab == 0
                                        ? const Color(0xFF6C5CE7)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Overview',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      selectedTab == 0
                                          ? Colors.white
                                          : const Color(0xFF718096),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color:
                                    selectedTab == 1
                                        ? const Color(0xFF6C5CE7)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Videos (${videos.length})',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      selectedTab == 1
                                          ? Colors.white
                                          : const Color(0xFF718096),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab content
                  selectedTab == 0 ? _buildOverviewTab() : _buildVideosTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title and category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              course!.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            course!.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),

          // Text(
          //   'by ${course!.instructor}',
          //   style: const TextStyle(fontSize: 16, color: Color(0xFF718096)),
          // ),
          const SizedBox(height: 24),

          // Course stats
          Row(
            children: [
              _buildStatItem(Icons.star, "4", Colors.amber),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.people,
                '${course!.members}',
                const Color(0xFF6C5CE7),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.access_time,
                course!.desc,
                const Color(0xFF48BB78),
              ),
              const SizedBox(width: 24),
              // _buildStatItem(
              //   Icons.signal_cellular_alt,
              //   course!.level,
              //   const Color(0xFFED8936),
              // ),
            ],
          ),
          const SizedBox(height: 32),

          // Description
          const Text(
            'About This Course',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course!.desc,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),

          // // Topics covered
          // if (course!.topics.isNotEmpty) ...[
          //   const Text(
          //     'What You\'ll Learn',
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //       color: Color(0xFF2D3748),
          //     ),
          //   ),
          //   const SizedBox(height: 16),
          //   ...course!.topics
          //       .map(
          //         (topic) => Padding(
          //           padding: const EdgeInsets.only(bottom: 12),
          //           child: Row(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Container(
          //                 margin: const EdgeInsets.only(top: 6),
          //                 width: 8,
          //                 height: 8,
          //                 decoration: const BoxDecoration(
          //                   color: Color(0xFF6C5CE7),
          //                   shape: BoxShape.circle,
          //                 ),
          //               ),
          //               const SizedBox(width: 16),
          //               Expanded(
          //                 child: Text(
          //                   topic,
          //                   style: const TextStyle(
          //                     fontSize: 16,
          //                     color: Color(0xFF4A5568),
          //                     height: 1.5,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       )
          //       .toList(),
          //   const SizedBox(height: 32),
          // ],

          // Price and enroll button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course!.price > 0
                          ? '\$${course!.price.toStringAsFixed(0)}'
                          : 'Free',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEnrolled = !isEnrolled;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEnrolled
                            ? const Color(0xFF48BB78)
                            : const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEnrolled ? 'Enrolled ✓' : 'Enroll Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    if (videos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No videos available for this course',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final watchedCount = videos.where((v) => v.isWatched).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.1),
                  const Color(0xFF6C5CE7).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$watchedCount of ${videos.length} videos',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: videos.isNotEmpty ? watchedCount / videos.length : 0,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${videos.isNotEmpty ? ((watchedCount / videos.length) * 100).round() : 0}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Videos list
          const Text(
            'Course Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          ...videos.asMap().entries.map((entry) {
            final index = entry.key;
            final video = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      video.isWatched
                          ? const Color(0xFF48BB78).withOpacity(0.3)
                          : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      ),
                      child:
                          video.thumbnail.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  video.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.play_circle_fill,
                                      color: Color(0xFF6C5CE7),
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.play_circle_fill,
                                color: Color(0xFF6C5CE7),
                                size: 24,
                              ),
                    ),
                    if (video.isLocked)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFED8936),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    if (video.isWatched)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF48BB78),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        video.isLocked
                            ? const Color(0xFF718096)
                            : const Color(0xFF2D3748),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    video.duration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
                trailing:
                    video.isLocked
                        ? const Icon(Icons.lock, color: Color(0xFFED8936))
                        : const Icon(
                          Icons.play_arrow,
                          color: Color(0xFF6C5CE7),
                        ),
                onTap:
                    video.isLocked
                        ? null
                        : () {
                          // Handle video play
                          print('Playing video: ${video.title}');
                          // You can navigate to a video player screen here
                        },
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }
}
