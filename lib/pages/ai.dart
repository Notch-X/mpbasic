import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mpbasic/models/category_model.dart';
import 'package:mpbasic/pages/UI/UX/background_widget.dart';
import 'package:mpbasic/pages/UI/UX/bottom_app_bar_widget.dart';
import 'package:mpbasic/pages/UI/UX/drawer_widget.dart';
import 'package:mpbasic/pages/analytics.dart';
import 'package:mpbasic/pages/process.dart';
import 'package:mpbasic/pages/home.dart';
import 'package:mpbasic/pages/alerts.dart';
import 'package:mpbasic/pages/message.dart';
import 'package:mpbasic/pages/themesNotifier.dart';
import 'package:firebase_database/firebase_database.dart';

class AIChatbotPage extends ConsumerStatefulWidget {
  const AIChatbotPage({super.key});

  @override
  ConsumerState<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends ConsumerState<AIChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  List<CategoryModel> categories = [];
  Map<String, dynamic> _cachedFirebaseData = {};
  bool _isLoadingFirebase = false;

  @override
  void initState() {
    super.initState();
    _getCategories();
    // Pre-fetch Firebase data
    _fetchFirebaseData();
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

  Future<Map<String, dynamic>> _fetchFirebaseData() async {
    if (_isLoadingFirebase) return _cachedFirebaseData;
    
    setState(() => _isLoadingFirebase = true);
    
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await ref.child('set').get();
      
      if (snapshot.exists) {
        _cachedFirebaseData = Map<String, dynamic>.from(snapshot.value as Map);
        return _cachedFirebaseData;
      }
      return {};
    } catch (e) {
      print("Error fetching Firebase data: $e");
      return {};
    } finally {
      setState(() => _isLoadingFirebase = false);
    }
  }

  String _formatFirebaseData(Map<String, dynamic> data) {
    StringBuffer formattedData = StringBuffer();
    formattedData.writeln("\nManufacturing Analytics Data:");
    
    data.forEach((key, value) {
      if (value is Map) {
        formattedData.writeln("$key:");
        (value).forEach((k, v) {
          formattedData.writeln("  - $k: $v");
        });
      } else {
        formattedData.writeln("$key: $value");
      }
    });
    
    return formattedData.toString();
  }

  Future<void> _sendRegularMessage() async {
    await callGeminiModel(includeAnalytics: false);
  }

  Future<void> _sendAnalyticsMessage() async {
    await _fetchFirebaseData();
    await callGeminiModel(includeAnalytics: true);
  }

  Future<void> callGeminiModel({bool includeAnalytics = false}) async {
    try {
      final prompt = _controller.text.trim();
      if (prompt.isEmpty) return;

      setState(() {
        _messages.add(Message(text: prompt, isUser: true));
        _isLoading = true;
      });

      _controller.clear();

      String fullPrompt = prompt;
      if (includeAnalytics) {
        if (_cachedFirebaseData.isNotEmpty) {
          String formattedData = _formatFirebaseData(_cachedFirebaseData);
          fullPrompt = """
Please analyze the following question in the context of our manufacturing data:

Question: $prompt

Manufacturing Data Context:
$formattedData

Please provide insights based on both the question and the manufacturing data.
""";
        } else {
          setState(() {
            _messages.add(Message(
              text: "Unable to fetch analytics data. Proceeding with regular response.",
              isUser: false,
            ));
          });
        }
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: dotenv.env['GOOGLE_API_KEY']!
      );
      
      final content = [Content.text(fullPrompt)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(text: response.text!, isUser: false));
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      print("Error calling Generative AI: $e");
      print("Stacktrace: $stacktrace");
      setState(() {
        _isLoading = false;
        _messages.add(Message(
          text: "Error: Unable to fetch response. Please try again.",
          isUser: false,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: appBar(),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        drawer: DrawerWidget(navigateToPage: _navigateToPage),
        body: Stack(
          children: [
            const BackgroundWidget(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return ListTile(
                              title: Align(
                                alignment: message.isUser 
                                    ? Alignment.centerRight 
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.white,
                                    borderRadius: message.isUser
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          )
                                        : BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                      color: message.isUser 
                                          ? Colors.white 
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 32,
                          top: 16.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    hintText: 'Write your message',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                ),
                              ),
                              if (_isLoading)
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    // Regular chat button
                                    IconButton(
                                      icon: Icon(Icons.send, color: Colors.blue),
                                      onPressed: _sendRegularMessage,
                                      tooltip: 'Send regular message',
                                    ),
                                    // Analytics button
                                    IconButton(
                                      icon: Icon(
                                        Icons.analytics,
                                        color: _isLoadingFirebase ? Colors.grey : Colors.green,
                                      ),
                                      onPressed: _isLoadingFirebase ? null : _sendAnalyticsMessage,
                                      tooltip: 'Send with analytics',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBarWidget(navigateToPage: _navigateToPage),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'AI ChatBot',
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