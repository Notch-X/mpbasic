import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  int _selectedSection = 0;
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

  Color _getQualityColor(dynamic value) {
    double qualityValue = double.tryParse(value.toString()) ?? 0;
    if (qualityValue >= 95) return Colors.green;
    if (qualityValue >= 85) return Colors.orange;
    return Colors.red;
  }

  String _formatBottleCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildAnalyticsDiagram(Map<String, dynamic> subpage) {
    if (subpage['title'] == 'Quality') {
      return StreamBuilder(
        stream: _databaseReference.child('set').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final qualityValue = data['Quality'] ?? 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quality Rate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getQualityColor(qualityValue),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${qualityValue.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getQualityColor(qualityValue),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      );
    } else if (subpage['title'] == 'Performance') {
      return StreamBuilder(
        stream: _databaseReference.child('set').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final performanceValue = data['Performance'] ?? 0;
            final color = _getPerformanceColor(performanceValue);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Performance Rate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${performanceValue.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      );
    }

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

// Add this new method to get the color based on performance value
  Color _getPerformanceColor(dynamic value) {
    double performanceValue = double.tryParse(value.toString()) ?? 0;
    if (performanceValue >= 95) return Colors.green;
    if (performanceValue >= 85) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDetailsCard(Map<String, dynamic> subpage) {
    if (subpage['title'] == 'Quality') {
      return StreamBuilder(
        stream: _databaseReference.child('set').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final goodBottles = (data['Good Bottles'] ?? 0).toInt();
            final badBottles = (data['Bad Bottles'] ?? 0).toInt();

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Production Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4D4C),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Bottles',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatBottleCount(goodBottles),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4D4C),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bad Bottles',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatBottleCount(badBottles),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4D4C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      );
    }

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
          ],
        ),
      ),
    );
  }
}
