import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A simple screen introducing the "Transpose X" app and its mission.
///
/// Displays a brief description of the app's purpose and a message of gratitude.
class AboutUsScreen extends StatelessWidget {
  /// Creates an instance of [AboutUsScreen].
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /// Back button leading out of the About Us page.
        leading: const BackButton(color: AppColors.accent),

        /// Title displayed in the AppBar.
        title: const Text("About Us", style: AppTextStyles.heading),

        /// Background color of the AppBar.
        backgroundColor: AppColors.background,

        /// No shadow under the AppBar.
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),

              /// Section heading for the mission statement.
              Text(
                "Empowering Music Learners",
                style: AppTextStyles.sectionHeading,
              ),
              SizedBox(height: 16),

              /// Paragraph describing why Transpose X was created.
              Text(
                "Transpose X was created to make sheet music more accessible, "
                "especially for beginners and self-taught musicians. We know the struggle "
                "of encountering a piece in an unfamiliar key — so we built a tool to make "
                "transposition simple, fast, and friendly.",
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: 16),

              /// Paragraph on who benefits from using the app.
              Text(
                "Whether you're a music teacher preparing materials or a student learning to play, "
                "Transpose X helps you focus on what matters: making music.",
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: 16),

              /// Paragraph about the team behind Transpose X.
              Text(
                "We're a small team of music lovers, technologists, and designers committed to "
                "building tools that remove friction and foster creativity.",
                style: AppTextStyles.bodyText,
              ),
              SizedBox(height: 24),

              /// Closing gratitude message to the users.
              Text(
                "Thank you for being part of our journey. 🎼",
                style: AppTextStyles.bodyText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
