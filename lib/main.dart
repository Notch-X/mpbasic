import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpbasic/pages/onboarding.dart';
import 'package:mpbasic/pages/themesNotifier.dart';
import 'package:mpbasic/pages/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    
    await dotenv.load(fileName: ".env");
    runApp(const ProviderScope(child: MyApp()));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      home: Onboarding(),
    );
    
  }
}
