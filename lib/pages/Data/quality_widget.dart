import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class QualityWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const QualityWidget({required this.databaseReference, Key? key})
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
          final qualityValue = data['Quality'] ?? 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quality Rate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getQualityColor(qualityValue),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${qualityValue.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getQualityColor(qualityValue),
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

  Color _getQualityColor(dynamic value) {
    double qualityValue = double.tryParse(value.toString()) ?? 0;
    if (qualityValue >= 95) return Colors.green;
    if (qualityValue >= 85) return Colors.orange;
    return Colors.red;
  }
}
