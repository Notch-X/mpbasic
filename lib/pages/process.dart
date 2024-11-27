import 'package:flutter/material.dart';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
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
  double _oeeValue = 100.0;
  bool _bottlesReplaced = false;

  void _resetOEE() {
    setState(() {
      _oeeValue = 100.0;
      _status = "OEE Reset to 100%";
    });
  }

  void _replaceBottles() {
    setState(() {
      _bottlesReplaced = true;
      _status = "Bottles Replaced Successfully";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Overview of System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
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
      ),
      drawer: DrawerWidget(navigateToPage: _navigateToPage),
      body: Stack(
        children: [
          const BackgroundWidget(),
          _buildOverallSystemPage(),
        ],
      ),
      bottomNavigationBar: BottomAppBarWidget(navigateToPage: _navigateToPage),
    );
  }

  Widget _buildOverallSystemPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 100), // Add padding for AppBar
          Center(
            child: Column(
              children: [
                _buildControlCard(
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
                _buildControlCard(
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
                _buildControlCard(
                  label: 'Manual',
                  color: Colors.orange,
                  isActive: false,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManualModePage(
                          selectedModule: 0,
                          onModuleChanged: (int moduleIndex) {},
                          onStatusChanged: (String newStatus) {
                            setState(() {
                              _status = newStatus;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildControlCard(
                  label: 'OEE Reset',
                  color: Colors.blue,
                  isActive: false,
                  onPressed: _resetOEE,
                ),
                _buildControlCard(
                  label: 'Replace Bottles',
                  color: Colors.purple,
                  isActive: _bottlesReplaced,
                  onPressed: _replaceBottles,
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
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
      case 'AI ChatBot':
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