import 'dart:async';
import 'package:flutter/material.dart';

class ManualModePage extends StatefulWidget {
  final int selectedModule;
  final Function(int) onModuleChanged;
  final Function(String) onStatusChanged;

  const ManualModePage({
    super.key,
    required this.selectedModule,
    required this.onModuleChanged,
    required this.onStatusChanged,
  });

  @override
  State<ManualModePage> createState() => _ManualModePageState();
}

class _ManualModePageState extends State<ManualModePage>
    with SingleTickerProviderStateMixin {
  bool _bottlesReplaced = false;
  bool _bottlesFilled = false;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  Timer? _filledTimer;
  late TabController _tabController;

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Water Supply',
      'moduleNumber': 1,
      'subpages': [
        {'title': 'Overview', 'icon': Icons.dashboard_outlined},
        {'title': 'Water Level', 'icon': Icons.water},
      ]
    },
    {
      'title': 'Dosing Process',
      'moduleNumber': 2,
      'subpages': [
        {'title': 'Diluent', 'icon': Icons.science},
        {'title': 'Salt', 'icon': Icons.science},
        {'title': 'Water Level', 'icon': Icons.water},
      ]
    },
    {
      'title': 'Mixer Process',
      'moduleNumber': 3,
      'subpages': [
        {'title': 'Overview', 'icon': Icons.dashboard_outlined},
        {'title': 'Water Level', 'icon': Icons.water},
      ]
    },
    {
      'title': 'Filling Process',
      'moduleNumber': 4,
      'subpages': [
        {'title': 'Overview', 'icon': Icons.dashboard_outlined},
        {'title': 'Water Level', 'icon': Icons.water},
      ]
    },
    {
      'title': 'Waste Tank',
      'moduleNumber': 5,
      'subpages': [
        {'title': 'Overview', 'icon': Icons.dashboard_outlined},
        {'title': 'Water Level', 'icon': Icons.water},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _modules.length,
      vsync: this,
      initialIndex: widget.selectedModule,
    );
    _tabController.addListener(() {
      setState(() {
        widget.onModuleChanged(_tabController.index);
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _filledTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _handleBottlesReplaced() {
    if (!_isBlinking) {
      setState(() {
        _isBlinking = true;
        _bottlesReplaced = false;
        _bottlesFilled = false;
      });

      _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      });
    }
  }

  void _handleStartProcess() {
    if (_isBlinking) {
      _blinkTimer?.cancel();
      setState(() {
        _isBlinking = false;
        _bottlesReplaced = true;
      });

      _filledTimer = Timer(const Duration(seconds: 25), () {
        setState(() {
          _bottlesFilled = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _modules.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B4D4C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module ${_modules[_tabController.index]['moduleNumber']}: ${_modules[_tabController.index]['title']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: _modules.map((module) {
              return Tab(
                text: 'Module ${module['moduleNumber']}',
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _modules.map((module) => _buildModulePage(module)).toList(),
        ),
      ),
    );
  }

  Widget _buildModulePage(Map<String, dynamic> module) {
    return DefaultTabController(
      length: module['subpages'].length,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF1B4D4C),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1B4D4C),
              tabs: module['subpages']
                  .map<Widget>((subpage) => Tab(
                        text: subpage['title'],
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: module['subpages']
                  .map<Widget>(
                      (subpage) => _buildSubPage(subpage, module['title']))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPage(Map<String, dynamic> subpage, String moduleTitle) {
    if (subpage['title'] == 'Water Level') {
      return _buildWaterLevelPage();
    } else {
      return _buildOverviewPage(moduleTitle);
    }
  }

  Widget _buildWaterLevelPage() {
    return const Center(
      child: Text(
        'Water Level Information\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF1B4D4C),
        ),
      ),
    );
  }

  Widget _buildOverviewPage(String moduleTitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModuleDiagram(moduleTitle),
          if (moduleTitle == 'Filling Process') _buildBottleIndicators(),
          const SizedBox(height: 20),
          _buildControlButtons(moduleTitle == 'Filling Process'),
        ],
      ),
    );
  }

  Widget _buildModuleDiagram(String moduleTitle) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B4D4C).withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          moduleTitle,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF1B4D4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottleIndicators() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLEDWithLabel(
            'Bottles Filled',
            _bottlesFilled ? Colors.green : Colors.grey,
          ),
          _buildLEDWithLabel(
            'Bottles Replaced',
            _isBlinking
                ? Colors.orange
                : (_bottlesReplaced ? Colors.orange : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(bool showBottleIndicators) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildControlButton('Start Process', _handleStartProcess),
        _buildControlButton('Stop Process'),
        _buildControlButton('Open Valve'),
        _buildControlButton('Close Valve'),
        if (showBottleIndicators)
          _buildControlButton('Replace Bottles', _handleBottlesReplaced),
      ],
    );
  }

  Widget _buildControlButton(String label, [VoidCallback? onPressed]) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: ElevatedButton(
        onPressed: onPressed ??
            () {
              widget.onStatusChanged("$label initiated");
            },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4D4C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLEDWithLabel(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (color != Colors.grey)
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B4D4C),
          ),
        ),
      ],
    );
  }
}
