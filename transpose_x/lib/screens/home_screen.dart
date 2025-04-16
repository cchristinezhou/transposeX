import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xml/xml.dart';
import '../services/api_service.dart';
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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "How to Use Transpose X",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        "Snap a photo, upload a file, or import a PDF of your sheet music.\n\n",
                  ),
                  TextSpan(
                    text: "2. Detect & Adjust\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "We’ll identify the key signature automatically.\n\n",
                  ),
                  TextSpan(
                    text: "3. Download & Play\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "Get your transposed sheet music in seconds."),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CameraScreen()),
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
      List<XmlDocument> parsedDocs = [];

      for (XFile file in selectedFiles) {
        final bytes = await ApiService.uploadFileReturningBytes(
          file.path,
          file.name,
        );
        if (bytes == null) continue;

        // If MXL (zip), unzip and find the .xml
        if (file.name.toLowerCase().endsWith('.mxl') || _isZip(bytes)) {
          try {
            final archive = ZipDecoder().decodeBytes(bytes);
            for (final archived in archive) {
              if (archived.name.endsWith('.xml')) {
                final xmlStr = utf8.decode(archived.content as List<int>);
                parsedDocs.add(XmlDocument.parse(xmlStr));
                break;
              }
            }
          } catch (e) {
            print("❌ Failed to unzip MXL: $e");
          }
        } else {
          final xmlStr = utf8.decode(bytes);
          parsedDocs.add(XmlDocument.parse(xmlStr));
        }
      }

      Navigator.pop(context); // Hide loading spinner

      if (parsedDocs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed or no valid XML found.")),
        );
        return;
      }

      // Start merging
      final baseDoc = parsedDocs.first;
      final score = baseDoc.rootElement;
      final basePartList = score.getElement('part-list')!;
      int nextPartId = 2; // Start from P2

      for (int i = 1; i < parsedDocs.length; i++) {
        final doc = parsedDocs[i];
        final incomingScore = doc.rootElement;

        // Merge part-list
        final incomingPartList = incomingScore.getElement('part-list');
        if (incomingPartList != null) {
          for (final partDef in incomingPartList.findElements('score-part')) {
            final newId = 'P$nextPartId';
            final copied = partDef.copy();
            copied.getAttributeNode('id')?.value = newId;
            basePartList.children.add(copied);
          }
        }

        // Merge parts
        for (final part in incomingScore.findAllElements('part')) {
          final newId = 'P$nextPartId';
          final updatedPart = part.copy();
          updatedPart.getAttributeNode('id')?.value = newId;

          // Optional: re-number measures to avoid conflicts
          int measureNum = 1;
          for (final measure in updatedPart.findElements('measure')) {
            final attr = measure.getAttributeNode('number');
            if (attr != null) {
              attr.value = measureNum.toString();
            }
            measureNum++;
          }

          score.children.add(updatedPart);
          nextPartId++;
        }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error during upload: $e")));
    }
  }

  bool _isZip(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
  }
}
