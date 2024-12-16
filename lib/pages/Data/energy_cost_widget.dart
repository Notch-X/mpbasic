import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EnergyCostWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const EnergyCostWidget({Key? key, required this.databaseReference})
      : super(key: key);

  Color _getECostColor(dynamic value) {
    double eCostVal = double.tryParse(value.toString()) ?? 0;
    if (eCostVal <= 50) return Colors.green;
    if (eCostVal <= 100) return Colors.orange;
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

          final eCost = data['kWh Cost'] ?? 0;
          final color = _getECostColor(eCost);

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
                  'Energy Cost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${eCost.toString()} SGD',
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

class EDetailsWidget extends StatelessWidget {
  final DatabaseReference databaseReference;
  const EDetailsWidget({Key? key, required this.databaseReference})
      : super(key: key);

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
                  'Energy Cost Details',
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
                          'Energy Cost is the cost per kWh',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}