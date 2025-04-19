import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Defines the text styles used across the app.
class AppTextStyles {
  /// Large bold heading text style.
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  /// Medium-weight button text style, white color.
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.background,
  );

  /// Subtitle or secondary text style, grey color.
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.accent,
  );

  /// Text style for error messages or validation errors.
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: AppColors.warningRed,
  );

  /// Text style for section headings or important labels.
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryPurple,
  );

  /// Text style for body text or general information.
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.accent,
  );

  /// Medium-weight body text style.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  /// Primary action text style (purple color).
  static const TextStyle primaryAction = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryPurple,
  );

  /// Badge or counter number inside small circle.
  static const TextStyle badgeText = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  /// Large heading for main titles.
  static const TextStyle largeHeading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryPurple,
  );

  /// Subheading for secondary titles.
  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  /// Slightly smaller body text (for bullet points, notes).
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 1.6,
    color: AppColors.accent,
  );

  /// Style for bottom text links like "About Us" and "Privacy Policy."
  static const TextStyle bottomLink = TextStyle(
    fontSize: 14,
    color: AppColors.accent,
    fontWeight: FontWeight.w500,
  );

  /// Link text (e.g., 'learn more here').
  static const TextStyle linkText = TextStyle(
    fontSize: 13,
    height: 1.6,
    color: AppColors.primaryPurple,
    decoration: TextDecoration.underline,
  );

  /// Style for elevated primary button text.
  static const TextStyle primaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
  );

  /// Style for secondary (outlined) buttons.
  static const TextStyle secondaryButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryPurple,
  );
}
