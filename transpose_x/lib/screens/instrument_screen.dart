import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'saved_screen.dart';

class InstrumentScreen extends StatefulWidget {
  @override
  _InstrumentScreenState createState() => _InstrumentScreenState();
}

class _InstrumentScreenState extends State<InstrumentScreen> {
  final TextEditingController _instrumentController = TextEditingController();
  List<String> _instruments = [];

  @override
  void initState() {
    super.initState();
    _loadCachedInstruments();
  }

  Future<void> _loadCachedInstruments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _instruments = prefs.getStringList('instruments') ?? [];
    });
  }

  Future<void> _saveInstrumentsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('instruments', _instruments);
  }

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

  void _deleteInstrument(int index) {
    setState(() {
      _instruments.removeAt(index);
    });
    _saveInstrumentsToCache();
  }

  @override
  void dispose() {
    _saveInstrumentsToCache();
    _instrumentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Back",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Instrument", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            TextField(
              controller: _instrumentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: "Value",
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addInstrument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color.fromARGB(255, 98, 85, 139),
                  side: BorderSide(color: Color.fromARGB(255, 98, 85, 139)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text("Add an Instrument"),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _instruments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(_instruments[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteInstrument(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Color.fromARGB(255, 98, 85, 139),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          await _saveInstrumentsToCache();
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SavedScreen()),
            );
          }
        },
      ),
    );
  }
}