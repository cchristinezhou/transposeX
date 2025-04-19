import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that explains how Transpose X detects the key signature of uploaded sheet music.
///
/// Provides users with a simple and accessible explanation of the detection process,
/// focusing on why only the dominant key is detected for ease of use.
class KeyInfoScreen extends StatelessWidget {
  /// Creates an instance of [KeyInfoScreen].
  const KeyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Semantics(
          label: "Go back to previous screen",
          button: true,
          child: const BackButton(color: AppColors.accent),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Scrollbar(
            radius: const Radius.circular(8),
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      "How We Detect\nYour Key",
                      style: AppTextStyles.largeHeading,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Transpose X simplifies key detection by identifying the dominant key in your sheet music. "
                    "If a piece contains multiple key signatures, we focus on the most prominent one "
                    "to keep the transposition process smooth and straightforward.",
                    style: AppTextStyles.bodyText,
                  ),
                  SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      "Why Do We Detect Only One Key?",
                      style: AppTextStyles.subHeading,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Many sheet music pieces modulate (change keys), making it complex to transpose every key accurately.\n"
                    "• To keep things user-friendly, we detect the primary key so you can quickly transpose without confusion.\n"
                    "• If your piece has multiple keys, you may need to manually adjust sections after transposition.",
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: 24),
                  Text(
                    "If you need more flexibility, let us know! We’re always looking to improve. 🎶",
                    style: AppTextStyles.bodyText,
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
