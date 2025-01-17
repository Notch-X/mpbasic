import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CO2Widget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const CO2Widget({super.key, required this.databaseReference});

  Color _getCO2Color(dynamic value) {
    double co2Value = double.tryParse(value.toString()) ?? 0;
    if (co2Value <= 50) return Colors.green;
    if (co2Value <= 100) return Colors.orange;
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

          final co2TotalValue = data['CO2 Total'] ?? 0;
          final color = _getCO2Color(co2TotalValue);

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
                  'CO2 Total',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${co2TotalValue.toString()} kg',
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

class CO2DetailsWidget extends StatelessWidget {
  final DatabaseReference databaseReference;

  const CO2DetailsWidget({super.key, required this.databaseReference});

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
                'Loading CO2 details...',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
          );
        }

        final data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final co2Water = (data['CO2 Water'] ?? 0).toStringAsFixed(2);
        final co2EnergyValue = (data['CO2 Energy'] ?? 0).toStringAsFixed(2);
        final co2CompAirValue = (data['CO2 Comp Air'] ?? 0).toStringAsFixed(2);
        final co2TotalValue = (data['CO2 Total'] ?? 0).toStringAsFixed(2);

        return SingleChildScrollView(
          child: Card(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Breakdown of CO2 Total',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Breakdown with Visual Addition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // CO2 Water
                      _buildBreakdownColumn(
                        label: 'CO2 Water',
                        value: co2Water,
                        color: Colors.blue,
                        icon: Icons.water_drop_outlined,
                      ),
                      // Plus Sign
                      const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // CO2 Energy
                      _buildBreakdownColumn(
                        label: 'CO2 Energy',
                        value: co2EnergyValue,
                        color: Colors.green,
                        icon: Icons.electrical_services_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // CO2 Comp Air
                      _buildBreakdownColumn(
                        label: 'CO2 Comp Air',
                        value: co2CompAirValue,
                        color: Colors.orange,
                        icon: Icons.air_outlined,
                      ),
                      // Equals Sign
                      const Text(
                        '=',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Total Column (Repeated for Symmetry)
                      _buildBreakdownColumn(
                        label: 'CO2 Total',
                        value: co2TotalValue,
                        color: Colors.red,
                        icon: Icons.calculate_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to create consistent column layout
  Widget _buildBreakdownColumn({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          '$value kg',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
