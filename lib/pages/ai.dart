import 'package:mpbasic/models/category_model.dart';
// import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
// import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
// import 'package:mpbasic/pages/analytics.dart';
// import 'package:mpbasic/pages/process.dart';
// import 'package:mpbasic/pages/home.dart';
// import 'package:mpbasic/pages/alerts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  void _getCategories() {
    // Your implementation for fetching categories
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
}
