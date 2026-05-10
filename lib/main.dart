import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imposter/models/game_state.dart';
import 'package:imposter/theme/app_theme.dart';
import 'package:imposter/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const ImposterApp(),
    ),
  );
}

class ImposterApp extends StatefulWidget {
  const ImposterApp({super.key});

  static _ImposterAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_ImposterAppState>()!;

  @override
  State<ImposterApp> createState() => _ImposterAppState();
}

class _ImposterAppState extends State<ImposterApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imposter Word Game',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
