import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.leading,
    required this.title,
  });

  final Widget leading;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      horizontalTitleGap: 12,
      visualDensity: VisualDensity.compact,
    );
  }
}
