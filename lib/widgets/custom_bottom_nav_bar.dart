import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:istudy_courses/theme/colors.dart';

// Main wrapper widget để tích hợp vào mọi screen
class ScreenWithBottomNav extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigate;
  final List<BottomNavItem> navItems;
  final Duration autoHideDuration;
  final bool showOnStart;

  const ScreenWithBottomNav({
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
    required this.navItems,
    this.autoHideDuration = const Duration(seconds: 3),
    this.showOnStart = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenWithBottomNav> createState() => _ScreenWithBottomNavState();
}

class _ScreenWithBottomNavState extends State<ScreenWithBottomNav>
    with TickerProviderStateMixin {
  bool _isBottomNavVisible = false;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    if (widget.showOnStart) {
      _showBottomNav();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showBottomNav() {
    if (!_isBottomNavVisible) {
      setState(() {
        _isBottomNavVisible = true;
      });
      _animationController.forward();
      _fadeController.forward();
      _startHideTimer();
    } else {
      _startHideTimer(); // Reset timer nếu đã hiển thị
    }
  }

  void _hideBottomNav() {
    if (_isBottomNavVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isBottomNavVisible = false;
          });
        }
      });
      _fadeController.reverse();
    }
    _hideTimer?.cancel();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.autoHideDuration, () {
      if (mounted) {
        _hideBottomNav();
      }
    });
  }

  void _onUserInteraction() {
    _showBottomNav();
    HapticFeedback.lightImpact(); // Phản hồi xúc giác nhẹ
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onUserInteraction,
      onScaleStart:
          (_) => _onUserInteraction(), // Only use scale (which includes pan)
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Bottom Navigation Bar
          if (_isBottomNavVisible) ...[
            // Background overlay để có thể tap để ẩn
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideBottomNav,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBottomNav(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 67, // Reduced height to prevent overflow
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ), // Reduced vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                widget.navItems.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = index == widget.currentIndex;
    final item = widget.navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onNavigate(index);
          _startHideTimer(); // Reset timer after navigation
        },
        child: Container(
          height: 59, // Fixed height to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container với animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 8 : 6), // Reduced padding
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                item.selectedGradient ??
                                [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                ],
                          )
                          : null,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Slightly smaller radius
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: (item.selectedGradient?.first ??
                                      const Color(0xFF6366F1))
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Icon(
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: isSelected ? 22 : 20, // Reduced icon size
                ),
              ),

              const SizedBox(height: 4), // Reduced spacing
              // Label với animation
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color:
                        isSelected
                            ? (item.selectedGradient?.first ??
                                const Color(0xFF6366F1))
                            : Colors.grey[600],
                    fontSize: isSelected ? 10 : 9, // Reduced font size
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model cho navigation item
class BottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final List<Color>? selectedGradient;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.selectedGradient,
  });
}

// Extension để dễ dàng sử dụng
extension ScreenExtension on Widget {
  Widget withBottomNav({
    required int currentIndex,
    required Function(int) onNavigate,
    List<BottomNavItem>? customItems,
    Duration autoHideDuration = const Duration(seconds: 3),
    bool showOnStart = false,
  }) {
    final defaultItems = [
      const BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
        selectedGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      const BottomNavItem(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: 'Search',
        selectedGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      const BottomNavItem(
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        label: 'Schedule',
        selectedGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      const BottomNavItem(
        icon: Icons.book_outlined,
        selectedIcon: Icons.book,
        label: 'Course',
        selectedGradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
    ];

    return ScreenWithBottomNav(
      currentIndex: currentIndex,
      onNavigate: onNavigate,
      navItems: customItems ?? defaultItems,
      autoHideDuration: autoHideDuration,
      showOnStart: showOnStart,
      child: this,
    );
  }
}

// Utility class để quản lý trạng thái navigation
class BottomNavController extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isVisible = false;

  int get currentIndex => _currentIndex;
  bool get isVisible => _isVisible;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
