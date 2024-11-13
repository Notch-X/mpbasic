import 'package:flutter/material.dart';
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
  // ignore: unused_field
  int _selectedSubPage = 0;
  TabController? _tabController;
  TabController? _subTabController;

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
        {'title': 'Electrical Power'},
        {'title': 'Water Usage'},
        {'title': 'Pressurized Air'},
      ]
    },
    {
      'title': 'Trends',
      'header': 'Trends',
      'subpages': [
        {'title': 'Temp/PH'},
        {'title': 'Total Water Used'},
        {'title': 'Pressurized Air'},
        {'title': 'Conductivity & TDS'},
        {'title': 'Power-Meter'},
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
              color: Colors.white,
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
                          color: Color(0xFF1B4D4C),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
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
      backgroundColor: Colors.black,
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
      // Remove the background color to make it transparent
      child: TabBar(
        controller: _subTabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        // Add these properties to remove the default tab background
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.white),
        ),
        // Remove any padding or margins that might show the background
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
      elevation: 4,
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
    return Center(
      child: Text(
        'Analytics Data for ${subpage['title']}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B4D4C),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> subpage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${subpage['title']} Details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4D4C),
              ),
            ),
            const SizedBox(height: 16),
            // Add your details widgets here
          ],
        ),
      ),
    );
  }
}
