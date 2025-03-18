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
      title: 'Transpose X',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/viewSheet': (context) => ViewSheetScreen(xmlUrl: 'https://your-transposed-file.xml'),
      },
    );
  }
}