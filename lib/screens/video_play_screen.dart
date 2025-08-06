import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istudy_courses/controllers/quiz_controller.dart';

import 'package:istudy_courses/helpers/course_item_type_enum.dart';
import 'package:istudy_courses/models/course_item.dart';
import 'package:istudy_courses/models/course_lesson.dart';
import 'package:istudy_courses/screens/quiz_screen.dart';
import 'package:istudy_courses/theme/colors.dart';
import 'package:istudy_courses/widgets/course_sidebar.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> videoList;
  final List<CourseLesson> lessons;
  final int initialIndex;
  final void Function(int index)? onVideoWatched;

  const VideoPlayerScreen({
    super.key,
    required this.videoList,
    required this.lessons,
    required this.initialIndex,
    this.onVideoWatched,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  // Video Player Controllers
  VideoPlayerController? _videoController;
  late AnimationController _controlsAnimationController;
  late AnimationController _playPauseAnimationController;
  late TabController _tabController;

  // State Variables
  int _currentVideoIndex = 0;
  String? _currentItemId;
  CourseItem? _currentItem;
  bool _isVideoInitialized = false;
  bool _showSidebar = false; // Bắt đầu với sidebar ẩn
  bool _isLoading = false;
  bool _showControls = true;
  bool _showVolumeSlider = false;
  bool _isBuffering = false;
  bool _isDisposed = false;
  //test nội dung cấu trúc course lesson

  // Video Properties
  double _volume = 1.0;
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  // Timer for auto-hiding controls
  Timer? _controlsTimer;
  //uid
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeVideoPlayer(); // Load video ngay khi khởi tạo
    print("widget lessons ${widget.lessons.length}");
    // Khởi tạo sample data trong initState
  }

  void _initializeControllers() {
    _currentVideoIndex = widget.initialIndex.clamp(
      0,
      widget.videoList.length - 1,
    );
    _tabController = TabController(length: 2, vsync: this);

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..value = 1.0;

    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Khởi tạo currentItem từ video đầu tiên
    if (widget.lessons.isNotEmpty && widget.lessons.first.items.isNotEmpty) {
      final firstVideoItem = widget.lessons.first.items.firstWhere(
        (item) => item.type == CourseItemType.video,
        orElse: () => widget.lessons.first.items.first,
      );
      _currentItem = firstVideoItem;
      _currentItemId = firstVideoItem.id;
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoList.isEmpty || _isDisposed) return;

    setState(() {
      _isLoading = true;
      _isBuffering = true;
    });

    try {
      final videoUrl = widget.videoList[_currentVideoIndex];
      await _setupVideoController(videoUrl);
    } catch (error) {
      if (!_isDisposed) {
        _handleVideoError(error);
      }
    }
  }

  Future<void> _initializeVideoFromItem(String videoUrl) async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _isVideoInitialized = false;
    });

    try {
      await _setupVideoController(videoUrl);
      if (!_isDisposed) {
        setState(() {
          _isVideoInitialized = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!_isDisposed) {
        _handleVideoError(error);
        _showErrorSnackBar('Lỗi tải video: $error');
      }
    }
  }

  Future<void> _setupVideoController(String videoUrl) async {
    if (_isDisposed) return;

    // Dispose previous controller if exists
    await _disposeVideoController();

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoController!.initialize();

      if (_isDisposed) {
        await _videoController!.dispose();
        return;
      }

      setState(() {
        _videoDuration = _videoController!.value.duration;
        _isBuffering = false;
        _isVideoInitialized = true;
        _isLoading = false;
      });

      _videoController!.addListener(_updateVideoPosition);
      _videoController!.setVolume(_volume);
      _videoController!.play();
      _playPauseAnimationController.forward();
      _startControlsTimer();
    } catch (e) {
      if (!_isDisposed) {
        _handleVideoError(e);
      }
    }
  }

  void _updateVideoPosition() {
    if (_isDisposed || _videoController == null || !mounted) return;

    final value = _videoController!.value;
    final position = value.position;
    final duration = value.duration;
    final isEnded = position >= duration && duration > Duration.zero;
    final isBuffering = value.isBuffering;

    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isBuffering = isBuffering;
      });
    }

    if (isEnded && widget.onVideoWatched != null) {
      widget.onVideoWatched!(_currentVideoIndex);
    }
  }

  void _handleVideoError(dynamic error) {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isLoading = false;
      _isVideoInitialized = false;
      _isBuffering = false;
    });
    debugPrint('Error initializing video: $error');
  }

  void _showErrorSnackBar(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Video Control Methods
  void _togglePlayPause() {
    if (_videoController?.value.isInitialized != true || _isDisposed) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _playPauseAnimationController.reverse();
      } else {
        _videoController!.play();
        _playPauseAnimationController.forward();
      }
    });
    _showControlsTemporary();
  }

  void _playPreviousVideo() {
    if (_currentVideoIndex > 0) {
      _changeVideo(_currentVideoIndex - 1);
    }
  }

  void _playNextVideo() {
    if (_currentVideoIndex < widget.videoList.length - 1) {
      _changeVideo(_currentVideoIndex + 1);
    }
  }

  Future<void> _changeVideo(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.videoList.length || _isDisposed)
      return;

    await _disposeVideoController();
    setState(() => _currentVideoIndex = newIndex);
    await _initializeVideoPlayer();
  }

  // UI Control Methods
  void _showControlsTemporary() {
    if (_isDisposed || !mounted) return;

    setState(() => _showControls = true);
    _controlsAnimationController.forward();
    _startControlsTimer();
  }

  void _startControlsTimer() {
    if (_isDisposed || !mounted) return;

    _controlsTimer?.cancel();
    _controlsAnimationController.forward();

    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (!_isDisposed &&
          mounted &&
          _videoController?.value.isInitialized == true &&
          _videoController!.value.isPlaying) {
        _controlsAnimationController.reverse().then((_) {
          if (!_isDisposed && mounted) {
            setState(() => _showControls = false);
          }
        });
      }
    });
  }

  void _toggleSidebar() {
    if (!_isDisposed && mounted) {
      setState(() {
        _showSidebar = !_showSidebar;
      });
    }
  }

  // Item Handling Methods
  void _onItemTap(CourseItem item, int lessonIndex, int itemIndex) {
    if (item.isLocked) {
      _showErrorSnackBar(
        'Bạn cần hoàn thành các bài học trước đó để mở khóa nội dung này',
      );
      return;
    }

    setState(() {
      _currentItemId = item.id;
      _currentItem = item;
      // Đóng sidebar sau khi chọn item
      _showSidebar = false;
    });

    _handleItemByType(item);
  }

  void _handleItemByType(CourseItem item) {
    switch (item.type) {
      case CourseItemType.video:
        if (item.videoUrl != null) {
          _initializeVideoFromItem(item.videoUrl!);
        }
        break;
      case CourseItemType.exercise:
        _showItemDialog(item, 'Đây là nội dung bài tập.');

        break;
      case CourseItemType.quiz:
        Get.off(() => QuizScreen(uid: _firebaseAuth.currentUser!.uid));

        break;

      case CourseItemType.document:
        _showItemDialog(item, 'Đây là tài liệu.');
        break;
      case CourseItemType.assignment:
        _showItemDialog(item, 'Đây là assignment.');
        break;
    }
  }

  void _showItemDialog(CourseItem item, String content) {
    if (_isDisposed) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(item.title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _markItemAsCompleted() {
    if (_currentItem == null || _currentItem!.isCompleted || _isDisposed)
      return;

    setState(() => _currentItem!.isCompleted = true);
    _showErrorSnackBar('Đã đánh dấu hoàn thành!');
  }

  // Utility Methods
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _getItemIcon(CourseItemType type) {
    switch (type) {
      case CourseItemType.video:
        return Icons.play_circle_outline;
      case CourseItemType.exercise:
        return Icons.assignment_outlined;
      case CourseItemType.quiz:
        return Icons.quiz_outlined;
      case CourseItemType.document:
        return Icons.article_outlined;
      case CourseItemType.assignment:
        return Icons.task_outlined;
    }
  }

  String _getItemTypeText(CourseItemType type) {
    switch (type) {
      case CourseItemType.video:
        return 'Video';
      case CourseItemType.exercise:
        return 'Bài tập';
      case CourseItemType.quiz:
        return 'Quiz';
      case CourseItemType.document:
        return 'Tài liệu';
      case CourseItemType.assignment:
        return 'Assignment';
    }
  }

  // Cleanup Methods
  Future<void> _disposeVideoController() async {
    if (_videoController != null) {
      _videoController!.removeListener(_updateVideoPosition);
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controlsTimer?.cancel();
    _controlsAnimationController.dispose();
    _playPauseAnimationController.dispose();
    _tabController.dispose();
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content
          _buildMainContent(),

          // Sidebar overlay
          if (_showSidebar)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 350,
                color: Colors.white,
                child: _buildCourseSidebar(),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _currentItem?.title ?? 'Bài giảng ${_currentVideoIndex + 1}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_showSidebar ? Icons.close : Icons.menu),
          onPressed: _toggleSidebar,
        ),
        if (_currentItem != null && !_currentItem!.isCompleted)
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _markItemAsCompleted,
            tooltip: 'Đánh dấu hoàn thành',
          ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(child: Center(child: _buildVideoPlayer())),
          if (_isVideoInitialized && _videoController != null)
            Expanded(child: _buildTabbedContent()),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Nếu chưa có current item, hiển thị video đầu tiên
    if (_currentItem == null && widget.videoList.isNotEmpty) {
      if (_isLoading) {
        return _buildLoadingIndicator();
      }

      if (!_isVideoInitialized || _videoController == null) {
        return _buildPlaceholder(
          Icons.error_outline,
          'Không thể tải video',
          color: Colors.red,
        );
      }

      return GestureDetector(
        onTap: _showControlsTemporary,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            if (_showControls) _buildControlsOverlay(),
            if (_isBuffering) _buildBufferingIndicator(),
          ],
        ),
      );
    }

    if (_currentItem == null) {
      return _buildPlaceholder(
        Icons.video_library,
        'Chọn một video từ danh sách bên cạnh',
      );
    }

    if (_currentItem!.type != CourseItemType.video) {
      return _buildItemPlaceholder();
    }

    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (!_isVideoInitialized || _videoController == null) {
      return _buildPlaceholder(
        Icons.error_outline,
        'Không thể tải video',
        color: Colors.red,
      );
    }

    return GestureDetector(
      onTap: _showControlsTemporary,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (_showControls) _buildControlsOverlay(),
          if (_isBuffering) _buildBufferingIndicator(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, String text, {Color? color}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color ?? Colors.white54),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _toggleSidebar,
            child: const Text('Mở danh sách bài học'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getItemIcon(_currentItem!.type),
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _currentItem!.title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getItemTypeText(_currentItem!.type),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Đang tải video...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedBuilder(
      animation: _controlsAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsAnimationController.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(child: _buildCenterPlayButton()),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterPlayButton() {
    if (_videoController == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _playPauseAnimationController,
          builder: (context, child) {
            return Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 12),
          _buildControlButtons(),
          if (_showVolumeSlider) _buildVolumeSlider(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_videoController == null) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          _formatDuration(_currentPosition),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.purple,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
        ),
        Text(
          _formatDuration(_videoDuration),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: _currentVideoIndex > 0 ? _playPreviousVideo : null,
        ),
        _buildControlButton(
          icon:
              _volume > 0.5
                  ? Icons.volume_up
                  : _volume > 0
                  ? Icons.volume_down
                  : Icons.volume_off,
          onPressed: () {
            setState(() => _showVolumeSlider = !_showVolumeSlider);
          },
        ),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed:
              _currentVideoIndex < widget.videoList.length - 1
                  ? _playNextVideo
                  : null,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.volume_down, color: Colors.white, size: 20),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.purple,
                inactiveTrackColor: Colors.white30,
                thumbColor: AppColors.purple,
                overlayColor: AppColors.purple.withOpacity(0.2),
                trackHeight: 3,
              ),
              child: Slider(
                value: _volume,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                    _videoController?.setVolume(_volume);
                  });
                },
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
          const Icon(Icons.volume_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  // Widget _buildVideoControls() {
  //   if (_videoController == null) return const SizedBox.shrink();

  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     color: Colors.black.withOpacity(0.7),
  //     child: Row(
  //       children: [
  //         IconButton(
  //           onPressed: _togglePlayPause,
  //           icon: Icon(
  //             _videoController!.value.isPlaying
  //                 ? Icons.pause
  //                 : Icons.play_arrow,
  //             color: Colors.white,
  //             size: 30,
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         // Expanded(
  //         //   child: VideoProgressIndicator(
  //         //     _videoController!,
  //         //     allowScrubbing: true,
  //         //     colors: const VideoProgressColors(
  //         //       playedColor: Colors.blue,
  //         //       backgroundColor: Colors.grey,
  //         //       bufferedColor: Colors.white54,
  //         //     ),
  //         //   ),
  //         // ),
  //         // const SizedBox(width: 16),
  //         // Text(
  //         //   '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
  //         //   style: const TextStyle(color: Colors.white, fontSize: 12),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTabbedContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildTabBarSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                VideoListTab(
                  videoList: widget.videoList,
                  currentIndex: _currentVideoIndex,
                  onVideoTap: _changeVideo,
                ),
                const LessonContentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorPadding: const EdgeInsets.all(2),
            labelColor: AppColors.purple,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.playlist_play, size: 18),
                    SizedBox(width: 6),
                    Text('Danh sách'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article_outlined, size: 18),
                    SizedBox(width: 6),
                    Text('Nội dung'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSidebar() {
    return CourseSidebar(
      lessons: widget.lessons,
      currentItemId: _currentItemId,
      onItemTap: _onItemTap,
      width: 350,
      backgroundColor: Colors.white,
      primaryColor: AppColors.light_purple,
    );
  }
}

// Separate Tab Widgets for better organization
class VideoListTab extends StatelessWidget {
  final List<String> videoList;
  final int currentIndex;
  final Function(int) onVideoTap;

  const VideoListTab({
    super.key,
    required this.videoList,
    required this.currentIndex,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Danh sách bài giảng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${videoList.length} videos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: videoList.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final isSelected = index == currentIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.purple.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: AppColors.purple.withOpacity(0.3))
                          : null,
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.purple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? Icons.play_arrow : Icons.play_circle_outline,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Bài giảng ${index + 1}',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.purple : Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Video ${index + 1}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing:
                      isSelected
                          ? const Icon(
                            Icons.equalizer,
                            color: AppColors.purple,
                            size: 20,
                          )
                          : null,
                  onTap: () => onVideoTap(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LessonContentTab extends StatelessWidget {
  const LessonContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLessonHeader(),
          const SizedBox(height: 24),
          _buildTheorySection(),
          const SizedBox(height: 24),
          _buildResourcesSection(),
          const SizedBox(height: 24),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.purple.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Front-end Programmer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bài 1: Tổng quan khóa học',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.bookmark_outline, color: Colors.white70, size: 20),
        ],
      ),
    );
  }

  Widget _buildTheorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.library_books, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Lý thuyết',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giới thiệu về Front-end Development',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Front-end development là quá trình xây dựng giao diện người dùng (UI) và trải nghiệm người dùng (UX) cho các ứng dụng web và di động. Trong bài học này, chúng ta sẽ tìm hiểu:',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              ..._buildTheoryPoints(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTheoryPoints() {
    final points = [
      'Các công nghệ cơ bản: HTML, CSS, JavaScript',
      'Frameworks phổ biến: React, Vue.js, Angular',
      'Tools và môi trường phát triển',
      'Best practices trong Front-end development',
      'Responsive design và mobile-first approach',
    ];

    return points
        .map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Tài liệu tham khảo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildResourceItem(
          'Slide bài giảng',
          'presentation.pdf',
          Icons.picture_as_pdf,
          '2.5 MB',
        ),
        _buildResourceItem(
          'Source code mẫu',
          'example-code.zip',
          Icons.code,
          '1.2 MB',
        ),
        _buildResourceItem(
          'Bài tập thực hành',
          'exercises.docx',
          Icons.assignment,
          '856 KB',
        ),
      ],
    );
  }

  Widget _buildResourceItem(
    String title,
    String filename,
    IconData icon,
    String size,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$filename • $size',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle download
            },
            icon: const Icon(Icons.download_outlined, size: 20),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lưu ý quan trọng',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy thực hành thường xuyên và không ngại thử nghiệm với code. Front-end development đòi hỏi sự sáng tạo và kiên nhẫn trong việc tạo ra những giao diện đẹp mắt và dễ sử dụng.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ghi chú của bạn',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Thêm ghi chú cho bài học này...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.purple),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save notes
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Lưu ghi chú',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
