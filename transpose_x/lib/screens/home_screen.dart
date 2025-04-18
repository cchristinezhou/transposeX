import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/xml_merge_helper.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'view_uploaded_sheet_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreenContent(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.white, child: _screens[_selectedIndex]),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 243, 237, 246),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 98, 85, 139),
          unselectedItemColor: Colors.black54,
          backgroundColor: Color.fromARGB(255, 243, 237, 246),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  Future<void> _pickFilesAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile>? selectedFiles = await picker.pickMultiImage();

    if (selectedFiles == null || selectedFiles.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      final mergedXml = await XmlMergeHelper.processAndMergeFiles(
        selectedFiles,
      );

      Navigator.pop(context); // hide loading spinner

      if (mergedXml == null) {
        _showErrorDialog(context, UploadErrorType.xml);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewSheetScreen(xmlContent: mergedXml),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, UploadErrorType.network);
    }
  }

  void _showErrorDialog(BuildContext context, UploadErrorType type) {
    String errorMessage;
    if (type == UploadErrorType.xml) {
      errorMessage =
          "The music sheet you uploaded isn’t clear. Please upload another file.";
    } else {
      errorMessage =
          "There seems to be an issue with your network. Please retry.";
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Uh-oh, upload failed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Color.fromARGB(255, 98, 85, 139)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickFilesAndUpload(context);
                },
                child: Text(
                  "Retry",
                  style: TextStyle(color: Color.fromARGB(255, 98, 85, 139)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TransposeX",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "How to Use Transpose X",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              "1. Upload Your Music\n"
              "Snap a photo, upload a file, or import a PDF of your sheet music.\n\n"
              "2. Detect & Adjust\n"
              "We’ll identify the key signature automatically.\n\n"
              "3. Download & Play\n"
              "Get your transposed sheet music in seconds.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CameraScreen()),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 98, 85, 139),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Take a Picture",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _pickFilesAndUpload(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 98, 85, 139),
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Upload", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

enum UploadErrorType { xml, network }
