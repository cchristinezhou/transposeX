import 'package:flutter/material.dart';
import 'key_info_screen.dart';
import 'transposing_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:flutter/gestures.dart';

/// A screen that displays the detected key signature and allows the user
/// to select a new key to transpose their sheet music.
///
/// Accessible with screen readers and button semantics.
class TransposeOptionsScreen extends StatefulWidget {
  /// The originally detected key of the uploaded sheet music.
  final String originalKey;

  /// The raw XML content of the uploaded sheet music.
  final String xmlContent;

  /// Creates a [TransposeOptionsScreen].
  const TransposeOptionsScreen({
    required this.originalKey,
    required this.xmlContent,
    Key? key,
  }) : super(key: key);

  @override
  State<TransposeOptionsScreen> createState() => _TransposeOptionsScreenState();
}

class _TransposeOptionsScreenState extends State<TransposeOptionsScreen> {
  /// The key currently selected for transposition.
  late String currentKey;

  /// The current index in the sharp/flat key lists.
  late int currentIndex;

  /// Whether the current key is minor.
  late bool isMinor;

  /// Whether to display keys using sharps (♯) or flats (♭).
  bool showSharps = true;

  /// List of keys using sharps.
  final List<String> sharpKeys = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ];

  /// List of keys using flats.
  final List<String> flatKeys = [
    "C",
    "D♭",
    "D",
    "E♭",
    "E",
    "F",
    "G♭",
    "G",
    "A♭",
    "A",
    "B♭",
    "B",
  ];

  @override
  void initState() {
    super.initState();
    _initializeKeyState(widget.originalKey);
  }

  /// Initializes key signature state from the detected key.
  void _initializeKeyState(String key) {
    final parts = key.split(' ');
    final base = parts[0];
    isMinor = parts.length > 1 && parts[1].toLowerCase() == "minor";

    if (sharpKeys.contains(base)) {
      showSharps = true;
      currentIndex = sharpKeys.indexOf(base);
    } else if (flatKeys.contains(base)) {
      showSharps = false;
      currentIndex = flatKeys.indexOf(base);
    } else {
      showSharps = true;
      currentIndex = 0;
    }

    _updateCurrentKey();
  }

  /// Updates the currently selected key string.
  void _updateCurrentKey() {
    final keyList = showSharps ? sharpKeys : flatKeys;
    currentKey = keyList[currentIndex] + (isMinor ? " minor" : " major");
  }

  /// Moves the key up by a half-step.
  void _transposeUp() {
    setState(() {
      currentIndex = (currentIndex + 1) % sharpKeys.length;
      _updateCurrentKey();
    });
  }

  /// Moves the key down by a half-step.
  void _transposeDown() {
    setState(() {
      currentIndex = (currentIndex - 1 + sharpKeys.length) % sharpKeys.length;
      _updateCurrentKey();
    });
  }

  /// Handles transposition confirmation and navigates to the next screen.
  void _onTransposePressed() {
    final original = widget.originalKey.trim().toLowerCase();
    final selected = currentKey.trim().toLowerCase();

    if (original == selected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Oops! That’s the same key. Try transposing to spice things up 🎶",
            style: AppTextStyles.bodyText,
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => TransposingScreen(
                xmlContent: widget.xmlContent,
                originalKey: widget.originalKey,
                transposedKey: currentKey,
                songName: "Uploaded Sheet",
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.accent,
        elevation: 0,
        title: Semantics(
          label: 'Transpose Options Screen',
          child: SizedBox.shrink(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Detection Successful!",
                  style: AppTextStyles.subHeading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "It looks like your sheet is in ${widget.originalKey}.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.bodySmall, // base style
                      children: [
                        const TextSpan(
                          text: "* We detect the dominant key. For more info, ",
                        ),
                        TextSpan(
                          text: "learn more here.",
                          style: AppTextStyles.linkText,
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const KeyInfoScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sharp/Flat toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Show as: ", style: AppTextStyles.bodyText),
                        const SizedBox(width: 6),
                        Semantics(
                          button: true,
                          label: 'Show sharps ♯',
                          child: ChoiceChip(
                            label: const Text("♯"),
                            selected: showSharps,
                            onSelected: (_) {
                              setState(() {
                                showSharps = true;
                                _updateCurrentKey();
                              });
                            },
                            selectedColor: AppColors.secondaryPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          button: true,
                          label: 'Show flats ♭',
                          child: ChoiceChip(
                            label: const Text("♭"),
                            selected: !showSharps,
                            onSelected: (_) {
                              setState(() {
                                showSharps = false;
                                _updateCurrentKey();
                              });
                            },
                            selectedColor: AppColors.secondaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Transpose Options",
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label: 'Currently selected key: $currentKey',
                          child: Text(
                            currentKey,
                            style: AppTextStyles.sectionHeading,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Semantics(
                          button: true,
                          label: 'Transpose up by half-step',
                          child: IconButton(
                            onPressed: _transposeUp,
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Transpose down by half-step',
                          child: IconButton(
                            onPressed: _transposeDown,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Semantics(
                      button: true,
                      label: 'Confirm transposition',
                      child: ElevatedButton(
                        onPressed: _onTransposePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Transpose",
                          style: AppTextStyles.primaryButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
