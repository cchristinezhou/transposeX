import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/xml_merge_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'view_uploaded_sheet_screen.dart';

/// The main entry point of the app after login/splash.
///
/// Provides bottom navigation between Home, Saved, and Profile screens.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The currently selected index in the bottom navigation bar.
  int _selectedIndex = 0;

  /// List of screens mapped to each bottom navigation tab.
  final List<Widget> _screens = [
    HomeScreenContent(),
    SavedScreen(),
    ProfileScreen(),
  ];

  /// Handles tab switching when a bottom navigation item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Semantics(
        label: "Bottom navigation bar with Home, Saved, and Profile options.",
        child: Container(
          color: AppColors.offWhite,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryPurple,
            unselectedItemColor: Colors.black54,
            backgroundColor: AppColors.offWhite,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
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
      ),
    );
  }
}

/// The content displayed when the user is on the Home tab.
///
/// Guides users to take a picture or upload sheet music.
class HomeScreenContent extends StatelessWidget {
  /// Picks files from the user's gallery and attempts to merge/upload them.
  Future<void> _pickFilesAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile>? selectedFiles = await picker.pickMultiImage();

    if (selectedFiles == null || selectedFiles.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final mergedXml = await XmlMergeHelper.processAndMergeFiles(selectedFiles);

      Navigator.pop(context); // Hide loading spinner

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

  /// Shows an error dialog when upload or processing fails.
  void _showErrorDialog(BuildContext context, UploadErrorType type) {
    String errorMessage;
    if (type == UploadErrorType.xml) {
      errorMessage =
          "The files you selected aren’t clear. Please upload a different file.";
    } else {
      errorMessage =
          "There seems to be an issue with your network. Please retry.";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Warning",
          style: AppTextStyles.heading,
        ),
        content: Text(
          errorMessage,
          style: AppTextStyles.subtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: AppColors.primaryPurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickFilesAndUpload(context);
            },
            child: Text("Retry", style: TextStyle(color: AppColors.primaryPurple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Semantics(
        label: "Home screen. Instructions for using TransposeX and upload options.",
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "TransposeX",
                style: AppTextStyles.heading.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 20),
              Text(
                "How to Use TransposeX",
                style: AppTextStyles.heading.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                "1. Upload Your Music\n"
                "Snap a photo, upload a file, or import a PDF of your sheet music.\n\n"
                "2. Detect & Adjust\n"
                "We’ll identify the key signature automatically.\n\n"
                "3. Download & Play\n"
                "Get your transposed sheet music in seconds.",
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 30),
              Semantics(
                button: true,
                label: "Take a picture of your sheet music",
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Take a Picture",
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Semantics(
                button: true,
                label: "Upload an image of your sheet music",
                child: ElevatedButton(
                  onPressed: () => _pickFilesAndUpload(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Upload", style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enum representing different types of upload errors.
enum UploadErrorType {
  /// Indicates a problem with reading or parsing the XML.
  xml,

  /// Indicates a network connection error.
  network,
}