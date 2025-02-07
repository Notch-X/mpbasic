import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class OEEWidget extends StatelessWidget {
  final DatabaseReference databaseReference;
  const OEEWidget({super.key, required this.databaseReference});

  Color _getOEEColor(dynamic value) {
    double oeeValue = double.tryParse(value.toString()) ?? 0;
    if (oeeValue >= 85) return Colors.green;
    if (oeeValue >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.child('set').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
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

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        }

        // Safe data parsing
        final data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        // Extract OEE value
        final oeeData = data['OEE'];
        final double oeeDouble = double.tryParse(oeeData.toString()) ?? 0.0;

        // Format to 2 decimal places
        final formattedOEE = oeeDouble.toStringAsFixed(2);

        final oeeColor = _getOEEColor(oeeDouble);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                oeeColor.withOpacity(0.1),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: oeeColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'OEE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${formattedOEE}%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: oeeColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OEEDetailsWidget extends StatefulWidget {
  final DatabaseReference databaseReference;
  const OEEDetailsWidget({super.key, required this.databaseReference});

  @override
  _OEEDetailsWidgetState createState() => _OEEDetailsWidgetState();
}

class _OEEDetailsWidgetState extends State<OEEDetailsWidget> {
  final List<OEEDataPoint> _oeeData = [];
  Timer? _loggingTimer;
  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _startContinuousLogging();
  }

  void _startContinuousLogging() {
    _dataSubscription =
        widget.databaseReference.child('set').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        final oeeData = data['OEE'];
        final double oeeDouble = double.tryParse(oeeData.toString()) ?? 0.0;

        final now = DateTime.now();

        setState(() {
          _addDataPoint(_oeeData, now, oeeDouble, 50);
        });

        _logOEEData(oeeDouble);
      }
    });

    _loggingTimer = Timer.periodic(const Duration(seconds: 3), (_) {});
  }

  void _addDataPoint(List<OEEDataPoint> dataList, DateTime timestamp,
      double value, int maxPoints) {
    dataList.add(OEEDataPoint(timestamp, value));
    if (dataList.length > maxPoints) {
      dataList.removeAt(0);
    }
  }

  void _logOEEData(double oeeValue) {
    widget.databaseReference.child('oee_history').push().set({
      'timestamp': ServerValue.timestamp,
      'value': oeeValue.toStringAsFixed(2),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildChart(
        title: 'OEE Over Time',
        data: _oeeData,
        color: Colors.blue,
        yAxisLabel: 'OEE Value',
        unit: '%',
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required List<OEEDataPoint> data,
    required Color color,
    required String yAxisLabel,
    required String unit,
  }) {
    if (data.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Center(
          child: Text(
            'Waiting for data...',
            style: TextStyle(color: color, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return const Text('');
                  final DateTime timestamp = data[value.toInt()].timestamp;
                  return Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0) + unit,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white10),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.value,
                );
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.7),
                  color,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: color.withOpacity(0.8),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loggingTimer?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }
}

class OEEDataPoint {
  final DateTime timestamp;
  final double value;

  OEEDataPoint(this.timestamp, this.value);
}
