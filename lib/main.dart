// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/macro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MacroTestApp());
}

class MacroTestApp extends StatelessWidget {
  const MacroTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macro Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MacroScreen(),
    );
  }
}
