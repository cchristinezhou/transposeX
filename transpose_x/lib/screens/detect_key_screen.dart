import 'package:flutter/material.dart';

class DetectKeyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detecting Key..."),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "🔍 Key detection placeholder screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}