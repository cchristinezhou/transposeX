import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      "http://10.0.0.246:3000"; // Change for deployment
  static const String _uploadEndpoint = "$_baseUrl/upload";
  static const String _transposeEndpoint = "$_baseUrl/api/transpose";
  static const String _savedSongsEndpoint = "$_baseUrl/saved-songs";
  static const String _saveSongEndpoint = "$_baseUrl/save-song";

  /// Upload a single image file and return its MusicXML content as a string
  static Future<String?> uploadFile(String filePath, String sheetName) async {
    try {
      final request = http.MultipartRequest("POST", Uri.parse(_uploadEndpoint));
      request.files.add(
        await http.MultipartFile.fromPath('musicImage', filePath),
      );
      request.fields['sheetName'] = sheetName;

      final response = await request.send();

      if (response.statusCode != 200) {
        print("❌ Upload failed: ${response.statusCode}");
        return null;
      }

      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final xmlPath = jsonResponse['xmlPath'];

      final xmlResponse = await http.get(Uri.parse("$_baseUrl$xmlPath"));

      if (xmlResponse.statusCode == 200) {
        return xmlResponse.body;
      } else {
        print("❌ Failed to fetch XML file: ${xmlResponse.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ uploadFile error: $e");
      return null;
    }
  }

  /// Upload a single file and get raw file content as bytes (for MXL/XML cases)
  static Future<Uint8List?> uploadFileReturningBytes(
    String filePath,
    String sheetName,
  ) async {
    try {
      final request = http.MultipartRequest("POST", Uri.parse(_uploadEndpoint));
      request.files.add(
        await http.MultipartFile.fromPath('musicImage', filePath),
      );
      request.fields['sheetName'] = sheetName;

      final response = await request.send();

      if (response.statusCode != 200) {
        print("❌ Upload failed: ${response.statusCode}");
        return null;
      }

      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final xmlPath = jsonResponse['xmlPath'];

      final xmlResponse = await http.get(Uri.parse("$_baseUrl$xmlPath"));

      if (xmlResponse.statusCode == 200) {
        return xmlResponse.bodyBytes;
      } else {
        print("❌ Failed to fetch raw file: ${xmlResponse.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ uploadFileReturningBytes error: $e");
      return null;
    }
  }

  /// Upload multiple files and return true if all succeed
  static Future<bool> uploadFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      final result = await uploadFile(path, "DefaultSheetName");
      if (result == null) return false;
    }
    return true;
  }

  /// Request transposed XML with a given interval
  static Future<String> transposeSong({
    required String xml,
    required int interval,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_transposeEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'xml': xml, 'interval': interval}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transposedXml'];
      } else {
        throw Exception('Failed to transpose XML: ${response.body}');
      }
    } catch (e) {
      print("❌ transposeSong error: $e");
      rethrow;
    }
  }

  /// Save a transposed song to the backend
  static Future<bool> saveSongToDatabase({
    required String name,
    required String xml,
    required String originalKey,
    required String transposedKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_saveSongEndpoint),
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
      print("❌ saveSongToDatabase error: $e");
      return false;
    }
  }

  /// Fetch list of saved songs from the backend
  static Future<List<Map<String, dynamic>>> getSavedSongs() async {
    try {
      final response = await http.get(Uri.parse(_savedSongsEndpoint));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load saved songs');
      }
    } catch (e) {
      print("❌ getSavedSongs error: $e");
      return [];
    }
  }

  /// Delete a saved song by its ID
  static Future<bool> deleteSongFromDatabase(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/songs/$id'));

      if (response.statusCode == 200) {
        print("✅ Song deleted");
        return true;
      } else {
        print("❌ Failed to delete song: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ deleteSongFromDatabase error: $e");
      return false;
    }
  }
}
