import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mpbasic/config.dart'; // Import the configuration file

Future<void> sendDiluentMixerValveStateToFlask(
    String control, bool state, BuildContext context) async {
  try {
    final url = Uri.parse(
        '${Config.baseUrl}/diluent_mixer'); // Use the baseUrl from the configuration file

    final response = await http
        .post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'control': control,
        'state': state,
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Diluent Mixer Valve control updated successfully')),
        );
      }
    } else {
      print('Failed to send data to Flask: ${response.statusCode}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update Diluent Mixer Valve control')),
        );
      }
    }
  } catch (e) {
    print('Error sending data to Flask: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Connection error. Please check if the server is running.'),
        ),
      );
    }
  }
}
