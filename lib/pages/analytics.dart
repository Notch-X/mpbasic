import 'package:flutter/material.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/ai.dart'; 
import 'package:mpbasic/pages/alerts.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  int _selectedSection = 0;
  int _selectedSubPage = 0;
  TabController? _tabController;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'OEE', // Tab label
      'header': 'Overall Equipment Effectiveness', // Header text
      'subpages': [
        {
          'title': 'Availability',
          'icon': Icons.access_time,
        },
        {
          'title': 'Performance',
          'icon': Icons.speed,
        },
        {
          'title': 'Quality',
          'icon': Icons.verified,
        },
      ]
    },
    {
      'title': 'Sustainability',
      'header': 'Sustainability',
      'subpages': [
        {
          'title': 'Electrical Power',
          'icon': Icons.electrical_services,
        },
        {
          'title': 'Water Usage',
          'icon': Icons.water,
        },
        {
          'title': 'Pressurized Air',
          'icon': Icons.air,
        },
      ]
    },
    {
      'title': 'Trends',
      'header': 'Trends',
      'subpages': [
        {
          'title': 'Temp/PH',
          'icon': Icons.thermostat,
        },
        {
          'title': 'Total Water Used',
          'icon': Icons.water_damage,
        },
        {
          'title': 'Pressurized Air',
          'icon': Icons.air,
        },
        {
          'title': 'Conductivity & TDS',
          'icon': Icons.science,
        },
        {
          'title': 'Power-Meter',
          'icon': Icons.bolt,
        },
        {
          'title': 'Overall Equipment Effectiveness',
          'icon': Icons.assessment,
        },
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedSection = _tabController!.index;
        _selectedSubPage = 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

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
      case 'Chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatbotPage()),
        );
        break;
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsPage()),
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

  void _showFullScreenDiagram(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'Analytics Diagram for ${_sections[_selectedSection]['header']}\nSubpage: ${_sections[_selectedSection]['subpages'][_selectedSubPage]['title']}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1B4D4C),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _sections[_selectedSection]['header'],
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
          tabs:
              _sections.map((section) => Tab(text: section['title'])).toList(),
        ),
      ),
      backgroundColor: const Color(0xFFF5F9F9),
      drawer: _buildDrawer(),
      body: Column(
        children: [
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

  Widget _buildSubPageTabs() {
    List<Map<String, dynamic>> currentSubpages =
        _sections[_selectedSection]['subpages'];
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentSubpages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubPage = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    currentSubpages[index]['icon'],
                    color: _selectedSubPage == index
                        ? const Color(0xFF4FB3AF)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentSubpages[index]['title'],
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
        },
      ),
    );
  }

  Widget _buildPageContent() {
    Map<String, dynamic> currentSubpage =
        _sections[_selectedSection]['subpages'][_selectedSubPage];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenDiagram(context),
            child: _buildAnalyticsDiagram(),
          ),
          const SizedBox(height: 20),
          _buildAnalyticsDetails(currentSubpage),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDiagram() {
    Map<String, dynamic> currentSubpage =
        _sections[_selectedSection]['subpages'][_selectedSubPage];
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
          'Analytics Diagram for ${_sections[_selectedSection]['header']}\nSubpage: ${currentSubpage['title']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B4D4C),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDetails(Map<String, dynamic> subpage) {
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
          Row(
            children: [
              Icon(
                subpage['icon'],
                color: const Color(0xFF1B4D4C),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                subpage['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4D4C),
                ),
              ),
            ],
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
