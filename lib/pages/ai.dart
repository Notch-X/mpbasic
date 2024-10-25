import 'package:flutter/material.dart';
import 'package:mpbasic/models/category_model.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/home.dart'; 
import 'package:mpbasic/pages/alerts.dart'; // Adding page

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  void _getCategories() {
    categories = CategoryModel.getCategories();
  }

  // Navigation handler for both drawer and bottom bar
  void _navigateToPage(String route, BuildContext context) {
    Navigator.pop(context);
    switch (route) {
      case 'Home':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        break;
      case 'Process':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProcessPage()),
        );
        break;
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsPage()),
        );
        break;
      case 'Chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatbotPage()),
        );
        break;
       case 'Alerts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: const Color(0xFFF5F9F9),
      drawer: _buildDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 40),
          // Add your home page content here
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDrawer() {
    return SizedBox(
      width: 240,
      child: Drawer(
        child: Container(
          color: const Color(0xFF1B4D4C),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1B4D4C),
                ),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
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
              _buildDrawerItem(Icons.home, 'Home'),
              _buildDrawerItem(Icons.science, 'Process'),
              _buildDrawerItem(Icons.analytics, 'Analytics'),
              _buildDrawerItem(Icons.chat_bubble, 'AI ChatBot'),
              _buildDrawerItem(Icons.notifications, 'Alerts'),
              Divider(color: Colors.white.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4FB3AF)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () => _navigateToPage(title, context),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'AI ChatBot',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF1B4D4C),
      elevation: 0.0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: const Color(0xFF1B4D4C),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(Icons.science, 'Process'),
            _buildBottomNavItem(Icons.analytics, 'Analytics'),
            const SizedBox(width: 40), // Space for FAB
            _buildBottomNavItem(Icons.chat_bubble, 'Chat'),
            _buildBottomNavItem(Icons.notifications, 'Alerts'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _navigateToPage(label, context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4FB3AF), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4FB3AF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return FloatingActionButton(
      onPressed: () {
        // If not on home page, navigate to home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      },
      elevation: 2,
      backgroundColor: const Color(0xFF4FB3AF),
      shape: const CircleBorder(
        side: BorderSide(
          color: Color(0xFF1B4D4C),
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.home,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
