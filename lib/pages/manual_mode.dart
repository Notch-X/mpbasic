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

  void _handleOpenV18Valve() {
    widget.onStatusChanged('Open V18 Valve');
  }

  void _handleOpenV19Valve() {
    widget.onStatusChanged('Open V19 Valve');
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
                ToggleValveButton(
                  title: 'Mixer',
                  onStatusChanged: () {
                    // Implement Mixer functionality
                  },
                ),
                ToggleValveButton(
                  title: 'Pump',
                  onStatusChanged: () {
                    // Implement Pump functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ToggleValveButton(
                  title: 'Valve 1',
                  onStatusChanged: _handleOpenValve,
                ),
                ToggleValveButton(
                  title: 'Valve 2',
                  onStatusChanged: _handleOpenValve,
                ),
              ],
            ),
          ],
          if (moduleNumber == 5) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleValveButton(
                  title: 'V18 Valve',
                  onStatusChanged: _handleOpenV18Valve,
                  isSmall: true,
                ),
                const SizedBox(width: 20),
                ToggleValveButton(
                  title: 'V19 Valve',
                  onStatusChanged: _handleOpenV19Valve,
                  isSmall: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 20),
          if (moduleNumber != 5)
            ControlButtons(
              onOpenValve: _handleOpenValve,
              onCloseValve: () {},
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
            onCloseValve: () {},
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
              ToggleValveButton(
                title: 'Mixer',
                onStatusChanged: () {
                  // Implement Mixer functionality
                },
              ),
              ControlButtons(
                onOpenValve: _handleOpenValve,
                onCloseValve: () {},
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
              ToggleValveButton(
                title: 'Mixer',
                onStatusChanged: () {
                  // Implement Mixer functionality
                },
              ),
              ToggleValveButton(
                title: 'Pump',
                onStatusChanged: () {
                  // Implement Pump functionality
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ToggleValveButton(
                title: 'Valve 1',
                onStatusChanged: _handleOpenValve,
              ),
              ToggleValveButton(
                title: 'Valve 2',
                onStatusChanged: _handleOpenValve,
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          backgroundColor: const Color(0xFF66C7C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
          elevation: 6.0,
        ),
        onPressed: _toggleValve,
        child: Text(
          '${_isOpen ? 'Close' : 'Open'} Valve for Bottle ${widget.index + 1}',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}

class ToggleValveButton extends StatefulWidget {
  final String title;
  final Function() onStatusChanged;
  final bool isSmall;

  const ToggleValveButton({
    Key? key,
    required this.title,
    required this.onStatusChanged,
    this.isSmall = false,
  }) : super(key: key);

  @override
  _ToggleValveButtonState createState() => _ToggleValveButtonState();
}

class _ToggleValveButtonState extends State<ToggleValveButton> {
  bool _isOpen = false;

  void _toggleValve() {
    setState(() {
      _isOpen = !_isOpen;
      widget.onStatusChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isSmall ? 40 : 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          backgroundColor: const Color(0xFF66C7C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: widget.isSmall
              ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
              : const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
          elevation: 6.0,
        ),
        onPressed: _toggleValve,
        child: Text(
          '${_isOpen ? 'Close' : 'Open'} ${widget.title}',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.0,
          ),
        ),
      ),
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