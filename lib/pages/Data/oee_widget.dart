import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OEEWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const OEEWidget({Key? key, required this.databaseReference})
      : super(key: key);

  Color _getOEEColor(dynamic oeeValue) {
    double value = double.tryParse(oeeValue.toString()) ?? 0;
    if (value >= 85) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getOEEStatus(dynamic oeeValue) {
    double value = double.tryParse(oeeValue.toString()) ?? 0;
    if (value >= 85) return 'Excellent Performance';
    if (value >= 60) return 'Average Performance';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').child('OEE').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final oeeValue = snapshot.data!.snapshot.value;
          final color = _getOEEColor(oeeValue);

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  '${oeeValue.toString()}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getOEEStatus(oeeValue),
                    style: TextStyle(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey),
            ),
            child: const Text(
              'No OEE data available',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class OEEDetailsWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const OEEDetailsWidget({Key? key, required this.databaseReference})
      : super(key: key);

  String _getOEEStatus(dynamic oeeValue) {
    double value = double.tryParse(oeeValue.toString()) ?? 0;
    if (value >= 85) return 'Excellent Performance';
    if (value >= 60) return 'Average Performance';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').child('OEE').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Card(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loading OEE details...',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
          );
        }

        final oeeValue = snapshot.data!.snapshot.value;
        return Card(
          elevation: 0,
          color: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'OEE Details:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OEE Value: ${oeeValue.toString()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Status: ${_getOEEStatus(oeeValue)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
