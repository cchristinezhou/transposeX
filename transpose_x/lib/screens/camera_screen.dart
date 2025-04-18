// camera_screen.dart
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'view_uploaded_sheet_screen.dart';
import '../utils/xml_merge_helper.dart';

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
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() => _capturedImages.add(image));
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() => _capturedImages.addAll(selectedImages));
    }
  }

  Future<void> _uploadAndMerge() async {
    if (_capturedImages.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      List<XmlDocument> parsedDocs = [];

      for (XFile image in _capturedImages) {
        final bytes = await ApiService.uploadFileReturningBytes(image.path, image.name);
        if (bytes == null) continue;

        if (_isZip(bytes)) {
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

      Navigator.pop(context); // Hide spinner

      if (parsedDocs.isEmpty) {
        _showWarningDialog();
        return;
      }

      final mergedXml = XmlMergeHelper.mergeXmlDocuments(parsedDocs);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewSheetScreen(xmlContent: mergedXml),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showWarningDialog();
    }
  }

  bool _isZip(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Warning", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "We couldn't recognize your image(s). Make sure your photo is clear, well-lit, and shows the full sheet music. Try again or pick a different image.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Color(0xFF62558B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadAndMerge();
            },
            child: Text("Retry", style: TextStyle(color: Color(0xFF62558B))),
          ),
        ],
      ),
    );
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
              child: _buildCapturedImageThumbnails(),
            ),
        ],
      ),
      bottomNavigationBar: _buildCameraControls(),
    );
  }

  Widget _buildCapturedImageThumbnails() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < _capturedImages.length && i < 5; i++)
            Positioned(
              top: i * 3.0,
              right: i * 3.0,
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
    );
  }

  Widget _buildCameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.photo, size: 30, color: Color(0xFF62558B)),
                onPressed: _pickImagesFromGallery,
              ),
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF62558B), width: 5),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _uploadAndMerge,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, size: 40, color: Color(0xFF62558B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}