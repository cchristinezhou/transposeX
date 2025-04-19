import 'package:flutter/material.dart';
import 'name_screen.dart';
import 'age_screen.dart';
import 'instrument_screen.dart';
import 'about_us_screen.dart';
import 'privacy_policies_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen displaying user profile options like Name, Age, and Instrument.
///
/// Also provides navigation links to "About Us" and "Privacy Policy" screens.
class ProfileScreen extends StatelessWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        /// Title displayed in the AppBar.
        title: const Text("My Profile", style: AppTextStyles.sectionHeading),

        /// Centers the AppBar title.
        centerTitle: true,

        /// AppBar background color.
        backgroundColor: AppColors.background,

        /// AppBar text/icon color.
        foregroundColor: AppColors.accent,

        /// No shadow under AppBar.
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// Main profile options list (Name, Age, Instrument).
          Expanded(
            child: Column(
              children: [
                _buildProfileOption(context, "Name", const NameScreen()),
                _buildDivider(),
                _buildProfileOption(context, "Age", const AgeScreen()),
                _buildDivider(),
                _buildProfileOption(
                  context,
                  "Instrument",
                  const InstrumentScreen(),
                ),
                _buildDivider(),
              ],
            ),
          ),

          /// Bottom links: About Us and Privacy Policy.
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildBottomLinks(context),
          ),
        ],
      ),
    );
  }

  /// Builds a tappable ListTile for navigating to a profile detail screen.
  ///
  /// [context] - BuildContext to push the new screen.
  /// [title] - The title shown on the tile.
  /// [screen] - The destination screen widget.
  Widget _buildProfileOption(
    BuildContext context,
    String title,
    Widget screen,
  ) {
    return Semantics(
      label: "$title option",
      button: true,
      child: ListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                final offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds a simple divider between profile options.
  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: AppColors.subtitleGrey,
      height: 0,
    );
  }

  /// Builds navigation links at the bottom of the screen (About Us, Privacy Policy).
  Widget _buildBottomLinks(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: "About Us link",
          button: true,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              );
            },
            child: const Text("About Us", style: AppTextStyles.bottomLink),
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: "Privacy Policy link",
          button: true,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            child: const Text(
              "Privacy Policy",
              style: AppTextStyles.bottomLink,
            ),
          ),
        ),
      ],
    );
  }
}
