import 'package:flutter/material.dart';
import 'package:mpbasic/pages/home.dart'; // Import HomePage

class ProcessPage extends StatefulWidget {
  const ProcessPage({super.key});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  int _selectedModule = 0;
  int _selectedSubPage = 0;

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Module 1: Dosing Process',
      'subpages': [
        {'title': 'Overview', 'icon': Icons.assignment},
        {'title': 'Parameters', 'icon': Icons.tune},
      ]
    },
    {
      'title': 'Module 2: Mixing Process',
      'subpages': [
        {'title': 'Overview', 'icon': Icons.assignment},
        {'title': 'Parameters', 'icon': Icons.tune},
      ]
    },
    {
      'title': 'Module 3: Brewing Process',
      'subpages': [
        {'title': 'Overview', 'icon': Icons.assignment},
        {'title': 'Parameters', 'icon': Icons.tune},
      ]
    },
    {
      'title': 'Module 4: Filling Process',
      'subpages': [
        {'title': 'Overview', 'icon': Icons.assignment},
        {'title': 'Parameters', 'icon': Icons.tune},
      ]
    },
  ];

  void _navigateToPage(String route, BuildContext context) {
    // Close the drawer if it's open
    Navigator.pop(context);

    // Navigate to the selected page
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
      // Add more cases for other pages if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modules[_selectedModule]['title'],
          style: const TextStyle(
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
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F9F9),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildModuleSelector(),
          _buildSubPageTabs(),
          Expanded(
            child: _buildPageContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModuleSelector() {
    return Container(
      height: 60,
      color: const Color(0xFF1B4D4C),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedModule = index;
                _selectedSubPage = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedModule == index
                        ? const Color(0xFF4FB3AF)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                'Module ${index + 1}',
                style: TextStyle(
                  color: _selectedModule == index
                      ? const Color(0xFF4FB3AF)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubPageTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _modules[_selectedModule]['subpages'].map<Widget>((subpage) {
          final index = _modules[_selectedModule]['subpages'].indexOf(subpage);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubPage = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedSubPage == index
                        ? const Color(0xFF4FB3AF)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    subpage['icon'],
                    color: _selectedSubPage == index
                        ? const Color(0xFF4FB3AF)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    subpage['title'],
                    style: TextStyle(
                      color: _selectedSubPage == index
                          ? const Color(0xFF4FB3AF)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageContent() {
    // Example process diagram for each module
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProcessDiagram(),
          const SizedBox(height: 20),
          _buildProcessDetails(),
        ],
      ),
    );
  }

  Widget _buildProcessDiagram() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Process Diagram for ${_modules[_selectedModule]['title']}\nSubpage: ${_modules[_selectedModule]['subpages'][_selectedSubPage]['title']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B4D4C),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Process Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D4C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This is the ${_modules[_selectedModule]['subpages'][_selectedSubPage]['title']} view for ${_modules[_selectedModule]['title']}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
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
