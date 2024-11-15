import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environmental Impact Section
          const Text(
            'Environmental Impact',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricCard('Trees', '90', Icons.park, Colors.green),
          const SizedBox(height: 8),
          _buildMetricCard(
              'Wildlife Affected', '18', Icons.pets, Colors.orange),

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
              'Total Energy', '415 kWh', Icons.bolt, Colors.yellow),
          const SizedBox(height: 8),
          _buildMetricCard('Total Air', '0 L/min', Icons.air, Colors.blue),

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
              'Carbon Expense', '12.0 SGD', Icons.attach_money, Colors.green),
          const SizedBox(height: 8),
          _buildMetricCard(
              'Carbon Emission', '2.4 TONS', Icons.cloud, Colors.grey),

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
                    _buildPerformanceIndicator('Dosing', 75, Colors.green),
                    _buildPerformanceIndicator('Mixing', 55, Colors.blue),
                    _buildPerformanceIndicator('Brewing', 75, Colors.orange),
                    _buildPerformanceIndicator('Filling', 65, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
