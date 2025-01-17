import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AvailabilityWidget extends StatelessWidget {
  final DatabaseReference databaseReference;
  const AvailabilityWidget({super.key, required this.databaseReference});
  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  Color _getAvailabilityColor(dynamic value) {
    double availabilityValue = double.tryParse(value.toString()) ?? 0;
    if (availabilityValue >= 85) return Colors.green;
    if (availabilityValue >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').onValue,
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
        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          final data =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final availabilityValue = data['Availability'] ?? 0;
          final color = _getAvailabilityColor(availabilityValue);
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
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${availabilityValue.toString()}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}

class AvailabilityDetailsWidget extends StatelessWidget {
  final DatabaseReference databaseReference;
  const AvailabilityDetailsWidget({super.key, required this.databaseReference});
  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Card(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Loading availability details...',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
          );
        }
        final data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final runTime = (data['RunTime'] ?? 0).toInt();
        final idleDurationTime = (data['Ideal Duration'] ?? 0).toInt();
        return Card(
          elevation: 0,
          color: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Runtime Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Run Time',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatDuration(runTime),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ideal Duration',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatDuration(idleDurationTime),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Availability = (Run Time / Ideal Duration) × 100%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
