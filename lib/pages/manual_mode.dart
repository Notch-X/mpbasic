import 'package:flutter/material.dart';

class ManualModePage extends StatefulWidget {
  final Function(String)? onStatusChanged;

  const ManualModePage({
    Key? key,
    this.onStatusChanged,
    required int selectedModule,
    required Null Function(dynamic module) onModuleChanged,
  }) : super(key: key);

  @override
  State<ManualModePage> createState() => _ManualModePageState();
}

class _ManualModePageState extends State<ManualModePage> {
  int? activeModule;
  Map<String, bool> controlStates = {};

  final List<Map<String, dynamic>> modules = [
    {
      'id': 1,
      'title': 'Water Supply',
      'controls': ['Supply Valve']
    },
    {
      'id': 2,
      'title': 'Dosing Process',
      'controls': ['Diluent Valve', 'Stock Valve', 'Stock Mixer Valve']
    },
    {
      'id': 3,
      'title': 'Mixer Process',
      'controls': ['Valve 1', 'Valve 2', 'Valve 3', 'Mixer', 'Pump']
    },
    {
      'id': 4,
      'title': 'Filling Process',
      'controls': [
        'Filling Valve',
        'Bottle 1',
        'Bottle 2',
        'Bottle 3',
        'Bottle 4',
        'Bottle 5',
        'Bottle 6',
        'Bottle 7',
        'Bottle 8',
        'Bottle 9',
        'Bottle 10'
      ]
    },
    {
      'id': 5,
      'title': 'Testing Process',
      'controls': ['V18 Valve', 'V19 Valve']
    },
    {
      'id': 6,
      'title': 'Waste Tank',
      'controls': ['Waste Valve 1', 'Waste Valve 2']
    }
  ];

  void handleControlToggle(int moduleId, String control) {
    final key = '$moduleId-$control';
    setState(() {
      controlStates[key] = !(controlStates[key] ?? false);
    });

    String status =
        '$control: ${(controlStates[key] ?? false) ? "OPEN" : "CLOSE"}';
    if (control == 'Mixer' || control == 'Pump') {
      status = '$control: ${(controlStates[key] ?? false) ? "ON" : "OFF"}';
    }

    widget.onStatusChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Manual Control Mode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blue.shade900.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildModuleGrid(),
                const SizedBox(height: 24),
                if (activeModule != null) _buildControlPanel(),
                if (activeModule == null) _buildNoSelectionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        final isActive = activeModule == module['id'];

        return InkWell(
          onTap: () => setState(() => activeModule = module['id']),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF66C7C7)
                  : const Color(0xFF66C7C7).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: const Color(0xFF66C7C7).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  module['title'],
                  style: TextStyle(
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Module ${module['id']}',
                  style: TextStyle(
                    color: isActive ? Colors.white70 : Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlPanel() {
    final selectedModule = modules.firstWhere((m) => m['id'] == activeModule);
    final controls = selectedModule['controls'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedModule['title']} Controls',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (activeModule == 4)
            _buildBottleGrid(controls)
          else
            _buildStandardControls(controls),
        ],
      ),
    );
  }

  Widget _buildStandardControls(List<String> controls) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controls.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final control = controls[index];
        final controlKey = '$activeModule-$control';
        final isActive = controlStates[controlKey] ?? false;

        String buttonText = isActive ? 'OPEN' : 'CLOSE';
        if (control == 'Mixer' || control == 'Pump') {
          buttonText = isActive ? 'ON' : 'OFF';
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                control,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                onPressed: () => handleControlToggle(activeModule!, control),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? const Color(0xFF66C7C7)
                      : Colors.grey.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottleGrid(List<String> controls) {
    return Column(
      children: [
        // Main Valve Control
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Main Valve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              _buildValveButton('Main Valve'),
            ],
          ),
        ),
        // Bottle Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final control = 'Bottle ${index + 1}';
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    control,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  _buildValveButton(control),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildValveButton(String control) {
    final controlKey = '$activeModule-$control';
    final isActive = controlStates[controlKey] ?? false;

    return ElevatedButton(
      onPressed: () => handleControlToggle(activeModule!, control),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? const Color(0xFF66C7C7) : Colors.grey.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isActive ? 'OPEN' : 'CLOSE',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNoSelectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Select a module to access its controls',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
