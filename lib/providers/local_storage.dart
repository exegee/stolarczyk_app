import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageProvider {
  static Future<void> writeFile(File file, String filename, String ext) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    await file.copy('$path/$filename.$ext');
  }
}
