import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'transpose_options_screen.dart';

/// A screen that detects the key signature from the uploaded sheet music.
///
/// Simulates a short loading period while extracting the key,
/// then navigates to the [TransposeOptionsScreen].
class DetectKeyScreen extends StatefulWidget {
  /// The XML content of the uploaded sheet music.
  final String xmlContent;

  /// Creates a [DetectKeyScreen].
  const DetectKeyScreen({Key? key, required this.xmlContent}) : super(key: key);

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
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading

    final detectedKey = _extractKeyFromXml(widget.xmlContent);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransposeOptionsScreen(
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

      final fifths =
          int.tryParse(keyElement.getElement('fifths')?.innerText ?? '0') ?? 0;
      final mode =
          keyElement.getElement('mode')?.innerText.toLowerCase() ?? 'major';

      return _mapKeySignature(fifths, mode);
    } catch (e) {
      return "C major"; // Fallback on error
    }
  }

  String _mapKeySignature(int fifths, String mode) {
    const sharpMajorKeys = ["C", "G", "D", "A", "E", "B", "F#", "C#", "G#"];
    const sharpMinorKeys = ["A", "E", "B", "F#", "C#", "G#", "D#", "A#", "E#"];

    const flatMajorKeys = ["C", "F", "B♭", "E♭", "A♭", "D♭", "G♭", "C♭"];
    const flatMinorKeys = ["A", "D", "G", "C", "F", "B♭", "E♭", "A♭"];

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Detecting the Key...", style: AppTextStyles.bodyMedium),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: AppColors.offWhite,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Cancel", style: AppTextStyles.primaryAction),
            ),
          ],
        ),
      ),
    );
  }
}
