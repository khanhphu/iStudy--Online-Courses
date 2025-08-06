import 'package:flutter/material.dart';
import 'package:istudy_courses/helpers/course_item_type_enum.dart';
import 'package:istudy_courses/models/course_item.dart';
import 'package:istudy_courses/models/course_lesson.dart';
import 'package:istudy_courses/theme/colors.dart';

class CourseSidebar extends StatefulWidget {
  final List<CourseLesson> lessons;
  final String? currentItemId;
  final Function(CourseItem item, int lessonIndex, int itemIndex)? onItemTap;
  final double width;
  final Color? backgroundColor;
  final Color? primaryColor;

  const CourseSidebar({
    super.key,
    required this.lessons,
    this.currentItemId,
    this.onItemTap,
    this.width = 320,
    this.backgroundColor,
    this.primaryColor,
  });

  @override
  State<CourseSidebar> createState() => _CourseSidebarState();
}

class _CourseSidebarState extends State<CourseSidebar> {
  late List<CourseLesson> _lessons;
  late Color primaryColor;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    _lessons =
        widget.lessons
            .map(
              (lesson) => CourseLesson(
                id: lesson.id,
                title: lesson.title,
                items: lesson.items,
                isExpanded: lesson.isExpanded,
              ),
            )
            .toList();

    primaryColor = widget.primaryColor ?? AppColors.purple;
    backgroundColor = widget.backgroundColor ?? Colors.white;

    // Debug: In ra console để kiểm tra dữ liệu
    print('CourseSidebar initState: ${_lessons.length} lessons');
    for (int i = 0; i < _lessons.length; i++) {
      print(
        'Lesson $i: ${_lessons[i].title} - ${_lessons[i].items.length} items',
      );
    }
  }

  // Thêm didUpdateWidget để xử lý khi props thay đổi
  @override
  void didUpdateWidget(CourseSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons != widget.lessons) {
      setState(() {
        _lessons =
            widget.lessons
                .map(
                  (lesson) => CourseLesson(
                    id: lesson.id,
                    title: lesson.title,
                    items: lesson.items,
                    isExpanded: lesson.isExpanded,
                  ),
                )
                .toList();
      });
    }
  }

  void _toggleLesson(int index) {
    setState(() {
      _lessons[index] = CourseLesson(
        id: _lessons[index].id,
        title: _lessons[index].title,
        items: _lessons[index].items,
        isExpanded: !_lessons[index].isExpanded,
      );
    });
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

  Color _getItemColor(CourseItemType type) {
    switch (type) {
      case CourseItemType.video:
        return Colors.red[600]!;
      case CourseItemType.exercise:
        return Colors.orange[600]!;
      case CourseItemType.quiz:
        return Colors.purple[600]!;
      case CourseItemType.document:
        return Colors.blue[600]!;
      case CourseItemType.assignment:
        return Colors.green[600]!;
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

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    print('CourseSidebar build: ${_lessons.length} lessons'); // Debug

    return Container(
      width: widget.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                        'Nội dung khóa học',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_lessons.length} bài học',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Course Progress
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ học tập',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${_getCompletedItemsCount()}/${_getTotalItemsCount()}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getProgressValue(),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Lessons List
          Expanded(
            child:
                _lessons.isEmpty
                    ? Center(
                      child: Text(
                        'Không có dữ liệu bài học',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _lessons.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, lessonIndex) {
                        print(
                          'Building lesson $lessonIndex: ${_lessons[lessonIndex].title}',
                        ); // Debug
                        final lesson = _lessons[lessonIndex];
                        return _buildLessonTile(lesson, lessonIndex);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(CourseLesson lesson, int lessonIndex) {
    final completedItems =
        lesson.items.where((item) => item.isCompleted).length;
    final totalItems = lesson.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            lesson.isExpanded
                ? primaryColor.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            lesson.isExpanded
                ? Border.all(color: primaryColor.withOpacity(0.2))
                : null,
      ),
      child: Column(
        children: [
          // Lesson Header
          InkWell(
            onTap: () => _toggleLesson(lessonIndex),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: lesson.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Lesson Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Lesson Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedItems/$totalItems hoàn thành',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value:
                              totalItems > 0 ? completedItems / totalItems : 0,
                          strokeWidth: 2,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      ),
                      if (completedItems == totalItems && totalItems > 0)
                        Icon(Icons.check, color: primaryColor, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lesson Items
          if (lesson.isExpanded)
            ...lesson.items.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              return _buildLessonItem(item, lessonIndex, itemIndex);
            }),
        ],
      ),
    );
  }

  Widget _buildLessonItem(CourseItem item, int lessonIndex, int itemIndex) {
    final isSelected = item.id == widget.currentItemId;
    final itemColor = _getItemColor(item.type);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
      child: InkWell(
        onTap:
            item.isLocked
                ? null
                : () => widget.onItemTap?.call(item, lessonIndex, itemIndex),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? primaryColor.withOpacity(0.1)
                    : item.isLocked
                    ? Colors.grey[50]
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: primaryColor.withOpacity(0.3))
                    : null,
          ),
          child: Row(
            children: [
              // Item Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      item.isLocked
                          ? Colors.grey[200]
                          : itemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  item.isLocked ? Icons.lock_outline : _getItemIcon(item.type),
                  color: item.isLocked ? Colors.grey[500] : itemColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Item Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            item.isLocked
                                ? Colors.grey[500]
                                : isSelected
                                ? primaryColor
                                : Colors.grey[800],
                        decoration:
                            item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    if (item.duration != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _formatDuration(item.duration),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Status Icon
              if (item.isCompleted)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 12),
                )
              else if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCompletedItemsCount() {
    return _lessons
        .expand((lesson) => lesson.items)
        .where((item) => item.isCompleted)
        .length;
  }

  int _getTotalItemsCount() {
    return _lessons.expand((lesson) => lesson.items).length;
  }

  double _getProgressValue() {
    final completed = _getCompletedItemsCount();
    final total = _getTotalItemsCount();
    return total > 0 ? completed / total : 0.0;
  }
}
