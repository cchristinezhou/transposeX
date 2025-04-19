// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../utils/file_export.dart';
import 'view_sheet_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that displays a list of saved sheet music,
/// allowing users to rename, download, and share their sheets.
class SavedScreen extends StatefulWidget {
  /// Creates a [SavedScreen].
  const SavedScreen({super.key});

  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  /// List of saved songs retrieved from the backend.
  List<Map<String, dynamic>> savedSongs = [];

  /// Whether the songs are currently being loaded.
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSavedSongs();
  }

  /// Fetches the saved songs from the backend API.
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

  /// Shows a dialog allowing the user to rename a saved song.
  void _showRenameDialog(BuildContext parentContext, int index) {
    final TextEditingController _controller = TextEditingController(
      text: savedSongs[index]["name"] ?? "Untitled",
    );

    showDialog(
      context: parentContext,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Rename Your Music Sheet",
              style: AppTextStyles.heading,
            ),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel", style: AppTextStyles.primaryAction),
              ),
              TextButton(
                onPressed: () async {
                  final newName = _controller.text.trim();
                  final oldName = savedSongs[index]["name"];
                  final scaffoldContext = parentContext;
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
                      _showSnackBar(
                        scaffoldContext,
                        "✅ Renamed successfully!",
                        true,
                      );
                    } else {
                      _showSnackBar(
                        scaffoldContext,
                        "❌ Failed to rename.",
                        false,
                      );
                    }
                  }
                },
                child: const Text("Save", style: AppTextStyles.primaryAction),
              ),
            ],
          ),
    );
  }

  /// Shows a bottom sheet menu with options for a specific saved song.
  void _showOptionsMenu(BuildContext context, int index) {
    final song = savedSongs[index];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (sheetContext) => Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionTile(
                  icon: Icons.edit,
                  label: "Rename",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showRenameDialog(context, index);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.download,
                  label: "Download XML",
                  onTap: () async {
                    final scaffoldContext = context;
                    Navigator.pop(sheetContext);
                    final file = await saveXmlFile(song["xml"]);
                    await saveToDownloads(file);
                    if (mounted) {
                      _showSnackBar(
                        scaffoldContext,
                        "✅ Download successful!",
                        true,
                      );
                    }
                  },
                ),
                _buildOptionTile(
                  icon: Icons.share,
                  label: "Share XML",
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

  /// Builds a tile used inside the bottom sheet options menu.
  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
    );
  }

  /// Shows a [SnackBar] for success or error messages.
  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? AppColors.successGreen : AppColors.warningRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Saved", style: AppTextStyles.heading),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : savedSongs.isEmpty
              ? const Center(
                child: Text(
                  "No saved songs yet 💤",
                  style: AppTextStyles.bodyText,
                ),
              )
              : Scrollbar(
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(10),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: savedSongs.length,
                  separatorBuilder:
                      (context, index) => const Divider(
                        height: 1,
                        color: AppColors.subtitleGrey,
                      ),
                  itemBuilder: (context, index) {
                    final song = savedSongs[index];
                    return Semantics(
                      label: "Saved song: ${song["name"]}",
                      button: true,
                      child: ListTile(
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
                          fetchSavedSongs(); // Refresh list
                        },
                        leading: const Icon(
                          Icons.description,
                          size: 28,
                          color: AppColors.accent,
                        ),
                        title: Text(
                          song["name"] ?? "Untitled",
                          style: AppTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          song["transposedKey"] ?? "Unknown",
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.subtitleGrey,
                          ),
                          onPressed: () => _showOptionsMenu(context, index),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
