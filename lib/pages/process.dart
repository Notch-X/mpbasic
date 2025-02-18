import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mpbasic/config.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/manual_mode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Process Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ProcessPage(),
    );
  }
}

class ProcessPage extends StatefulWidget {
  const ProcessPage({super.key});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  bool isButton1Toggled = false;
  bool isButton2Toggled = false;
  bool isButton3Toggled = false;
  String selectedConcentration = '';

  Future<void> sendStateToFlask() async {
    try {
      final url = Config.baseUrl;

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'button1': isButton1Toggled,
          'button2': isButton2Toggled,
          'button3': isButton3Toggled,
          'concentration':
              selectedConcentration.isNotEmpty ? selectedConcentration : null,
        }),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        print('Response from Flask: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mode updated successfully')),
          );
        }
      } else {
        print('Failed to send data to Flask: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update mode')),
          );
        }
      }
    } catch (e) {
      print('Error sending data to Flask: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Connection error. Please check if the server is running.'),
          ),
        );
      }
    }
  }

  void updateButtonStates(int buttonNumber) {
    setState(() {
      isButton1Toggled = false;
      isButton2Toggled = false;
      isButton3Toggled = false;

      if (buttonNumber == 1) isButton1Toggled = true;
      if (buttonNumber == 2) isButton2Toggled = true;
      if (buttonNumber == 3) isButton3Toggled = true;
    });

    sendStateToFlask();
  }

  void updateConcentration(String concentration) {
    setState(() {
      selectedConcentration = concentration;
    });

    sendStateToFlask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'PLC Control System',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blue.shade900.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildOverallSystemPage(),
        ),
      ),
      bottomNavigationBar: BottomAppBarWidget(navigateToPage: _navigateToPage),
    );
  }

  Widget _buildOverallSystemPage() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildSystemStatus(),
              const SizedBox(height: 40),
              _buildControlsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    String status = 'System Status: ';
    Color statusColor;

    if (isButton1Toggled) {
      status += 'Automatic Mode';
      statusColor = Colors.green;
    } else if (isButton2Toggled) {
      status += 'Stopped';
      statusColor = Colors.red;
    } else if (isButton3Toggled) {
      status += 'Manual Mode';
      statusColor = Colors.orange;
    } else {
      status += 'Idle';
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'System Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildControlButton(
            label: 'Auto',
            isToggled: isButton1Toggled,
            onPressed: () => updateButtonStates(1),
            icon: Icons.auto_mode,
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            label: 'Stop',
            isToggled: isButton2Toggled,
            onPressed: () => updateButtonStates(2),
            icon: Icons.stop_circle,
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            label: 'Manual',
            isToggled: isButton3Toggled,
            onPressed: () {
              updateButtonStates(3);
              _navigateToPage('Manual', context);
            },
            icon: Icons.handyman,
          ),
          const SizedBox(height: 24),
          _buildConcentrationPanel(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required bool isToggled,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isToggled
                  ? const Color(0xFF66C7C7)
                  : Colors.grey.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isToggled ? 'ON' : 'OFF',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcentrationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.science,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Concentration Control',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.0,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildConcentrationOption('0.45%'),
              _buildConcentrationOption('0.95%'),
              _buildConcentrationOption('3%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConcentrationOption(String concentration) {
    final isSelected = selectedConcentration == concentration;
    return ElevatedButton(
      onPressed: () => updateConcentration(concentration),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF66C7C7) : Colors.grey.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        concentration,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  void _navigateToPage(String route, BuildContext context) {
    switch (route) {
      case 'Home':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
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
      case 'Manual':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManualModePage(
              selectedModule: 0,
              onModuleChanged: (module) {
                // handle module change
              },
              onStatusChanged: (status) {
                // handle status change
              },
            ),
          ),
        );
        break;
      default:
        print('Unknown route: $route');
        break;
    }
  }
}
