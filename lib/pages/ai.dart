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

  // New method to fetch data from Firebase
  Future<Map<String, dynamic>> _fetchFirebaseData() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await ref.child('set').get();
      
      if (snapshot.exists) {
        return snapshot.value as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print("Error fetching Firebase data: $e");
      return {};
    }
  }

  // Enhanced Gemini model call with optional Firebase data integration
  callGeminiModel({bool includeAnalytics = false}) async {
    try {
      // Ensure the text is captured before clearing the controller
      final prompt = _controller.text.trim();

      if (prompt.isNotEmpty) {
        setState(() {
          _messages.add(Message(text: prompt, isUser: true));
          _isLoading = true;
        });

        // Clear the input box only after capturing the prompt
        _controller.clear();

        // Optionally fetch Firebase data
        Map<String, dynamic> firebaseData = {};
        if (includeAnalytics) {
          firebaseData = await _fetchFirebaseData();
        }

        // Prepare the full prompt
        String fullPrompt = prompt;
        if (includeAnalytics && firebaseData.isNotEmpty) {
          fullPrompt += "\n\nAdditional Context from Manufacturing Data:\n${firebaseData.toString()}";
        }

        // Instantiate the model with the correct parameters
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
      }
    } catch (e, stacktrace) {
      print("Error calling Generative AI: $e");
      print("Stacktrace: $stacktrace");
      setState(() {
        _isLoading = false;
        _messages.add(Message(text: "Error: Unable to fetch response.", isUser: false));
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
                              SizedBox(width: 8),
                              Row(
                                children: [
                                  // Regular Chat Button
                                  _isLoading
                                      ? Padding(
                                          padding: EdgeInsets.all(8),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            child: Icon(Icons.send, color: Colors.blue),
                                            onTap: () => callGeminiModel(includeAnalytics: false),
                                          ),
                                        ),
                                  
                                  // Analytics-Integrated Chat Button
                                  _isLoading
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            child: Icon(Icons.analytics, color: Colors.green),
                                            onTap: () => callGeminiModel(includeAnalytics: true),
                                          ),
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
