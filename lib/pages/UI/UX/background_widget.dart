import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.transparent,
            ],
            radius: 1.5,
            center: const Alignment(0.8, -0.6),
          ),
        ),
      ),
    );
  }
}
