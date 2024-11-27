import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/controls/control_buttons.dart';
import 'package:mpbasic/pages/controls/led_with_label.dart';
import 'package:mpbasic/pages/controls/module_page.dart';
import 'package:mpbasic/pages/controls/module_card.dart';

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
        {'title': 'Overview'},
        {'title': 'Water Level'},
      ]
    },
    {
      'title': 'Dosing Process',
      'moduleNumber': 2,
      'subpages': [
        {'title': 'Diluent'},
        {'title': 'Stock'},
        {'title': 'Water Level'},
      ]
    },
    {
      'title': 'Mixer Process',
      'moduleNumber': 3,
      'subpages': [
        {'title': 'Overview'},
      ]
    },
    {
      'title': 'Filling Process',
      'moduleNumber': 4,
      'subpages': [
        {'title': 'Overview'},
        {'title': 'Bottles'},
      ]
    },
    {
      'title': 'Testing Process',
      'moduleNumber': 5,
      'subpages': [
        {'title': 'Overview'},
      ]
    },
    {
      'title': 'Waste Tank',
      'moduleNumber': 6,
      'subpages': [
        {'title': 'Overview'},
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

      Timer(const Duration(seconds: 30), () {
        _blinkTimer?.cancel();
        setState(() {
          _isBlinking = false;
          _bottlesReplaced = true;
        });
      });
    }
  }

  void _handleStartProcess() {
    if (_bottlesReplaced) {
      setState(() {
        _bottlesReplaced = false;
      });

      _filledTimer = Timer(const Duration(seconds: 25), () {
        setState(() {
          _bottlesFilled = true;
        });
      });
    }
  }

  void _handleStop() {
    _blinkTimer?.cancel();
    _filledTimer?.cancel();
    setState(() {
      _isBlinking = false;
      _bottlesReplaced = false;
      _bottlesFilled = false;
    });
  }

  void _handleOpenValve() {
    widget.onStatusChanged('Open Valve');
  }

  void _handleCloseValve() {
    widget.onStatusChanged('Close Valve');
  }

  void _handleOpenV18Valve() {
    widget.onStatusChanged('Open V18 Valve');
  }

  void _handleCloseV18Valve() {
    widget.onStatusChanged('Close V18 Valve');
  }

  void _handleOpenV19Valve() {
    widget.onStatusChanged('Open V19 Valve');
  }

  void _handleCloseV19Valve() {
    widget.onStatusChanged('Close V19 Valve');
  }

  void _handleStart() {
    widget.onStatusChanged('Start');
    _handleStartProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
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
      ),
      body: Stack(
        children: [
          const BackgroundWidget(),
          TabBarView(
            controller: _tabController,
            children:
                _modules.map((module) => _buildModulePage(module)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModulePage(Map<String, dynamic> module) {
    return DefaultTabController(
      length: module['subpages'].length,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: module['subpages']
                  .map<Widget>((subpage) => Tab(
                        text: subpage['title'],
                        height: 40,
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: module['subpages']
                  .map<Widget>((subpage) => _buildSubPage(
                      subpage, module['title'], module['moduleNumber']))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPage(
      Map<String, dynamic> subpage, String moduleTitle, int moduleNumber) {
    switch (subpage['title']) {
      case 'Diluent':
        return _buildDiluentPage();
      case 'Stock':
        return _buildStockPage();
      case 'Water Level':
        return _buildWaterLevelPage();
      case 'Mixer':
        return _buildMixerPage();
      case 'Bottles':
        return _buildBottlesPage();
      default:
        return _buildOverviewPage(moduleTitle, moduleNumber);
    }
  }

  Widget _buildOverviewPage(String moduleTitle, int moduleNumber) {
    return ModulePage(
      moduleTitle: moduleTitle,
      moduleNumber: moduleNumber,
      moduleContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          if (moduleNumber == 3) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement Mixer functionality
                  },
                  child: const Text('Mixer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement Pump functionality
                  },
                  child: const Text('Pump'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _handleOpenValve,
                      child: const Text('Open Valve'),
                    ),
                    ElevatedButton(
                      onPressed: _handleCloseValve,
                      child: const Text('Close Valve'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _handleOpenValve,
                      child: const Text('Open Valve'),
                    ),
                    ElevatedButton(
                      onPressed: _handleCloseValve,
                      child: const Text('Close Valve'),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (moduleNumber == 5) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _handleOpenV18Valve,
                  child: const Text('Open V18 Valve'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _handleCloseV18Valve,
                  child: const Text('Close V18 Valve'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _handleOpenV19Valve,
                  child: const Text('Open V19 Valve'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _handleCloseV19Valve,
                  child: const Text('Close V19 Valve'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          if (moduleNumber != 5)
            ControlButtons(
              onOpenValve: _handleOpenValve,
              onCloseValve: _handleCloseValve,
            ),
        ],
      ),
      bottomButton: moduleNumber == 4 ? null : null,
    );
  }

  Widget _buildDiluentPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleCard(
            title: 'Diluent Control',
            child: Column(
              // Add your Diluent Control content here
            ),
          ),
          const SizedBox(height: 20),
          ControlButtons(
            onOpenValve: _handleOpenValve,
            onCloseValve: _handleCloseValve,
          ),
        ],
      ),
    );
  }

  Widget _buildStockPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleCard(
            title: 'Stock Solution Control',
            child: Column(
              // Add your Stock Solution Control content here
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement Mixer functionality
                },
                child: const Text('Mixer'),
              ),
              ControlButtons(
                onOpenValve: _handleOpenValve,
                onCloseValve: _handleCloseValve,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMixerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement Mixer functionality
                },
                child: const Text('Mixer'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement Pump functionality
                },
                child: const Text('Pump'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _handleOpenValve,
                    child: const Text('Open Valve'),
                  ),
                  ElevatedButton(
                    onPressed: _handleCloseValve,
                    child: const Text('Close Valve'),
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _handleOpenValve,
                    child: const Text('Open Valve'),
                  ),
                  ElevatedButton(
                    onPressed: _handleCloseValve,
                    child: const Text('Close Valve'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottlesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(10, (index) {
          return ModuleCard(
            title: 'Bottle ${index + 1}',
            child: BottleButton(
              index: index,
              onStatusChanged: widget.onStatusChanged,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWaterLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleCard(
            title: 'Water Level Control',
            child: Column(
              // Add your Water Level Control content here
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BottleButton extends StatefulWidget {
  final int index;
  final Function(String) onStatusChanged;

  const BottleButton({
    Key? key,
    required this.index,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _BottleButtonState createState() => _BottleButtonState();
}

class _BottleButtonState extends State<BottleButton> {
  bool _isOpen = false;

  void _toggleValve() {
    setState(() {
      _isOpen = !_isOpen;
      widget.onStatusChanged(
          'Valve for Bottle ${widget.index + 1} ${_isOpen ? 'Open' : 'Close'}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleValve,
      child: Text(
          '${_isOpen ? 'Close' : 'Open'} Valve for Bottle ${widget.index + 1}'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ManualModePage(
      selectedModule: 0,
      onModuleChanged: (index) {},
      onStatusChanged: (status) {},
    ),
  ));
}