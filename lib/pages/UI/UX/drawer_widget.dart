import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final Function(String, BuildContext) navigateToPage;

  const DrawerWidget({super.key, required this.navigateToPage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C1B29), Color(0xFF2D2A4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: const [Color(0xFF6A1B9A), Color(0xFF283593)],
                        ),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'EcoSaline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              buildDrawerItem(
                  Icons.home, 'Home', () => navigateToPage('Home', context)),
              buildDrawerItem(Icons.science, 'Process',
                  () => navigateToPage('Process', context)),
              buildDrawerItem(Icons.analytics, 'Analytics',
                  () => navigateToPage('Analytics', context)),
              buildDrawerItem(Icons.chat_bubble, 'AI ChatBot',
                  () => navigateToPage('Chat', context)),
              buildDrawerItem(Icons.notifications, 'Alerts',
                  () => navigateToPage('Alerts', context)),
              const Divider(color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
