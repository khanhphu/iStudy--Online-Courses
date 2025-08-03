import 'package:flutter/material.dart';
import 'package:istudy_courses/theme/colors.dart';
import 'package:istudy_courses/theme/theme.dart';
class CustomBottomNavBar extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.child,
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _isVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);

  void _showBar() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _showBar(),
      child: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              _showBar();
              return false;
            },
            child: widget.child,
          ),

          // Bottom bar fixed at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: _isVisible ? Offset.zero : const Offset(0, 1),
              duration: _animationDuration,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: _animationDuration,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: BottomNavigationBar(
                        currentIndex: widget.currentIndex,
                        onTap: widget.onTap,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.grey,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        items: List.generate(4, (index) {
                          Widget iconWidget;
                          String label;

                          final isSelected = index == widget.currentIndex;

                          switch (index) {
                            case 0:
                              iconWidget = Image.asset(
                                'assets/icon_home.png',
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.white : Colors.grey,
                              );
                              label = 'Home';
                              break;
                            case 1:
                              iconWidget = Image.asset(
                                'assets/icon_search.png',
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.white : Colors.grey,
                              );
                              label = 'Search';
                              break;
                            case 2:
                              iconWidget = Image.asset(
                                'assets/icon_schedule.png',
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.white : Colors.grey,
                              );
                              label = "Schedule";
                              break;
                            case 3:
                              iconWidget = Image.asset(
                                'assets/icon_course.png',
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.white : Colors.grey,
                              );

                              label = 'Course';
                              break;
                            case 4:
                              iconWidget = Image.asset(
                                'assets/icon_profile.png',
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.white : Colors.grey,
                              );

                              label = 'Profile';
                              break;
                            default:
                              iconWidget = Icon(Icons.circle);
                              label = 'Default';
                          }




          return BottomNavigationBarItem(
                            icon: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(isSelected ? 6 : 0),
                              decoration:
                                  isSelected
                                      ? BoxDecoration(
                                        color: AppColors.purple,
                                        shape: BoxShape.circle,
                                      )
                                      : null,
                              child: iconWidget,
                            ),
                            label: label,
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
           