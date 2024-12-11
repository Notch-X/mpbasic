import 'package:flutter/material.dart';

class ControlButtons extends StatefulWidget {
  final VoidCallback onOpenValve;
  final VoidCallback onCloseValve;

  const ControlButtons({
    Key? key,
    required this.onOpenValve,
    required this.onCloseValve,
  }) : super(key: key);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  bool _isOpen = false;

  void _toggleValve() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      widget.onOpenValve();
    } else {
      widget.onCloseValve();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildStyledButton(
            label: _isOpen ? 'Close Valve' : 'Open Valve',
            onPressed: _toggleValve,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF66C7C7), Color(0xFF009688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF66C7C7).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
          elevation: 6.0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
