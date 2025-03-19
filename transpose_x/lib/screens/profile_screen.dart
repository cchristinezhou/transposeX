import 'package:flutter/material.dart';
import 'name_screen.dart';  // Import Name editing page
import 'age_screen.dart';   // Import Age editing page
import 'instrument_screen.dart';  // Import Instrument editing page

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildProfileOption(context, "Name", NameScreen()),
          Divider(thickness: 1, color: Colors.grey[300]), 
          _buildProfileOption(context, "Age", AgeScreen()),
          Divider(thickness: 1, color: Colors.grey[300]), 
          _buildProfileOption(context, "Instrument", InstrumentScreen()),
          Divider(thickness: 1, color: Colors.grey[300]), 
          SizedBox(height: 20), 
          _buildPlaceholderLinks(context), 
        ],
      ),
    );
  }

  // Function to create a ListTile for profile options (Name, Age, Instrument)
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

  // Function to create placeholder links for About Us and Privacy Policies
  Widget _buildPlaceholderLinks(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
          },
          child: Text(
            "About Us (placeholder)",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
          },
          child: Text(
            "Privacy Policies (placeholder)",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}