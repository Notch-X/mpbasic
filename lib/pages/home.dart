import 'package:flutter/material.dart';
import 'package:mpbasic/models/category_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  void _getCategories() {
    categories = CategoryModel.getCategories();
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
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Saline Solution Production',
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
    return Padding(
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
    );
  }

  Widget _buildHomeButton() {
    return FloatingActionButton(
      onPressed: () {
        // Handle Home button press
      },
      elevation: 2,
      backgroundColor: const Color(0xFF4FB3AF),
      shape: CircleBorder(
        side: BorderSide(
          color: const Color(0xFF1B4D4C),
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
