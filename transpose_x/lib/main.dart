import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/view_sheet_screen.dart';

void main() {
  runApp(TransposeXApp());
}


class TransposeXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transpose X',
      theme: ThemeData.light(),
      home: HomeScreen(),
    );
  }
}