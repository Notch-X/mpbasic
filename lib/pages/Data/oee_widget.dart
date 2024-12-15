import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

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
                  '${oeeValue.toString()}',
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

class OEETimeSeriesWidget extends StatefulWidget {
  final DatabaseReference databaseReference;

  const OEETimeSeriesWidget({Key? key, required this.databaseReference})
      : super(key: key);

  @override
  _OEETimeSeriesWidgetState createState() => _OEETimeSeriesWidgetState();
}

class _OEETimeSeriesWidgetState extends State<OEETimeSeriesWidget> {
  final List<OEEDataPoint> _oeeDataPoints = [];
  Timer? _loggingTimer;
  StreamSubscription? _oeeSubscription;

  @override
  void initState() {
    super.initState();
    _startContinuousLogging();
  }

  void _startContinuousLogging() {
    // Start listening to OEE value changes
    _oeeSubscription = widget.databaseReference
        .child('set')
        .child('OEE')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final oeeValue =
            double.tryParse(event.snapshot.value.toString()) ?? 0.0;

        // Add new data point
        setState(() {
          _oeeDataPoints.add(OEEDataPoint(
            DateTime.now(),
            oeeValue,
          ));

          // Limit the number of data points to prevent memory issues
          if (_oeeDataPoints.length > 50) {
            _oeeDataPoints.removeAt(0);
          }
        });

        // Log the data to Firebase (optional)
        _logOEEData(oeeValue);
      }
    });

    // Set up a timer to ensure we're getting updates every 3 seconds
    _loggingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // You can add additional logging or refresh logic here if needed
    });
  }

  void _logOEEData(double oeeValue) {
    // Optional: Log historical data to a separate Firebase path
    widget.databaseReference.child('oee_history').push().set({
      'timestamp': ServerValue.timestamp,
      'value': oeeValue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OEE Time Series',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildOEEChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOEEChart() {
    if (_oeeDataPoints.isEmpty) {
      return const Center(
        child: Text(
          'Waiting for OEE data...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return LineChart(
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
                final DateTime timestamp =
                    _oeeDataPoints[value.toInt()].timestamp;
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
                  value.toStringAsFixed(0),
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
            spots: _oeeDataPoints.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade700,
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
                  strokeColor: Colors.blue.shade700,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade300.withOpacity(0.3),
                  Colors.blue.shade700.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loggingTimer?.cancel();
    _oeeSubscription?.cancel();
    super.dispose();
  }
}

class OEEDataPoint {
  final DateTime timestamp;
  final double value;

  OEEDataPoint(this.timestamp, this.value);
}
