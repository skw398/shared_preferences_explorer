import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter', 10);
  await prefs.setBool('repeat', true);
  await prefs.setDouble('decimal', 1.5);
  await prefs.setString('action', 'Start');
  await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);

  runApp(
    const SharedPreferencesExplorer(
      // anchorAlignment: Alignment.bottomLeft,
      // colorSchemeSeed: Colors.lightGreen,
      child: MyApp(),
    ),
  );

  // // Or
  // runApp(
  //   const SharedPreferencesExplorer(),
  //   // MyApp(),
  // );
}
