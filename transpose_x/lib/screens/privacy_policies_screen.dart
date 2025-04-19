import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that outlines the app's privacy policy.
///
/// Communicates how user data is handled with transparency and respect.
class PrivacyPolicyScreen extends StatelessWidget {
  /// Creates a [PrivacyPolicyScreen].
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: AppColors.accent),
        title: const Text("Privacy Policy", style: AppTextStyles.bodyMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),
              Text("Your Privacy Matters", style: AppTextStyles.sectionHeading),
              SizedBox(height: 16),
              Text(
                "We respect your privacy and are committed to keeping your data safe. Here's how we handle your information:",
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: 16),
              Text(
                "• We do not collect or store any personal identifying information without your consent.\n"
                "• Uploaded sheet music is processed securely and never shared.\n"
                "• We use temporary files only for display and conversion; these are not stored permanently.",
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 16),
              Text(
                "We may collect anonymous usage data to improve the app, such as which features are used most often. This helps us make Transpose X better for you — without tracking who you are.",
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: 24),
              Text(
                "If you have any questions about how your data is used, feel free to reach out. Transparency is important to us.",
                style: AppTextStyles.bodyText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
