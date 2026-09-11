import 'package:flutter/foundation.dart';

class AppConfig {
  /// Production hosted URL on GitHub Pages where view.html is published.
  /// When your aunt or anyone scans the QR from a medicine strip, this is the URL that opens!
  static const String productionViewerUrl =
      'https://sohamkarandikar.github.io/Medicine_Data_QR/view.html';

  /// Automatically picks the right URL:
  /// - If running on Web: uses current site origin + /view.html (e.g. localhost during dev, or live web URL)
  /// - If running on Mobile (Android / iOS): uses the production GitHub Pages URL
  static String get viewerBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // If deployed in a subfolder or root:
      if (Uri.base.path.contains('/view.html')) {
        return Uri.base.toString().split('?').first;
      }
      return '$origin/view.html';
    }
    return productionViewerUrl;
  }
}
