import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _audiverisUrl = "https://your-audiveris-api.com/upload";
  static const String _transposeUrl = "https://your-transpose-api.com/transpose";

  static Future<bool> uploadFile(String filePath) async {
    var request = http.MultipartRequest("POST", Uri.parse(_audiverisUrl));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();
    return response.statusCode == 200;
  }

  static Future<String> transposeMusic(String xmlData, String newKey) async {
    var response = await http.post(
      Uri.parse(_transposeUrl),
      body: {'xml': xmlData, 'key': newKey},
    );
    return response.statusCode == 200 ? response.body : "Error";
  }
}