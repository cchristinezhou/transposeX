import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transpose_result_screen.dart';

class TransposingScreen extends StatefulWidget {
  const TransposingScreen({Key? key}) : super(key: key);

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
    // Simulate a delay (pretend to call backend)
    await Future.delayed(const Duration(seconds: 2));

    // Load mock transposed XML from assets
    final String transposedXml =
        await rootBundle.loadString('assets/3.1.a.Fur_Elise.xml');

    // Navigate to result screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransposeResultScreen(transposedXml: transposedXml),
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