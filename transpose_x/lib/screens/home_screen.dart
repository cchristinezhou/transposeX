import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'view_uploaded_sheet_screen.dart';
import '../services/api_service.dart';
import 'package:xml/xml.dart';

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

// Actual home screen content
class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "TransposeX",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "How to Use Transpose X",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "1. Upload Your Music\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "Snap a photo, upload a file, or import a PDF of your sheet music. We’ll analyze it instantly.\n\n",
                  ),
                  TextSpan(
                    text: "2. Detect & Adjust\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "We’ll identify the key signature automatically. Select your desired key and let the magic happen.\n\n",
                  ),
                  TextSpan(
                    text: "3. Download & Play\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        "Get your transposed sheet music in seconds. Save, print, or share it effortlessly.",
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Making music easier, one key at a time.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 98, 85, 139),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Take a Picture",
                style: TextStyle(fontSize: 16, color: Colors.white),
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
              child: Text(
                "Upload",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFilesAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile>? selectedFiles = await picker.pickMultiImage();

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        List<String> xmls = [];

        for (XFile file in selectedFiles) {
          final xml = await ApiService.uploadFile(file.path, file.name);
          if (xml != null) xmls.add(xml);
        }

        Navigator.pop(context); // Dismiss spinner

        if (xmls.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Upload failed for all files.")),
          );
          return;
        }

        // Merge logic
        final baseDoc = XmlDocument.parse(xmls.first);
        final basePart = baseDoc.findAllElements('part').first;
        int measureOffset = basePart.findElements('measure').length;

        for (int i = 1; i < xmls.length; i++) {
          final doc = XmlDocument.parse(xmls[i]);
          final part = doc.findAllElements('part').first;
          final measures = part.findElements('measure');

          for (final measure in measures) {
            final numberAttr = measure.getAttributeNode('number');
            if (numberAttr != null) {
              numberAttr.value =
                  (int.parse(numberAttr.value) + measureOffset).toString();
            }
            basePart.children.add(measure.copy());
          }

          measureOffset += measures.length;
        }

        final mergedXml = baseDoc.toXmlString(pretty: true);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewSheetScreen(xmlContent: mergedXml),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error during upload: $e")),
        );
      }
    }
  }
}