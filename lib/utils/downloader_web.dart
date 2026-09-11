import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

class FileDownloader {
  static Future<String?> downloadPng(Uint8List bytes, String filename) async {
    try {
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = filename;
      anchor.click();
      web.URL.revokeObjectURL(url);
      return filename;
    } catch (e) {
      return null;
    }
  }
}
