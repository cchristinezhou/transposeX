import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String audiverisUrl = "http://10.0.0.246:3000/upload";
  static const String transposeUrl = "https://your-transpose-api.com/transpose";

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
      request.files.add(await http.MultipartFile.fromPath('musicImage', filePath));
      request.fields['sheetName'] = sheetName;

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        final xmlPath = json['xmlPath']; // Ex: /MusicXml/filename.mxl

        // Fetch the actual XML content from the server
        final xmlResponse = await http.get(Uri.parse("http://10.0.0.246:3000$xmlPath"));

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
}