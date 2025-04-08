import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),
              Text(
                "Your Privacy Matters",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 98, 85, 139)),
              ),
              SizedBox(height: 16),
              Text(
                "We respect your privacy and are committed to keeping your data safe. Here's how we handle your information:",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                "• We do not collect or store any personal identifying information without your consent.\n"
                "• Uploaded sheet music is processed securely and never shared.\n"
                "• We use temporary files only for display and conversion; these are not stored permanently.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                "We may collect anonymous usage data to improve the app, such as which features are used most often. This helps us make Transpose X better for you — without tracking who you are.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 24),
              Text(
                "If you have any questions about how your data is used, feel free to reach out. Transparency is important to us.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}