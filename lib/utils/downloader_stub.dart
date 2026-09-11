import 'dart:typed_data';

abstract class FileDownloader {
  static Future<String?> downloadPng(Uint8List bytes, String filename) {
    throw UnsupportedError('Platform not supported');
  }
}
