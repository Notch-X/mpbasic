import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mpbasic/Manual/diluent_mixer.dart';
import 'package:mpbasic/Manual/diluent_valve.dart';
import 'package:mpbasic/Manual/mixer_bottle.dart';
import 'package:mpbasic/Manual/mixer_pump.dart';
import 'package:mpbasic/Manual/mixer_tank.dart';
import 'package:mpbasic/Manual/mixer_output.dart';
import 'package:mpbasic/Manual/stock_mixer.dart';
import 'package:mpbasic/Manual/stock_valve.dart';
import 'package:mpbasic/Manual/supply_valve.dart';
import 'package:mpbasic/Manual/bottle_valve1.dart';
import 'package:mpbasic/Manual/bottle_valve2.dart';
import 'package:mpbasic/Manual/bottle_valve3.dart';
import 'package:mpbasic/Manual/bottle_valve4.dart';
import 'package:mpbasic/Manual/bottle_valve5.dart';
import 'package:mpbasic/Manual/bottle_valve6.dart';
import 'package:mpbasic/Manual/bottle_valve7.dart';
import 'package:mpbasic/Manual/bottle_valve8.dart';
import 'package:mpbasic/Manual/bottle_valve9.dart';
import 'package:mpbasic/Manual/bottle_valve10.dart';
import 'package:mpbasic/Manual/v18_valve.dart';
import 'package:mpbasic/Manual/v19_valve.dart';
import 'package:mpbasic/Manual/bottle_tray.dart';

class ManualModePage extends StatefulWidget {
  final Function(String)? onStatusChanged;

  const ManualModePage({
    super.key,
    this.onStatusChanged,
    required int selectedModule,
    required Null Function(dynamic module) onModuleChanged,
  });

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
      'controls': [
        'Diluent Mixer Valve',
        'Stock Mixer Valve',
        'Mixer Tank Valve',
        'Mixer',
        'Mixer Output Valve'
      ]
    },
    {
      'id': 4,
      'title': 'Filling Process',
      'controls': [
        'V16 Valve',
        'Pump',
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
      'controls': ['Waste Valve 1']
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

    // Send the state to Flask only for specific controls
   if (moduleId == 1 && control == 'Supply Valve') {
      sendSupplyValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 2 && control == 'Stock Valve') {
      sendStockValveStateToFlask(control, controlStates[key] ?? false, context);
    } else if (moduleId == 2 && control == 'Diluent Valve') {
      sendDiluentValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 2 && control == 'Stock Mixer Valve') {
      sendStockMixerValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 3 && control == 'Diluent Mixer Valve') {
      sendDiluentMixerValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 3 && control == 'Stock Mixer Valve') {
      sendStockMixerValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 3 && control == 'Mixer Tank Valve') {
      sendMixerTankValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 3 && control == 'Mixer Output Valve') {
      sendMixerOutputValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Pump') {
      sendMixerPumpStateToFlask(control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'V16 Valve') {
      sendMixerBottleValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 1') {
      sendBottleValve1StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 2') {
      sendBottleValve2StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 3') {
      sendBottleValve3StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 4') {
      sendBottleValve4StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 5') {
      sendBottleValve5StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 6') {
      sendBottleValve6StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 7') {
      sendBottleValve7StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 8') {
      sendBottleValve8StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 9') {
      sendBottleValve9StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 4 && control == 'Bottle 10') {
      sendBottleValve10StateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 5 && control == 'V18 Valve') {
      sendV18ValveStateToFlask(
         control, controlStates[key] ?? false, context);
    } else if (moduleId == 5 && control == 'V19 Valve') {
      sendV19ValveStateToFlask(
          control, controlStates[key] ?? false, context);
    } else if (moduleId == 6 && control == 'Bottle Tray') {
      sendBottleTrayStateToFlask(
          control, controlStates[key] ?? false, context);
    }
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
        // V16 Valve Control
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
                'V16 Valve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              _buildValveButton('V16 Valve'),
            ],
          ),
        ),
        // Pump Control
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
                'Pump',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              _buildValveButton('Pump'),
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
