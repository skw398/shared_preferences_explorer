import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_explorer/shared_preferences_explorer.dart';

class const MyApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class const MyHomePage({required final String title, super.key})
    extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<SharedPreferences> get prefs async => SharedPreferences.getInstance();

  @override
  void initState() {
    Future(() async {
      final counter = (await prefs).getInt('counter');
      setState(() => _counter = counter ?? 0);
    });
    super.initState();
  }

  Future<void> _incrementCounter() async {
    await (await prefs).setInt('counter', _counter + 1);
    setState(() => _counter++);
  }

  Future<void> _resetCounter() async {
    await (await prefs).setInt('counter', 0);
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          if (kDebugMode)
            Padding(
              padding: const .only(right: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const _DebugMenu(),
                    ),
                  );
                },
                child: const Text('DEBUG'),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: _resetCounter,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class const _DebugMenu() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEBUG')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('SharedPreferences values'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SharedPreferencesExplorerScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('SharedPreferencesAsync values'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      const SharedPreferencesAsyncExplorerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
