import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final databaseRef = FirebaseDatabase.instance.ref(); // Get a database reference

Future<void> fetchData() async {
  final snapshot = await databaseRef.child('').get();
  if (snapshot.exists) {
    print(snapshot.value); // Access the data
  } else {
    print('No data available');
  }
}

Future<void> sendDataToGeminiAPI(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('https://your-gemini-api-endpoint.com/analyze'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    print('Data sent successfully: ${response.body}');
  } else {
    print('Failed to send data: ${response.statusCode}');
  }
}
