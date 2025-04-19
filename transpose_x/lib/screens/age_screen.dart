import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen where the user can select and save their age.
///
/// The selected age is persisted locally using SharedPreferences.
class AgeScreen extends StatefulWidget {
  /// Creates an instance of [AgeScreen].
  const AgeScreen({super.key});

  @override
  _AgeScreenState createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  /// The currently selected age.
  int? _selectedAge = 20; // Default selected age is 20

  @override
  void initState() {
    super.initState();
    _loadCachedAge();
  }

  /// Loads the previously saved age from SharedPreferences.
  Future<void> _loadCachedAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAge = prefs.getInt('age') ?? 20;
    });
  }

  /// Saves the currently selected age to SharedPreferences.
  Future<void> _saveAgeToCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedAge != null) {
      await prefs.setInt('age', _selectedAge!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.accent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back to Profile",
          onPressed: () async {
            await _saveAgeToCache(); // Save selected age
            Navigator.pop(context);
          },
        ),
        title: const Text("Back", style: AppTextStyles.buttonText),
        centerTitle: false,
      ),
      body: Semantics(
        label: "Age selection screen",
        explicitChildNodes: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: AppColors.subtitleGrey, size: 20),
                  SizedBox(width: 8),
                  Semantics(
                    header: true,
                    child: Text("Your Age", style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.subtitleGrey),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: DropdownButton<int>(
                  value: _selectedAge,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  dropdownColor: AppColors.offWhite,
                  underline: const SizedBox(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedAge = newValue;
                    });
                  },
                  items:
                      List.generate(
                        101,
                        (index) => index,
                      ).map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Semantics(
                            label: "Age $value",
                            child: Center(
                              child: Text(
                                value.toString(),
                                style: AppTextStyles.bodyText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.subtitleGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Go to Home screen",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Saved",
            tooltip: "Go to Saved screen",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
            tooltip: "Go to Profile screen",
          ),
        ],
      ),
    );
  }
}
