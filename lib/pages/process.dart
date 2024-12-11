import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:mpbasic/pages/alerts.dart';
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

  Future<void> sendStateToFlask() async {
    try {
      // Use 10.0.2.2 for Android emulator
      // For physical device, use your computer's IP address
      final url = Uri.parse('http://10.0.2.2:5000');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'button1': isButton1Toggled,
          'button2': isButton2Toggled,
          'button3': isButton3Toggled,
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
    return SafeArea(
      child: Center(
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
                buildToggleButton(
                  label: 'Auto',
                  isToggled: isButton1Toggled,
                  onPressed: () => updateButtonStates(1),
                  icon: Icons.auto_mode,
                ),
                const SizedBox(height: 24),
                buildToggleButton(
                  label: 'Stop',
                  isToggled: isButton2Toggled,
                  onPressed: () => updateButtonStates(2),
                  icon: Icons.stop_circle,
                ),
                const SizedBox(height: 24),
                buildToggleButton(
                  label: 'Manual',
                  isToggled: isButton3Toggled,
                  onPressed: () {
                    updateButtonStates(3);
                    _navigateToPage('Manual', context);
                  },
                  icon: Icons.handyman,
                ),
                const SizedBox(height: 40),
              ],
            ),
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

  Widget buildToggleButton({
    required String label,
    required bool isToggled,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isToggled
                ? const Color(0xFF66C7C7).withOpacity(0.3)
                : Colors.transparent,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isToggled
              ? const Color(0xFF66C7C7)
              : const Color(0xFF66C7C7).withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isToggled ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              '$label: ${isToggled ? "ON" : "OFF"}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(String route, BuildContext context) {
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
