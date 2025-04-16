import 'package:flutter/material.dart';
import 'key_info_screen.dart';
import 'transposing_screen.dart';

class TransposeOptionsScreen extends StatefulWidget {
  final String originalKey;
  final String xmlContent;

  const TransposeOptionsScreen({
    required this.originalKey,
    required this.xmlContent,
    Key? key,
  }) : super(key: key);

  @override
  State<TransposeOptionsScreen> createState() => _TransposeOptionsScreenState();
}

class _TransposeOptionsScreenState extends State<TransposeOptionsScreen> {
  late String currentKey;
  late int currentIndex;
  late bool isMinor;
  bool showSharps = true;

  final List<String> sharpKeys = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ];

  final List<String> flatKeys = [
    "C",
    "D♭",
    "D",
    "E♭",
    "E",
    "F",
    "G♭",
    "G",
    "A♭",
    "A",
    "B♭",
    "B",
  ];

  @override
  void initState() {
    super.initState();
    _initializeKeyState(widget.originalKey);
  }

  void _initializeKeyState(String key) {
    final parts = key.split(' ');
    final base = parts[0];
    isMinor = parts.length > 1 && parts[1].toLowerCase() == "minor";

    if (sharpKeys.contains(base)) {
      showSharps = true;
      currentIndex = sharpKeys.indexOf(base);
    } else if (flatKeys.contains(base)) {
      showSharps = false;
      currentIndex = flatKeys.indexOf(base);
    } else {
      showSharps = true;
      currentIndex = 0;
    }

    _updateCurrentKey();
  }

  void _updateCurrentKey() {
    final keyList = showSharps ? sharpKeys : flatKeys;
    currentKey = keyList[currentIndex] + (isMinor ? " minor" : " major");
  }

  void _transposeUp() {
    setState(() {
      currentIndex = (currentIndex + 1) % sharpKeys.length;
      _updateCurrentKey();
    });
  }

  void _transposeDown() {
    setState(() {
      currentIndex = (currentIndex - 1 + sharpKeys.length) % sharpKeys.length;
      _updateCurrentKey();
    });
  }

  void _onTransposePressed() {
  final original = widget.originalKey.trim().toLowerCase();
  final selected = currentKey.trim().toLowerCase();

  if (original == selected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Oops! That’s the same key. Try transposing to spice things up 🎶"),
        backgroundColor: Color.fromARGB(255, 98, 85, 139),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 2),
      ),
    );
  } else {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => TransposingScreen(
      xmlContent: widget.xmlContent,
      originalKey: widget.originalKey,
      transposedKey: currentKey,
      songName: "Uploaded Sheet",
    ),
  ),
);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TOP — Key detection result
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Detection Successful!",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "It looks like your sheet is in ${widget.originalKey}.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "* We only detect the dominant key. For more info, ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => KeyInfoScreen()),
                          );
                        },
                        child: Text(
                          "learn more here.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 98, 85, 139),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // CENTER — Transpose controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Show as: "),
                        SizedBox(width: 6),
                        ChoiceChip(
                          label: Text("♯"),
                          selected: showSharps,
                          onSelected: (_) {
                            setState(() {
                              showSharps = true;
                              _updateCurrentKey();
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text("♭"),
                          selected: !showSharps,
                          onSelected: (_) {
                            setState(() {
                              showSharps = false;
                              _updateCurrentKey();
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Transpose UI
                    Text(
                      "Transpose Options",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentKey,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          onPressed: _transposeUp,
                          icon: Icon(Icons.add_circle_outline),
                          color: Color.fromARGB(255, 98, 85, 139),
                        ),
                        IconButton(
                          onPressed: _transposeDown,
                          icon: Icon(Icons.remove_circle_outline),
                          color: Color.fromARGB(255, 98, 85, 139),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _onTransposePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 98, 85, 139),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Transpose",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
