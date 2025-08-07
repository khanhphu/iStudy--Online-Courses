import 'package:flutter/material.dart';
import 'package:istudy_courses/theme/colors.dart';

class FloatingNavButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? heroTag;

  const FloatingNavButton({
    Key? key,
    required this.onPressed,
    this.icon = Icons.menu,
    this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
    this.heroTag,
  }) : super(key: key);

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppColors.purple)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? Colors.white,
                size: widget.size * 0.4,
              ),
            ),
          ),
        );
      },
    );
  }
}
