import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  static Future<String?> downloadPng(Uint8List bytes, String filename) async {
    try {
      Directory? targetDir;

      if (Platform.isAndroid) {
        // Try public Download directory first
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (publicDownload.existsSync()) {
          targetDir = publicDownload;
        } else {
          targetDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        targetDir = await getApplicationDocumentsDirectory();
      }

      targetDir ??= await getTemporaryDirectory();

      final file = File('${targetDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
