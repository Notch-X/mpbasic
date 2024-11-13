import 'package:flutter/material.dart';
import 'package:mpbasic/models/category_model.dart';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/ai.dart';
import 'package:mpbasic/pages/alerts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  bool _showGreenPlan = false;
  int _currentImageIndex = 0;

  // Define image assets for the Green Plan
  final List<Map<String, String>> _greenPlanContent = [
    {
      'image': 'assets/images/sg-green-plan.jpg',
      'title': 'Singapore Green Plan 2030',
      'description': 'An overview of the Singapore Green Plan 2030',
    },
    {
      'image': 'assets/images/Green_Plan.jpg',
      'title': 'Green Plan Details',
      'description': 'Detailed information about the Green Plan',
    }
  ];

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  void _getCategories() {
    categories = CategoryModel.getCategories();
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
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsPage()),
        );
        break;
      case 'Chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatbotPage()),
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

  Widget _buildGreenPlanViewer() {
    return AnimatedOpacity(
      opacity: _showGreenPlan ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _showGreenPlan
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _showGreenPlan = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevents tap from closing modal
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
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
                                  _greenPlanContent[_currentImageIndex]
                                      ['title']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _showGreenPlan = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.6,
                                ),
                                child: Image.asset(
                                  _greenPlanContent[_currentImageIndex]
                                      ['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                left: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentImageIndex = (_currentImageIndex -
                                              1 +
                                              _greenPlanContent.length) %
                                          _greenPlanContent.length;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentImageIndex =
                                          (_currentImageIndex + 1) %
                                              _greenPlanContent.length;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _greenPlanContent[_currentImageIndex]
                                      ['description']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _greenPlanContent
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == entry.key
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: appBar(context),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        drawer: DrawerWidget(navigateToPage: _navigateToPage),
        body: Stack(
          children: [
            const BackgroundWidget(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 100),
              ],
            ),
            _buildGreenPlanViewer(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _showGreenPlan = true;
              _currentImageIndex = 0;
            });
          },
          backgroundColor: Colors.green,
          icon: const Icon(Icons.eco),
          label: const Text('Green Plan'),
        ),
        bottomNavigationBar:
            BottomAppBarWidget(navigateToPage: _navigateToPage),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Saline Solution Production',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }
}
