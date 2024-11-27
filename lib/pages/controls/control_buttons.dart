import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onOpenValve;
  final VoidCallback onCloseValve;

  const ControlButtons({
    Key? key,
    required this.onOpenValve,
    required this.onCloseValve,
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
        ],
      ),
    );
  }
}
