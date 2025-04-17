import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transpose_result_screen.dart';
import '../services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  bool _isTransposing = false;

  @override
  void initState() {
    super.initState();
    _startTransposition();
  }

  Future<void> _startTransposition() async {
    if (!mounted) return;

    setState(() => _isTransposing = true);

    try {
      final dir = await getTemporaryDirectory();
      final outputFilePath = '${dir.path}/transposed.xml';

      final interval = _calculateInterval(
        widget.originalKey,
        widget.transposedKey,
      );

      final result = await ApiService.transposeSong(
        xml: widget.xmlContent,
        interval: interval,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransposeResultScreen(
            transposedXml: result,
            originalKey: widget.originalKey,
            transposedKey: widget.transposedKey,
            songName: widget.songName,
          ),
        ),
      );
    } catch (e) {
      print("❌ Transposition failed: $e");
      if (!mounted) return;
      _showErrorDialog(e);
    } finally {
      if (mounted) {
        setState(() => _isTransposing = false);
      }
    }
  }

  void _showErrorDialog(dynamic error) {
    String title = "Uh-oh, transposition failed!";
    String message = "Looks like we hit a wrong note. Try again or double-check your file.";

    if (error.toString().contains('SocketException')) {
      title = "Uh-oh! We couldn’t process your request.";
      message = "There was an issue sending your request. Check your internet connection and try again.";
    } else if (error.toString().contains('500') || error.toString().contains('Internal Server Error')) {
      title = "Oops! Something went wrong on our end.";
      message = "We couldn’t complete the transposition due to a system error. Please try again later.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _startTransposition();   // Retry
            },
            child: const Text("Retry", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
          ),
        ],
      ),
    );
  }

  int _calculateInterval(String originalKey, String transposedKey) {
    final keyMap = {
      "C": 0,
      "C#": 1,
      "Db": 1,
      "D": 2,
      "Eb": 3,
      "E": 4,
      "F": 5,
      "F#": 6,
      "G": 7,
      "Ab": 8,
      "A": 9,
      "Bb": 10,
      "B": 11,
    };
    int start = keyMap[originalKey.replaceAll(' major', '').replaceAll(' minor', '')] ?? 0;
    int end = keyMap[transposedKey.replaceAll(' major', '').replaceAll(' minor', '')] ?? 0;
    return end - start;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Transposing...", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color.fromARGB(50, 98, 85, 139),
                valueColor: AlwaysStoppedAnimation(
                  Color.fromARGB(255, 98, 85, 139),
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _isTransposing ? null : () => Navigator.pop(context),
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