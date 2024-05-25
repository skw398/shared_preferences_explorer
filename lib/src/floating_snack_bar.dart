import 'package:flutter/material.dart';

SnackBar floatingSnackBar({required String message}) {
  return SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
  );
}
