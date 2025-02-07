import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class EnvironmentMonitorWidget extends StatelessWidget {
  final DatabaseReference databaseReference;
  const EnvironmentMonitorWidget({super.key, required this.databaseReference});

  Color _getTemperatureColor(dynamic value) {
    double temperatureValue = double.tryParse(value.toString()) ?? 0;
    if (temperatureValue <= 0) return Colors.blue;
    if (temperatureValue <= 10) return Colors.green;
    if (temperatureValue <= 20) return Colors.yellow;
    if (temperatureValue <= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getPHColor(dynamic value) {
    double phValue = double.tryParse(value.toString()) ?? 0;
    if (phValue >= 6.5 && phValue <= 8.5) return Colors.green;
    if (phValue >= 5 && phValue < 6.5) return Colors.yellow;
    if (phValue >= 8.5 && phValue <= 10) return Colors.blue;
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

        // Extract temperature value directly like pH
        final tempData = data['Temperature'];
        final double tempDouble = double.tryParse(tempData.toString()) ?? 0.0;

        // Extract pH value
        final phData = data['pH'];
        final double phDouble = double.tryParse(phData.toString()) ?? 0.0;

        // Format to 2 decimal places
        final formattedTemp = tempDouble.toStringAsFixed(2);
        final formattedPH = phDouble.toStringAsFixed(2);

        final temperatureColor = _getTemperatureColor(tempDouble);
        final phColor = _getPHColor(phDouble);

        return Row(
          children: [
            // Temperature
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      temperatureColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: temperatureColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Temperature',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${formattedTemp}°C',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: temperatureColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // pH
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      phColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: phColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'pH',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formattedPH,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: phColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              phColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment(
                              ((phDouble - 5) / 5).clamp(-1.0, 1.0), 0),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: phColor,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TempPHDetailsWidget extends StatefulWidget {
  final DatabaseReference databaseReference;
  const TempPHDetailsWidget({super.key, required this.databaseReference});

  @override
  _TempPHDetailsWidgetState createState() => _TempPHDetailsWidgetState();
}

class _TempPHDetailsWidgetState extends State<TempPHDetailsWidget> {
  final List<TemperatureData> _temperatureData = [];
  final List<PHData> _phData = [];
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

        // Parse temperature directly like pH
        final tempData = data['Temperature'];
        final double tempDouble = double.tryParse(tempData.toString()) ?? 0.0;

        // Parse pH
        final phData = data['pH'];
        final double phDouble = double.tryParse(phData.toString()) ?? 0.0;

        final now = DateTime.now();

        setState(() {
          _addDataPoint(_temperatureData, now, tempDouble, 50);
          _addDataPoint(_phData, now, phDouble, 50);
        });

        _logEnvironmentData(tempDouble, phDouble);
      }
    });

    _loggingTimer = Timer.periodic(const Duration(seconds: 3), (_) {});
  }

  void _addDataPoint(
      List<dynamic> dataList, DateTime timestamp, double value, int maxPoints) {
    dataList.add(dataList == _temperatureData
        ? TemperatureData(timestamp, value)
        : PHData(timestamp, value));

    if (dataList.length > maxPoints) {
      dataList.removeAt(0);
    }
  }

  void _logEnvironmentData(double temperature, double ph) {
    widget.databaseReference.child('environment_history').push().set({
      'timestamp': ServerValue.timestamp,
      'Temperature': temperature.toStringAsFixed(2),
      'pH': ph.toStringAsFixed(2),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildChart(
            title: 'Temperature Over Time',
            data: _temperatureData,
            color: Colors.red,
            yAxisLabel: 'Temperature (°C)',
            unit: '°C',
          ),
          const SizedBox(height: 16),
          _buildChart(
            title: 'pH Level Over Time',
            data: _phData,
            color: Colors.blue,
            yAxisLabel: 'pH Level',
            unit: '',
          ),
        ],
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required List<dynamic> data,
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
            horizontalInterval: data == _temperatureData ? 5 : 0.5,
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
                interval: data == _temperatureData ? 5 : 0.5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(2) + unit,
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

class TemperatureData {
  final DateTime timestamp;
  final double value;

  TemperatureData(this.timestamp, this.value);
}

class PHData {
  final DateTime timestamp;
  final double value;

  PHData(this.timestamp, this.value);
}
