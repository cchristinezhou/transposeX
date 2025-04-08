import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'view_uploaded_sheet_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  List<XFile> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImages.add(image);
      });
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _capturedImages.addAll(selectedImages);
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Back", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int i = 0; i < _capturedImages.length; i++)
                      Positioned(
                        top: (i < 5) ? i * 3.0 : 15.0,
                        right: (i < 5) ? i * 3.0 : 15.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_capturedImages[i].path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _capturedImages.length.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.photo,
                    size: 30,
                    color: Color.fromARGB(255, 98, 85, 139),
                  ),
                  onPressed: _pickImagesFromGallery,
                ),
                GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromARGB(255, 98, 85, 139),
                        width: 5,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_capturedImages.isEmpty) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(child: CircularProgressIndicator()),
                    );

                    try {
                      List<String> xmls = [];

                      for (XFile image in _capturedImages) {
                        final xml = await ApiService.uploadFile(image.path, image.name);
                        if (xml != null) xmls.add(xml);
                      }

                      Navigator.pop(context);

                      if (xmls.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ Upload failed.")),
                        );
                        return;
                      }

                      // Merge XMLs
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
                        SnackBar(content: Text("❌ Error uploading images: $e")),
                      );
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.check_circle,
                        size: 40,
                        color: Color.fromARGB(255, 98, 85, 139),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}