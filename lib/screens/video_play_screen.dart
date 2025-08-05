import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> videoList;
  final int initialIndex;
  final void Function(int index)? onVideoWatched;

  const VideoPlayerScreen({
    super.key,
    required this.videoList,
    required this.initialIndex,
    this.onVideoWatched,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late int _currentIndex;
  late AnimationController _controlsAnimationController;
  late AnimationController _playPauseAnimationController;
  late TabController _tabController;

  double _volume = 1.0;
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _showVolumeSlider = false;
  bool _showControls = true;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _tabController = TabController(length: 2, vsync: this);

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..value = 1.0; // Start with controls visible

    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _initializePlayer();
  }

  void _initializePlayer() {
    setState(() {
      _isBuffering = true;
    });

    _controller = VideoPlayerController.network(widget.videoList[_currentIndex])
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _videoDuration = _controller.value.duration;
              _isBuffering = false;
            });
            _controller.play();
            _playPauseAnimationController.forward();
            _controller.addListener(_updatePosition);
            _startControlsTimer();
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() {
              _isBuffering = false;
            });
            print('Error initializing video: $error');
          });
  }

  void _updatePosition() {
    if (!mounted) return;
    final position = _controller.value.position;
    final isEnded = position >= _controller.value.duration;
    final isBuffering = _controller.value.isBuffering;

    setState(() {
      _currentPosition = position;
      _isBuffering = isBuffering;
    });

    if (isEnded && widget.onVideoWatched != null) {
      widget.onVideoWatched!(_currentIndex);
    }
  }

  void _disposeController() {
    _controller.removeListener(_updatePosition);
    _controller.dispose();
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _disposeController();
      setState(() => _currentIndex--);
      _initializePlayer();
    }
  }

  void _playNext() {
    if (_currentIndex < widget.videoList.length - 1) {
      _disposeController();
      setState(() => _currentIndex++);
      _initializePlayer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _playPauseAnimationController.reverse();
      } else {
        _controller.play();
        _playPauseAnimationController.forward();
      }
    });
    _showControlsTemporary();
  }

  void _showControlsTemporary() {
    setState(() {
      _showControls = true;
    });
    _controlsAnimationController.forward();
    _startControlsTimer();
  }

  void _startControlsTimer() {
    if (!mounted) return;

    // Cancel any existing timer
    _controlsAnimationController.stop();

    // Show controls immediately
    _controlsAnimationController.forward();

    // Hide controls after 3 seconds if playing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted &&
          _controller.value.isInitialized &&
          _controller.value.isPlaying) {
        _controlsAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() => _showControls = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _playPauseAnimationController.dispose();
    _tabController.dispose();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Bài giảng ${_currentIndex + 1}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video Player Section
          _buildVideoPlayer(),

          // Tabbed Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorPadding: const EdgeInsets.all(4),
                      labelColor: Colors.blue[700],
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.playlist_play, size: 18),
                              const SizedBox(width: 6),
                              const Text('Danh sách'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined, size: 18),
                              const SizedBox(width: 6),
                              const Text('Nội dung'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildVideoList(), _buildLessonContent()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black,
      child:
          _controller.value.isInitialized
              ? GestureDetector(
                onTap: _showControlsTemporary,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),

                    // Buffering indicator
                    if (_isBuffering)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),

                    // Controls overlay
                    _buildControlsOverlay(),
                  ],
                ),
              )
              : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
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
                // Center play/pause button
                Center(
                  child: GestureDetector(
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
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Bottom controls
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

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.blue,
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
          ),

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous button
              _buildControlButton(
                icon: Icons.skip_previous,
                onPressed: _currentIndex > 0 ? _playPrevious : null,
              ),

              // Volume button
              _buildControlButton(
                icon:
                    _volume > 0.5
                        ? Icons.volume_up
                        : _volume > 0
                        ? Icons.volume_down
                        : Icons.volume_off,
                onPressed: () {
                  setState(() {
                    _showVolumeSlider = !_showVolumeSlider;
                  });
                },
              ),

              // Next button
              _buildControlButton(
                icon: Icons.skip_next,
                onPressed:
                    _currentIndex < widget.videoList.length - 1
                        ? _playNext
                        : null,
              ),
            ],
          ),

          // Volume slider
          if (_showVolumeSlider)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.volume_down, color: Colors.white, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.blue,
                        overlayColor: Colors.blue.withOpacity(0.2),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            _controller.setVolume(_volume);
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
            ),
        ],
      ),
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

  Widget _buildVideoList() {
    return Column(
      children: [
        // Video list header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Danh sách bài giảng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${widget.videoList.length} videos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),

        // Video list
        Expanded(
          child: ListView.builder(
            itemCount: widget.videoList.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final isSelected = index == _currentIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: Colors.blue.withOpacity(0.3))
                          : null,
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
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
                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    'Video ${index + 1}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.equalizer,
                            color: Colors.blue[600],
                            size: 20,
                          )
                          : null,
                  onTap: () {
                    if (index != _currentIndex) {
                      _disposeController();
                      setState(() => _currentIndex = index);
                      _initializePlayer();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: Colors.white, size: 24),
                const SizedBox(width: 12),
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
                      Text(
                        'Bài ${_currentIndex + 1}: Tổng quan khóa học',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Theory section
          Text(
            'Lý thuyết',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          const SizedBox(height: 16),

          // Learning objectives
          _buildContentSection('Mục tiêu bài học:', [
            'Hiểu rõ khái niệm "Front-End" là gì',
            'Biết được những kiến thức và kỹ năng bạn sẽ học trong suốt khóa học',
            'Nắm được lộ trình học và công cụ sử dụng xuyên suốt khóa học',
            'Định hướng nghề nghiệp và cơ hội việc làm sau khi hoàn thành khóa học',
          ]),

          const SizedBox(height: 20),

          // What is Front-End section
          _buildContentSection('1. Front-End là gì?', [
            '"Front-End là phần giao diện người dùng – nơi mà người dùng nhìn thấy và tương tác trực tiếp trên trình duyệt web. Ví dụ: nút bấm, thanh điều hướng, hình ảnh của một website..."',
            'Mục đích của Front-End là tạo ra trải nghiệm người dùng (UX) tốt và giao diện người dùng (UI) đẹp mắt, mượt mà và dễ sử dụng.',
          ]),

          const SizedBox(height: 20),

          // Role of Front-End Developer
          _buildContentSection('2. Vai trò của lập trình viên Front-End', [
            'Một Front-End Developer chịu trách nhiệm:',
            '• Xây dựng bố cục và thiết kế website bằng HTML, CSS, JavaScript',
            '• Kết nối dữ liệu từ server (API) và hiển thị cho người dùng',
          ]),

          const SizedBox(height: 20),

          // Technologies section
          _buildTechSection(),

          const SizedBox(height: 20),

          // Career opportunities
          _buildContentSection('3. Cơ hội nghề nghiệp', [
            'Sau khi hoàn thành khóa học, bạn có thể làm việc ở các vị trí:',
            '• Front-End Developer',
            '• Web Developer',
            '• UI/UX Developer',
            '• Full-Stack Developer (kết hợp với Back-End)',
          ]),
        ],
      ),
    );
  }

  Widget _buildContentSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        ...content.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.startsWith('•'))
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                  )
                else if (!item.contains(':') && !item.startsWith('"'))
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    item.startsWith('•') ? item.substring(2) : item,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechSection() {
    final technologies = [
      {'name': 'HTML', 'color': Colors.orange, 'icon': '🔧'},
      {'name': 'CSS', 'color': Colors.blue, 'icon': '🎨'},
      {'name': 'JavaScript', 'color': Colors.yellow[700], 'icon': '⚡'},
      {'name': 'React', 'color': Colors.cyan, 'icon': '⚛️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Công nghệ sử dụng trong khóa học',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              technologies
                  .map(
                    (tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (tech['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (tech['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tech['icon'] as String,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tech['name'] as String,
                            style: TextStyle(
                              color: tech['color'] as Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}
