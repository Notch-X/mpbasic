import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mpbasic/pages/Data/availability_widget.dart';
import 'package:mpbasic/pages/Data/co2_energy_widget.dart';
import 'package:mpbasic/pages/Data/energy_cost_widget.dart';
import 'package:mpbasic/pages/Data/energy_kw_widget.dart';
import 'package:mpbasic/pages/Data/oee_widget.dart';
import 'package:mpbasic/pages/Data/performance_widget.dart';
import 'package:mpbasic/pages/Data/quality_widget.dart';
import 'package:mpbasic/pages/Data/temp_and_pH_widget.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:mpbasic/pages/alerts.dart';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  int _selectedSection = 0;
  int _selectedSubPage = 0;
  TabController? _tabController;
  TabController? _subTabController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'OEE',
      'header': 'Overall Equipment Effectiveness',
      'subpages': [
        {'title': 'Availability'},
        {'title': 'Performance'},
        {'title': 'Quality'},
      ]
    },
    {
      'title': 'Sustainability',
      'header': 'Sustainability',
      'subpages': [
        {'title': 'CO2 Total'},
      ]
    },
    {
      'title': 'Energy',
      'header': 'Energy',
      'subpages': [
        {'title': 'Energy(kW/kWh)'},
        {'title': 'Energy Cost'},
      ]
    },
    {
      'title': 'Trends',
      'header': 'Trends',
      'subpages': [
        {'title': 'Temp/PH'},
        {'title': 'Overall Equipment Effectiveness'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _tabController = TabController(length: _sections.length, vsync: this);
    _subTabController = TabController(
      length: _sections[_selectedSection]['subpages'].length,
      vsync: this,
    );

    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _selectedSection = _tabController!.index;
          _selectedSubPage = 0;
          _subTabController?.dispose();
          _subTabController = TabController(
            length: _sections[_selectedSection]['subpages'].length,
            vsync: this,
          );
        });
      }
    });

    _subTabController!.addListener(() {
      if (!_subTabController!.indexIsChanging) {
        setState(() {
          _selectedSubPage = _subTabController!.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  void _navigateToPage(String route, BuildContext context) {
    Navigator.pop(context);
    switch (route) {
      case 'Home':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        break;
      case 'Process':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProcessPage()),
        );
        break;
      case 'Chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatbotPage()),
        );
        break;
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsPage()),
        );
        break;
      case 'Alerts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertPage()),
        );
        break;
    }
  }

  void _showFullScreenDiagram(
      BuildContext context, Map<String, dynamic> subpage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subpage['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: _buildAnalyticsDiagram(subpage),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      drawer: DrawerWidget(navigateToPage: _navigateToPage),
      body: Stack(
        children: [
          const BackgroundWidget(),
          SafeArea(
            child: Column(
              children: [
                _buildSubPageTabs(),
                Expanded(child: _buildPageContent()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBarWidget(navigateToPage: _navigateToPage),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _sections[_selectedSection]['header'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        tabs: _sections.map((section) => Tab(text: section['title'])).toList(),
      ),
    );
  }

  Widget _buildSubPageTabs() {
    List<Map<String, dynamic>> currentSubpages =
        _sections[_selectedSection]['subpages'];
    return Container(
      height: 50,
      color: Colors.transparent,
      child: TabBar(
        controller: _subTabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.white),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: currentSubpages.map((subpage) {
          return Tab(text: subpage['title']);
        }).toList(),
      ),
    );
  }

  Widget _buildPageContent() {
    return TabBarView(
      controller: _subTabController,
      children: _sections[_selectedSection]['subpages'].map<Widget>((subpage) {
        return _buildSubPageContent(subpage);
      }).toList(),
    );
  }

  Widget _buildSubPageContent(Map<String, dynamic> subpage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard(subpage),
          const SizedBox(height: 20),
          _buildDetailsCard(subpage),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(Map<String, dynamic> subpage) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showFullScreenDiagram(context, subpage),
        child: Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(16),
          child: _buildAnalyticsDiagram(subpage),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDiagram(Map<String, dynamic> subpage) {
    if (_selectedSection == 0 && subpage['title'] == 'Availability') {
      return AvailabilityWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 0 && subpage['title'] == 'Performance') {
      return PerformanceWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 0 && subpage['title'] == 'Quality') {
      return QualityWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 1 && subpage['title'] == 'CO2 Total') {
      return CO2Widget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 2 && subpage['title'] == 'Energy(kW/kWh)') {
      return EnergyKWWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 2 && subpage['title'] == 'Energy Cost') {
      return EnergyCostWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 3 &&
        subpage['title'] == 'Overall Equipment Effectiveness') {
      return OEEWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 3 && subpage['title'] == 'Temp/PH') {
      return EnvironmentMonitorWidget(databaseReference: _databaseReference);
    }

    return Center(
      child: Text(
        'Analytics Data for ${subpage['title']}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> subpage) {
    if (_selectedSection == 0 && subpage['title'] == 'Availability') {
      return AvailabilityDetailsWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 0 && subpage['title'] == 'Performance') {
      return PerformanceDetailsWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 0 && subpage['title'] == 'Quality') {
      return QualityDetailsWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 1 && subpage['title'] == 'CO2 Total') {
      return CO2DetailsWidget(databaseReference: _databaseReference);
    }

    if (_selectedSection == 2 && subpage['title'] == 'Energy(kW/kWh)') {
      return EnergyDetailsWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 2 && subpage['title'] == 'Energy Cost') {
      return EDetailsWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 3 && subpage['title'] == 'Temp/PH') {
      return TempPHDetailsWidget(databaseReference: _databaseReference);
    }
    if (_selectedSection == 3 &&
        subpage['title'] == 'Overall Equipment Effectiveness') {
      return OEETimeSeriesWidget(databaseReference: _databaseReference);
    }

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Details for ${subpage['title']}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
