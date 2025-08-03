class Videos {
  final int id;
  final int courseId;
  final String title;
  final String duration;
  final String thumbnail;
  final bool isWatched;
  final bool isLocked;
  final String videoUrl;

  Videos({
    required this.id,
    required this.courseId,
    required this.title,
    required this.duration,
    required this.thumbnail,
    this.isWatched = false,
    this.isLocked = false,
    required this.videoUrl,
  });
  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      title: json['title']?.toString() ?? 'Untitled Video',
      duration: json['duration']?.toString() ?? '0:00',
      thumbnail: json['thumbnail']?.toString() ?? '',
      isWatched: json['isWatched'] ?? false,
      isLocked: json['isLocked'] ?? false,
      videoUrl: json['videoUrl']?.toString() ?? '',
    );
  }
}
