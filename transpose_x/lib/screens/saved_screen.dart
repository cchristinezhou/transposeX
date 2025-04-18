import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../utils/file_export.dart';
import 'view_sheet_screen.dart';

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
      final songs =
          rawSongs
              .where(
                (song) =>
                    song["id"] != null &&
                    song["name"] != null &&
                    song["xml"] != null &&
                    song["transposedKey"] != null,
              )
              .map<Map<String, dynamic>>(
                (song) => {
                  "id": song["id"],
                  "name": song["name"],
                  "xml": song["xml"],
                  "originalKey": song["originalKey"] ?? "Unknown",
                  "transposedKey": song["transposedKey"] ?? "Unknown",
                  "createdTime": song["createdTime"] ?? "",
                },
              )
              .toList();
      if (mounted) {
        setState(() {
          savedSongs = songs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Failed to load songs: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showRenameDialog(BuildContext parentContext, int index) {
    TextEditingController _controller = TextEditingController(
      text: savedSongs[index]["name"] ?? "Untitled",
    );

    showDialog(
      context: parentContext,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Color.fromARGB(255, 98, 85, 139)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final newName = _controller.text.trim();
                  final oldName = savedSongs[index]["name"];

                  final scaffoldContext = parentContext; // 👈 Save BEFORE pop
                  Navigator.pop(dialogContext);

                  if (newName.isNotEmpty && oldName != null) {
                    final success = await ApiService.renameSheet(
                      oldName,
                      newName,
                    );

                    if (!mounted) return;

                    if (success) {
                      setState(() {
                        savedSongs[index]["name"] = newName;
                      });
                      _showSuccessSnackBar(
                        scaffoldContext,
                        "✅ Renamed successfully!",
                      );
                    } else {
                      _showErrorSnackBar(
                        scaffoldContext,
                        "❌ Failed to rename.",
                      );
                    }
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Color.fromARGB(255, 98, 85, 139)),
                ),
              ),
            ],
          ),
    );
  }

  void _showOptionsMenu(BuildContext context, int index) {
    final song = savedSongs[index];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (sheetContext) => Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.black),
                  title: Text('Rename'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showRenameDialog(context, index);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.download, color: Colors.black),
                  title: Text('Download XML'),
                  onTap: () async {
                    final scaffoldContext = context;
                    Navigator.pop(sheetContext);
                    final file = await saveXmlFile(song["xml"]);
                    await saveToDownloads(file);
                    if (mounted)
                      _showSuccessSnackBar(
                        scaffoldContext,
                        "✅ Download successful!",
                      );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share, color: Colors.black),
                  title: Text('Share XML'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    shareXmlContent(song["xml"]);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 2),
      ),
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
      body:
          isLoading
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
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey[300]),
                  itemBuilder: (context, index) {
                    final song = savedSongs[index];
                    return ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ViewSheetScreen(
                                  xmlContent: song["xml"] ?? "",
                                  keySignature:
                                      song["transposedKey"] ?? "Unknown",
                                  fileName: song["name"] ?? "Untitled",
                                ),
                          ),
                        );
                        fetchSavedSongs(); // Refresh after editing
                      },
                      leading: Icon(
                        Icons.description,
                        size: 28,
                        color: Colors.black,
                      ),
                      title: Text(
                        song["name"] ?? "Untitled",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
