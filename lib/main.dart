import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'login.dart';
import 'Styles/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const TheiaApp());
}

class TheiaApp extends StatelessWidget {
  const TheiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'THEIA',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.fondo,
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
