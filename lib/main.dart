import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SwapshelfApp());
}

class SwapshelfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swapshelf',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // LoginScreen ana ekran olarak ayarlandı
    );
  }
}
