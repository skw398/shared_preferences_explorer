import 'package:material_ui/material_ui.dart';

class SharedPreferencesExplorerTheme extends StatelessWidget {
  const SharedPreferencesExplorerTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(colorSchemeSeed: Colors.blue),
      child: child,
    );
  }
}
