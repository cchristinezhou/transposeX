import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved")),
      body: Center(
        child: Text(
          "Saved Screen - Work in Progress",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}