import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transpose_result_screen.dart';

class TransposingScreen extends StatefulWidget {
  final String xmlContent;
  final String originalKey;
  final String transposedKey;
  final String songName;

  const TransposingScreen({
    Key? key,
    required this.xmlContent,
    required this.originalKey,
    required this.transposedKey,
    required this.songName,
  }) : super(key: key);

  @override
  State<TransposingScreen> createState() => _TransposingScreenState();
}

class _TransposingScreenState extends State<TransposingScreen> {
  @override
  void initState() {
    super.initState();
    _startTransposition();
  }

  Future<void> _startTransposition() async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate processing

  if (!mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => TransposeResultScreen(
        transposedXml: widget.xmlContent,
        originalKey: widget.originalKey,
        transposedKey: widget.transposedKey,
        songName: widget.songName,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Transposing...",
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color.fromARGB(50, 98, 85, 139),
                valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 98, 85, 139)),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}