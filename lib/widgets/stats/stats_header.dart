import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsHeader extends StatelessWidget {
  final String title;
  final String userInitial;

  const StatsHeader({
    super.key,
    required this.title,
    required this.userInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const _HeaderIcon(icon: CupertinoIcons.bell, hasNotification: true),
        const SizedBox(width: 12),
        _HeaderIcon(
          child: Text(
            userInitial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final bool hasNotification;
  const _HeaderIcon({this.icon, this.child, this.hasNotification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42, // Slightly larger for better touch target
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 20),
          if (child != null) child!,
          if (hasNotification)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
