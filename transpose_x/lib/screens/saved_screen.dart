import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import 'view_sheet_screen.dart'; // Make sure this import is included

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> savedSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSavedSongs();
  }

Future<void> fetchSavedSongs() async {
  try {
    final rawSongs = await ApiService.getSavedSongs();

    // Filter and map to only include valid entries
    final songs = rawSongs
        .where((song) =>
            song["id"] != null &&
            song["name"] != null &&
            song["xml"] != null &&
            song["transposedKey"] != null)
        .map<Map<String, dynamic>>((song) => {
              "id": song["id"],
              "name": song["name"],
              "xml": song["xml"],
              "originalKey": song["originalKey"] ?? "Unknown",
              "transposedKey": song["transposedKey"] ?? "Unknown",
              "createdTime": song["createdTime"] ?? "",
            })
        .toList();

    setState(() {
      savedSongs = songs;
      isLoading = false;
    });
  } catch (e) {
    print("❌ Failed to load songs: $e");
    setState(() => isLoading = false);
  }
}

  void _showRenameDialog(BuildContext context, int index) {
    TextEditingController _controller = TextEditingController(
      text: savedSongs[index]["name"] ?? "Untitled",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Rename Your Music Sheet"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Enter new name",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 98, 85, 139),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                savedSongs[index]["name"] = _controller.text;
              });
              Navigator.pop(context);
              // Optionally: update backend
            },
            child: Text("Save", style: TextStyle(color: Color.fromARGB(255, 98, 85, 139))),
          ),
        ],
      ),
    );
  }

  void _shareSheetMusic(String songTitle, String key) {
    Share.share("Check out my sheet music: $songTitle 🎶 in $key.");
  }

  void _showOptionsMenu(BuildContext context, int index) async {
    final localContext = context;

    final songId = savedSongs[index]["id"];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Song"),
        content: const Text("Are you sure you want to delete this song?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final success = await ApiService.deleteSongFromDatabase(songId);
    if (!mounted) return;

    if (success) {
      setState(() => savedSongs.removeAt(index));
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text("✅ Song deleted")),
      );
    } else {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text("❌ Failed to delete the song")),
      );
    }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedSongs.isEmpty
              ? Center(child: Text("No saved songs yet 💤"))
              : Scrollbar(
                  thumbVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(10),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: savedSongs.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final song = savedSongs[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewSheetScreen(
                                xmlContent: song["xml"] ?? "",
                                keySignature: song["transposedKey"] ?? "Unknown",
                                fileName: song["name"] ?? "Untitled",
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.description, size: 28, color: Colors.black),
                        title: Text(
                          song["name"] ?? "Untitled",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          song["transposedKey"] ?? "Unknown",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                          onPressed: () => _showOptionsMenu(context, index),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}