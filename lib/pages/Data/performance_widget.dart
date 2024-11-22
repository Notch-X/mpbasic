import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PerformanceWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const PerformanceWidget({required this.databaseReference, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final performanceValue = data['Performance'] ?? 0;
          final color = _getPerformanceColor(performanceValue);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Performance Rate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${performanceValue.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  Color _getPerformanceColor(dynamic value) {
    double performanceValue = double.tryParse(value.toString()) ?? 0;
    if (performanceValue >= 95) return Colors.green;
    if (performanceValue >= 85) return Colors.orange;
    return Colors.red;
  }
}
