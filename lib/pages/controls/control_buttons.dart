import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onOpenValve;
  final VoidCallback onCloseValve;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ControlButtons({
    Key? key,
    required this.onOpenValve,
    required this.onCloseValve,
    required this.onStart,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onOpenValve,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Open Valve',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: onCloseValve,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Close Valve',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Start Process',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Stop Process',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
