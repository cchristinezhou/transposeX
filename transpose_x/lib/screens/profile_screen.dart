import 'package:flutter/material.dart';

// This screen displays the user's profile settings with options to edit Name, Age, and Instrument.
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildProfileOption(context, "Name", NameScreen()),
          _buildProfileOption(context, "Age", AgeScreen()),
          _buildProfileOption(context, "Instrument", InstrumentScreen()),
        ],
      ),
    );
  }

  // Helper function to create a profile option that navigates to the corresponding edit screen.
  Widget _buildProfileOption(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}

// Screen for editing the user's name.
class NameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Name")),
      body: Center(child: Text("Name Edit Page")),
    );
  }
}

// Screen for editing the user's age.
class AgeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Age")),
      body: Center(child: Text("Age Edit Page")),
    );
  }
}

// Screen for editing the user's instrument.
class InstrumentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Instrument")),
      body: Center(child: Text("Instrument Edit Page")),
    );
  }
}