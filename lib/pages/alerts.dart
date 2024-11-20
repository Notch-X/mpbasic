import 'package:flutter/material.dart';
import 'package:mpbasic/models/category_model.dart';
// import 'package:mpbasic/pages/UI/UX/background_widget.dart';
// import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
// import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:firebase_database/firebase_database.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  void _getCategories() {
    categories = CategoryModel.getCategories();
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
      appBar: AppBar(
        title: Text('AI Chatbot Page'),
      ),
      body: StreamBuilder(
        stream: _databaseReference
            .child('set')
            .onValue, // Replace 'your-node-name' with your actual node
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.snapshot.value;
            // Assuming your data is a Map, or adjust this according to your data structure.
            return ListView.builder(
              itemCount: (data as Map).length,
              itemBuilder: (context, index) {
                String key = (data as Map).keys.elementAt(index);
                var value = (data as Map)[key];
                return ListTile(
                  title: Text(key), // Use data as per your need
                  subtitle: Text(value.toString()),
                );
              },
            );
          }

          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Alerts',
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
    );
  }
}
