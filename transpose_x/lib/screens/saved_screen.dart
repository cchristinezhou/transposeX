import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  // Hardcoded list of saved songs
  // TODO: Replace with actual saved songs
  final List<Map<String, String>> savedSongs = [
    {"title": "Feather", "key": "G Major"},
    {"title": "Nonsense", "key": "C Minor"},
    {"title": "Anti-Hero", "key": "E Major"}, // Taylor Swift
    {"title": "Flowers", "key": "A Minor"}, // Miley Cyrus
    {"title": "As It Was", "key": "D Major"}, // Harry Styles
    {"title": "Good 4 U", "key": "C Minor"}, // Olivia Rodrigo
    {"title": "Shivers", "key": "B Minor"}, // Ed Sheeran
    {"title": "Levitating", "key": "F Major"}, // Dua Lipa
    {"title": "Save Your Tears", "key": "G Minor"}, // The Weeknd
  ];

  void _showOptionsMenu(BuildContext context, String songTitle) {
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
                onTap: () {
                  // TODO: Implement share functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.black),
                title: Text("Download"),
                onTap: () {
                  // TODO: Implement download functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.black),
                title: Text("Edit name"),
                onTap: () {
                  // TODO: Implement rename functionality
                  Navigator.pop(context);
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
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(
              Color.fromARGB(255, 98, 85, 139),
            ), // Purple Scrollbar
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
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final song = savedSongs[index];
              return GestureDetector(
                onTap:
                    () => _showOptionsMenu(
                      context,
                      song["title"]!,
                    ), // Tap anywhere to open menu
                child: ListTile(
                  leading: Icon(
                    Icons.description,
                    size: 28,
                    color: Colors.black,
                  ),
                  title: Text(
                    song["title"]!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    song["key"]!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed:
                        () => _showOptionsMenu(
                          context,
                          song["title"]!,
                        ), // Three-dot menu opens pop-up
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
