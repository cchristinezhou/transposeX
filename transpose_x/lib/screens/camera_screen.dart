import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  List<XFile> _capturedImages = []; // Store multiple images

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
      final XFile image =
          await _cameraController!.takePicture(); // Capture image
      setState(() {
        _capturedImages.add(image); // Store image in the list
      });
    } catch (e) {
      print("Error capturing image: $e");
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
          // Camera preview remains running
          Positioned.fill(
            child:
                _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : Center(child: CircularProgressIndicator()),
          ),

          // Display mini preview in the bottom-right corner
          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  clipBehavior: Clip.none, // Allows stacking effect
                  children: [
                    // Limit the offset to a max of 5 images
                    for (int i = 0; i < _capturedImages.length; i++)
                      Positioned(
                        top:
                            (i < 5)
                                ? i * 3.0
                                : 15.0, // Stop shifting after 5 images
                        right:
                            (i < 5) ? i * 3.0 : 15.0, // Keep max offset at 25px
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

                    // Badge showing the number of captured images
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
          // Capture & Checkmark buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery button
                IconButton(
                  icon: Icon(
                    Icons.photo,
                    size: 30,
                    color: Color.fromARGB(255, 98, 85, 139),
                  ),
                  onPressed: () {
                    // TODO: Open Gallery
                  },
                ),

                // Capture button (Takes picture)
                GestureDetector(
                  onTap: _captureImage, // Capture image
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

                // Checkmark button (Confirm selection)
                GestureDetector(
                  onTap: () {
                    // TODO: Upload multiple captured images
                    print("Images to upload: ${_capturedImages.length}");
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6), // Inset fix
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

          Container(
            color: Color.fromARGB(255, 243, 237, 246),
            child: BottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: Color.fromARGB(255, 98, 85, 139),
              unselectedItemColor: Colors.black54,
              backgroundColor: Color.fromARGB(255, 243, 237, 246),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: "Saved",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
