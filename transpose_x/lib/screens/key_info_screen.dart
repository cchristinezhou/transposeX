import 'package:flutter/material.dart';

class KeyInfoScreen extends StatelessWidget {
  const KeyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Scrollbar(
            radius: Radius.circular(8),
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 16),
                  Text(
                    "How We Detect\nYour Key",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 98, 85, 139),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Transpose X simplifies key detection by identifying the dominant key in your sheet music. If a piece contains multiple key signatures, we focus on the most prominent one to keep the transposition process smooth and straightforward.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Why Do We Detect Only One Key?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Many sheet music pieces modulate (change keys), making it complex to transpose every key accurately.\n"
                    "• To keep things user-friendly, we detect the primary key so you can quickly transpose without confusion.\n"
                    "• If your piece has multiple keys, you may need to manually adjust sections after transposition.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "If you need more flexibility, let us know! We’re always looking to improve. 🎶",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
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