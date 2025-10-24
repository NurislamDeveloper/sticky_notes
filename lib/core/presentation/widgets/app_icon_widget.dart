import 'package:flutter/material.dart';
class AppIconWidget extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  const AppIconWidget({
    super.key,
    this.size = 100.0,
    this.backgroundColor,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF1E3A8A);
    final icColor = iconColor ?? Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.note_alt_rounded,
              size: size * 0.5,
              color: icColor,
            ),
          ),
          Positioned(
            top: size * 0.15,
            right: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(size * 0.125),
              ),
              child: Icon(
                Icons.star,
                size: size * 0.15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
