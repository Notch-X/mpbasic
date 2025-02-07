import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const DashboardWidget({
    super.key,
    required this.databaseReference,
  });

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final set =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottle Efficiency Section
              const Text(
                'Bottle Efficiency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                  'Good Bottles',
                  set['Good Bottles']?.toString() ?? '0',
                  FontAwesomeIcons
                      .bottleWater, // This will give you a bottle icon
                  Colors.green),
              const SizedBox(height: 8),
              _buildMetricCard(
                  'Bad Bottles',
                  set['Bad Bottles']?.toString() ?? '0',
                  FontAwesomeIcons
                      .bottleWater, // This will give you a bottle icon
                  Colors.red),

              // Resources Section
              const SizedBox(height: 24),
              const Text(
                'Resources',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'Total Energy',
                '${(set['kWh'] ?? 0.0).toStringAsFixed(2)} kWh',
                Icons.bolt,
                Colors.yellow,
              ),

              const SizedBox(height: 8),
              _buildMetricCard(
                  'Total Compressed Air',
                  '${(set['Total Compressed Air'] ?? 0.0).toStringAsFixed(2)} Pa',
                  Icons.air,
                  Colors.blue),

              // Carbon Impact Section
              const SizedBox(height: 24),
              const Text(
                'Carbon Impact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                  'Carbon Expense',
                  '${(set['kWh Cost'] ?? 0.0).toStringAsFixed(2)} SGD',
                  Icons.attach_money,
                  Colors.green),
              const SizedBox(height: 8),
              _buildMetricCard(
                  'Carbon Emission',
                  '${(set['CO2 Total'] ?? 0.0).toStringAsFixed(2)} TONS',
                  Icons.cloud,
                  Colors.grey),

              // Performance Indicators
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Equipment Effectiveness (OEE)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPerformanceIndicator(
                          'Availability',
                          double.parse(
                              (set['Availability'] ?? 0.0).toStringAsFixed(2)),
                          Colors.green,
                        ),
                        _buildPerformanceIndicator(
                          'Performance',
                          double.parse(
                              (set['Performance'] ?? 0.0).toStringAsFixed(2)),
                          Colors.blue,
                        ),
                        _buildPerformanceIndicator(
                          'Quality',
                          double.parse(
                              (set['Quality'] ?? 0.0).toStringAsFixed(2)),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
