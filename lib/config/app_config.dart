class AppConfig {
  /// Live production hosted URL on GitHub Pages.
  /// When your aunt or anyone scans the QR from a medicine strip, this is the URL that opens!
  static const String productionViewerUrl =
      'https://soham-1304.github.io/Medicine_Data_QR/view.html';

  /// Always use the live production GitHub Pages URL so every QR code
  /// scanned from any phone camera in the world opens the live medicine card!
  static String get viewerBaseUrl => productionViewerUrl;
}
