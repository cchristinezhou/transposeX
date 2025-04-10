import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://10.0.0.246:3000"; // ← machine's IP on the same network
      // TODO: REPLACE THE IP ADDRESS BEFORE DEPLOYING
  static const String audiverisUrl = "$baseUrl/upload";
  static const String transposeUrl = "https://your-transpose-api.com/transpose";
  static const String savedSongsUrl = "$baseUrl/saved-songs";
  static const String saveSongUrl = "$baseUrl/save-song";

  // Upload multiple files sequentially
  static Future<bool> uploadFiles(List<String> filePaths) async {
    for (String filePath in filePaths) {
      String? result = await uploadFile(filePath, "DefaultSheetName");
      if (result == null) return false;
    }
    return true;
  }

  // Upload a single file and return the XML content
  static Future<String?> uploadFile(String filePath, String sheetName) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(audiverisUrl));
      request.files.add(
        await http.MultipartFile.fromPath('musicImage', filePath),
      );
      request.fields['sheetName'] = sheetName;

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        final xmlPath = json['xmlPath'];

        final xmlResponse = await http.get(Uri.parse("$baseUrl$xmlPath"));

        if (xmlResponse.statusCode == 200) {
          return xmlResponse.body;
        } else {
          print("❌ XML fetch failed with status: ${xmlResponse.statusCode}");
        }
      } else {
        print("❌ Upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Upload or XML fetch failed: $e");
    }

    return null;
  }

  // Save transposed song info to backend
  static Future<bool> saveSongToDatabase({
    required String name,
    required String xml,
    required String originalKey,
    required String transposedKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(saveSongUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "xml": xml,
          "originalKey": originalKey,
          "transposedKey": transposedKey,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Song saved successfully");
        return true;
      } else {
        print("❌ Failed to save song: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error saving song to DB: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedSongs() async {
    final response = await http.get(Uri.parse(savedSongsUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load saved songs');
    }
  }

  // Delete a song from the library
  static Future<bool> deleteSongFromDatabase(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/songs/$id'),
    );

    if (response.statusCode == 200) {
      print("✅ Song deleted successfully");
      return true;
    } else {
      print("❌ Failed to delete song: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ Error deleting song: $e");
    return false;
  }
}
}
