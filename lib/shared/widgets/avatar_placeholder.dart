import 'package:flutter/material.dart';

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.support_agent_rounded,
        color: Colors.white,
        size: size * 0.46,
      ),
    );
  }
}
