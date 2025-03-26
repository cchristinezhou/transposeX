import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _audiverisUrl = "http://10.0.0.246:3000/upload";
  static const String _transposeUrl = "https://your-transpose-api.com/transpose";

  // Upload multiple files sequentially
  static Future<bool> uploadFiles(List<String> filePaths) async {
    for (String filePath in filePaths) {
      if (!await uploadFile(filePath)) return false; // Stop if any upload fails
    }
    return true; // All uploads successful
  }

  // Upload a single file
  static Future<bool> uploadFile(String filePath) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(_audiverisUrl));
      request.files.add(await http.MultipartFile.fromPath('musicImage', filePath));

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}