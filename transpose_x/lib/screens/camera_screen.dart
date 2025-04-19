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
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

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
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);

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
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<XmlDocument> parsedDocs = [];

      for (XFile image in _capturedImages) {
        final bytes = await ApiService.uploadFileReturningBytes(
          image.path,
          image.name,
        );
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

      Navigator.pop(context);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Warning", style: AppTextStyles.heading),
        content: const Text(
          "We couldn't recognize your image(s). Make sure your photo is clear, well-lit, and shows the full sheet music. Try again or pick a different image.",
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: AppTextStyles.primaryAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadAndMerge();
            },
            child: const Text("Retry", style: AppTextStyles.primaryAction),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          tooltip: "Back to previous screen",
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Back", style: AppTextStyles.bodyMedium),
      ),
      body: Semantics(
        label: "Camera screen. Use capture or upload images.",
        explicitChildNodes: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: _isCameraInitialized
                  ? Semantics(
                      label: "Camera preview",
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: GestureDetector(
                            onTapDown: (details) async {
                              final renderBox = context.findRenderObject() as RenderBox;
                              final localPosition = renderBox.globalToLocal(details.globalPosition);
                              final dx = localPosition.dx / renderBox.size.width;
                              final dy = localPosition.dy / renderBox.size.height;

                              try {
                                await _cameraController!.setFocusPoint(Offset(dx, dy));
                                print('🔍 Focusing at: $dx, $dy');
                              } catch (e) {
                                print('⚠️ setFocusPoint failed: $e');
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            if (_capturedImages.isNotEmpty)
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildCapturedImageThumbnails(),
              ),
          ],
        ),
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
              child: Semantics(
                label: "Captured image ${i + 1}",
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
            ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Text(
                _capturedImages.length.toString(),
                style: AppTextStyles.badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            button: true,
            label: "Pick images from gallery",
            child: IconButton(
              icon: const Icon(
                Icons.photo,
                size: 30,
                color: AppColors.primaryPurple,
              ),
              onPressed: _pickImagesFromGallery,
            ),
          ),
          Semantics(
            button: true,
            label: "Capture image from camera",
            child: GestureDetector(
              onTap: _captureImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryPurple, width: 5),
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: "Upload and merge images",
            child: GestureDetector(
              onTap: _uploadAndMerge,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}