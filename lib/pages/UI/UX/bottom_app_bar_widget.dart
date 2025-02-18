import 'package:flutter/material.dart';

class BottomAppBarWidget extends StatelessWidget {
  final Function(String, BuildContext) navigateToPage;

  const BottomAppBarWidget({super.key, required this.navigateToPage});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildBottomNavItem(
                Icons.science, () => navigateToPage('Process', context)),
            buildBottomNavItem(
                Icons.analytics, () => navigateToPage('Analytics', context)),
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => navigateToPage('Home', context),
            ),
            buildBottomNavItem(
                Icons.chat_bubble, () => navigateToPage('Chat', context)),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: onTap,
    );
  }
}
