import 'package:flutter/material.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // Store song list in a mutable state
  List<Map<String, String>> savedSongs = [
    {"title": "Feather", "key": "G Major"},
    {"title": "Nonsense", "key": "C Minor"},
    {"title": "Anti-Hero", "key": "E Major"},
    {"title": "Flowers", "key": "A Minor"},
    {"title": "As It Was", "key": "D Major"},
    {"title": "Good 4 U", "key": "C Minor"},
  ];

  // Function to show rename dialog
  void _showRenameDialog(BuildContext context, int index) {
    TextEditingController _controller = TextEditingController(text: savedSongs[index]["title"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
          title: Text("Rename Your Music Sheet"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter new name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 98, 85, 139)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedSongs[index]["title"] = _controller.text; // Update song name
                });
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
            ),
          ],
        );
      },
    );
  }

  // Function to show the bottom sheet menu
  void _showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 243, 237, 246),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share, color: Colors.black),
                title: Text("Share"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.black),
                title: Text("Download"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.black),
                title: Text("Edit name"),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, index); // Open rename dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Saved",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Color.fromARGB(255, 98, 85, 139)),
            trackColor: MaterialStateProperty.all(Colors.transparent),
            trackVisibility: MaterialStateProperty.all(false),
          ),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: Radius.circular(10),
          scrollbarOrientation: ScrollbarOrientation.right,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: savedSongs.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final song = savedSongs[index];
              return GestureDetector(
                onTap: () => _showOptionsMenu(context, index), // Tap anywhere to open menu
                child: ListTile(
                  leading: Icon(Icons.description, size: 28, color: Colors.black),
                  title: Text(
                    song["title"]!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(song["key"]!, style: TextStyle(color: Colors.grey[700])),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed: () => _showOptionsMenu(context, index), // Three-dot menu opens pop-up
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}