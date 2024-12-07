import 'package:example/my_app.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  final prefsAsync = SharedPreferencesAsync();
  await prefsAsync.clear();

  await prefs.setInt('counter', 10);
  await prefs.setBool('repeat', true);
  await prefs.setDouble('decimal', 1.5);
  await prefs.setString('action', 'Start');
  await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);

  await prefsAsync.setString('action-async', 'Stop');

  runApp(
    const SharedPreferencesExplorer(
      // initialAnchorAlignment: AnchorAlignment.bottomLeft,
      child: MyApp(),
    ),
  );
}
