import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart' as http; // TODO: Uncomment for real backend

class ApiService {
  static const String _audiverisUrl = "http://10.0.0.246:3000/upload";
  static const String _transposeUrl = "https://your-transpose-api.com/transpose";

  // Upload multiple files sequentially
  static Future<bool> uploadFiles(List<String> filePaths) async {
    // TODO: Restore real backend logic later
    // for (String filePath in filePaths) {
    //   if (!await uploadFile(filePath)) return false;
    // }
    // return true;

    return true; // Mock: Always succeed
  }

  // Upload a single file
  static Future<bool> uploadFile(String filePath) async {
    // TODO: Restore real backend logic later
    // try {
    //   var request = http.MultipartRequest("POST", Uri.parse(_audiverisUrl));
    //   request.files.add(await http.MultipartFile.fromPath('musicImage', filePath));
    //   var response = await request.send();
    //   return response.statusCode == 200;
    // } catch (e) {
    //   return false;
    // }

    return true; // Mock: Always succeed
  }

  // TODO (NEED TO REMOVE): Mock function to load Fur Elise from assets
  static Future<String> getMockXml() async {
    return await rootBundle.loadString('assets/3.1.a.Fur_Elise.xml');
  }
}