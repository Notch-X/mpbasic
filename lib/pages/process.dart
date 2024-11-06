import 'package:flutter/material.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:mpbasic/pages/alerts.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/manual_mode.dart';


class ProcessPage extends StatefulWidget {
  const ProcessPage({super.key});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  String _status = "";
  bool _isAutoMode = false;
  bool _isStopped = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Overview of System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B4D4C),
        elevation: 0.0,
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: _buildOverallSystemPage(),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildOverallSystemPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.only(bottom: 20),
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
            child: const Center(
              child: Text(
                'Overall System Diagram',
                style: TextStyle(fontSize: 20, color: Color(0xFF1B4D4C)),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 24,
                  child: _buildControlButtonWithLED(
                    label: 'Auto',
                    color: Colors.green,
                    isActive: _isAutoMode,
                    onPressed: () {
                      setState(() {
                        _isAutoMode = true;
                        _isStopped = false;
                        _status = "System is running in Auto mode";
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 24,
                  child: _buildControlButtonWithLED(
                    label: 'Stop',
                    color: Colors.red,
                    isActive: _isStopped,
                    onPressed: () {
                      setState(() {
                        _isAutoMode = false;
                        _isStopped = true;
                        _status = "System stopped running";
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 24,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManualModePage(
                                selectedModule: 0,
                              
                                onModuleChanged: (int moduleIndex) {
                                },
                                onStatusChanged: (String newStatus) {
                                  setState(() {
                                    _status = newStatus;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width / 3 - 24,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Manual',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _status,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtonWithLED({
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: Size(
              MediaQuery.of(context).size.width / 3 - 24,
              48,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
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
            const SizedBox(width: 40),
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
      onPressed: () => _navigateToPage('Home', context),
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
}
