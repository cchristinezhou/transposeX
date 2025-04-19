// coverage:ignore-file
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import 'transpose_result_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that processes and displays the transposition of a music sheet.
///
/// Handles API communication, progress feedback, and error dialogs.
/// Optimized for screen readers and accessibility.
class TransposingScreen extends StatefulWidget {
  /// Raw XML content of the original sheet music.
  final String xmlContent;

  /// The original key signature.
  final String originalKey;

  /// The target key signature after transposition.
  final String transposedKey;

  /// The name of the song being transposed.
  final String songName;

  /// Creates a [TransposingScreen].
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

  /// Initiates the transposition request to backend service.
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
          builder:
              (_) => TransposeResultScreen(
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

  /// Displays an accessible error dialog based on the type of failure.
  void _showErrorDialog(dynamic error) {
    String title = "Uh-oh, transposition failed!";
    String message =
        "Looks like we hit a wrong note. Try again or double-check your file.";

    if (error.toString().contains('SocketException')) {
      title = "No Internet Connection";
      message =
          "We couldn't send your request. Please check your internet and try again.";
    } else if (error.toString().contains('500') ||
        error.toString().contains('Internal Server Error')) {
      title = "Server Error";
      message = "Something went wrong on our end. Please try again later.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.bodyMedium),
            ),
            content: Semantics(
              liveRegion: true,
              child: Text(message, style: AppTextStyles.bodyText),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: AppTextStyles.primaryAction),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startTransposition();
                },
                child: const Text("Retry", style: AppTextStyles.primaryAction),
              ),
            ],
          ),
    );
  }

  /// Calculates semitone interval difference between two keys.
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
    int start =
        keyMap[originalKey.replaceAll(' major', '').replaceAll(' minor', '')] ??
        0;
    int end =
        keyMap[transposedKey
            .replaceAll(' major', '')
            .replaceAll(' minor', '')] ??
        0;
    return end - start;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                label: "Transposing your music sheet",
                child: const Text(
                  "Transposing...",
                  style: AppTextStyles.largeHeading,
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                label: "Loading progress indicator",
                value: "Processing",
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Color.fromARGB(50, 98, 85, 139),
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                button: true,
                label: "Cancel transposition and go back",
                child: OutlinedButton(
                  onPressed:
                      _isTransposing ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
