import 'package:flutter/material.dart';

void showSaveError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Could not save. Check your device storage.')),
  );
}
