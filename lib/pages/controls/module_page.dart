import 'package:flutter/material.dart';

class ModulePage extends StatelessWidget {
  final String moduleTitle;
  final int moduleNumber;
  final Widget moduleContent;
  final Widget? bottomButton;

  const ModulePage({
    Key? key,
    required this.moduleTitle,
    required this.moduleNumber,
    required this.moduleContent,
    this.bottomButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildModuleDiagram(moduleTitle),
              moduleContent,
              if (moduleNumber == 4) const SizedBox(height: 80),
            ],
          ),
        ),
        if (bottomButton != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: bottomButton!,
          ),
      ],
    );
  }

  Widget _buildModuleDiagram(String moduleTitle) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          moduleTitle,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
