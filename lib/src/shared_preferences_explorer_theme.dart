import 'package:material_ui/material_ui.dart';

class const SharedPreferencesExplorerTheme({
  super.key,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(colorSchemeSeed: Colors.blue),
      child: child,
    );
  }
}
