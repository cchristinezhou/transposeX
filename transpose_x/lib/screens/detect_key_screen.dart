import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'transpose_options_screen.dart';

class DetectKeyScreen extends StatefulWidget {
  final String xmlContent;

  const DetectKeyScreen({
    Key? key,
    required this.xmlContent,
  }) : super(key: key);

  @override
  State<DetectKeyScreen> createState() => _DetectKeyScreenState();
}

class _DetectKeyScreenState extends State<DetectKeyScreen> {
  @override
  void initState() {
    super.initState();
    _startKeyDetection();
  }

  Future<void> _startKeyDetection() async {
    await Future.delayed(Duration(seconds: 2)); // simulate loading

    final detectedKey = _extractKeyFromXml(widget.xmlContent);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransposeOptionsScreen(
          originalKey: detectedKey,
          xmlContent: widget.xmlContent,
        ),
      ),
    );
  }

  String _extractKeyFromXml(String xmlContent) {
    try {
      final document = XmlDocument.parse(xmlContent);
      final keyElement = document.findAllElements('key').first;

      final fifths = int.tryParse(keyElement.getElement('fifths')?.innerText ?? '0') ?? 0;
      final mode = keyElement.getElement('mode')?.innerText.toLowerCase() ?? 'major';

      return _mapKeySignature(fifths, mode);
    } catch (e) {
      return "C major"; // fallback on error
    }
  }

  String _mapKeySignature(int fifths, String mode) {
  const sharpMajorKeys = [
    "C", "G", "D", "A", "E", "B", "F#", "C#", "G#"
  ];
  const sharpMinorKeys = [
    "A", "E", "B", "F#", "C#", "G#", "D#", "A#", "E#"
  ];

  const flatMajorKeys = [
    "C", "F", "B♭", "E♭", "A♭", "D♭", "G♭", "C♭"
  ];
  const flatMinorKeys = [
    "A", "D", "G", "C", "F", "B♭", "E♭", "A♭"
  ];

  if (fifths >= 0) {
    return mode == "minor"
        ? "${sharpMinorKeys[fifths]} minor"
        : "${sharpMajorKeys[fifths]} major";
  } else {
    final index = -fifths;
    return mode == "minor"
        ? "${flatMinorKeys[index]} minor"
        : "${flatMajorKeys[index]} major";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Detecting the Key...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Colors.purple.shade100,
                valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 98, 85, 139)),
              ),
            ),
            SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}