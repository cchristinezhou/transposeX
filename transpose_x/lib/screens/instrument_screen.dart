import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that allows users to add, view, and manage their musical instruments.
///
/// The list of instruments is saved locally using SharedPreferences.
class InstrumentScreen extends StatefulWidget {
  /// Creates an instance of [InstrumentScreen].
  const InstrumentScreen({super.key});

  @override
  _InstrumentScreenState createState() => _InstrumentScreenState();
}

class _InstrumentScreenState extends State<InstrumentScreen> {
  /// Controller for the instrument input text field.
  final TextEditingController _instrumentController = TextEditingController();

  /// The list of instruments entered by the user.
  List<String> _instruments = [];

  @override
  void initState() {
    super.initState();
    _loadCachedInstruments();
  }

  /// Loads cached instruments from SharedPreferences.
  Future<void> _loadCachedInstruments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _instruments = prefs.getStringList('instruments') ?? [];
    });
  }

  /// Saves the current list of instruments to SharedPreferences.
  Future<void> _saveInstrumentsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('instruments', _instruments);
  }

  /// Adds a new instrument to the list.
  void _addInstrument() {
    final instrument = _instrumentController.text.trim();
    if (instrument.isNotEmpty) {
      setState(() {
        _instruments.add(instrument);
        _instrumentController.clear();
      });
      _saveInstrumentsToCache();
    }
  }

  /// Deletes an instrument at the specified index.
  void _deleteInstrument(int index) {
    setState(() {
      _instruments.removeAt(index);
    });
    _saveInstrumentsToCache();
  }

  @override
  void dispose() {
    _instrumentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.accent,
        leading: Semantics(
          label: "Back to previous screen",
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text("Back", style: AppTextStyles.bodyMedium),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Instrument", style: AppTextStyles.bodyMedium),
            const SizedBox(height: 5),
            Semantics(
              label: "Enter the name of an instrument",
              child: TextField(
                controller: _instrumentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.subtitleGrey),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  hintText: "e.g., Violin",
                  hintStyle: AppTextStyles.bodyText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Semantics(
                label: "Button to add a new instrument",
                button: true,
                child: ElevatedButton(
                  onPressed: _addInstrument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(color: AppColors.primaryPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Add an Instrument",
                    style: AppTextStyles.primaryAction,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Semantics(
                label: "List of saved instruments",
                child: ListView.builder(
                  itemCount: _instruments.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          _instruments[index],
                          style: AppTextStyles.bodyText,
                        ),
                        trailing: Semantics(
                          label: "Delete ${_instruments[index]}",
                          button: true,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.warningRed,
                            ),
                            onPressed: () => _deleteInstrument(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Semantics(
        label: "Bottom navigation with Home, Saved, and Profile options",
        child: BottomNavigationBar(
          currentIndex: 2,
          selectedItemColor: AppColors.primaryPurple,
          unselectedItemColor: AppColors.subtitleGrey,
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