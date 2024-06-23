import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'page/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(

      //data lihat di file google-services.json
      apiKey: 'AIzaSyCLFwDUfbSXC2qsbZ1XjZnn9KU9vWQJV3o', //current_key
      appId: '1:156216172419:android:6f318ab36bf96c986da0b6', //mobilesdk_app_id
      messagingSenderId: '156216172419', //project_number
      projectId: 'absensi-12ff9'), //project_id
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cardTheme: const CardTheme(surfaceTintColor: Colors.white),
        dialogTheme: const DialogTheme(surfaceTintColor: Colors.white, backgroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
