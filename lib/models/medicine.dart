import 'package:intl/intl.dart';

class Medicine {
  final String name;
  final String genericName;
  final String dosage;
  final String manufacturer;
  final String batchNo;
  final DateTime mfgDate;
  final DateTime expDate;
  final String description;

  // Default testing URL - points to local network IP so phone on Wi-Fi can scan and open it!
  static const String defaultLocalBaseUrl = 'http://192.168.0.104:8081/view.html';

  Medicine({
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.manufacturer,
    required this.batchNo,
    required this.mfgDate,
    required this.expDate,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final df = DateFormat('yyyy-MM-dd');
    return {
      'name': name,
      'genericName': genericName,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'batchNo': batchNo,
      'mfgDate': df.format(mfgDate),
      'expDate': df.format(expDate),
      'description': description,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final df = DateFormat('yyyy-MM-dd');
    return Medicine(
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      manufacturer: json['manufacturer'] as String,
      batchNo: json['batchNo'] as String,
      mfgDate: df.parse(json['mfgDate'] as String),
      expDate: df.parse(json['expDate'] as String),
      description: json['description'] as String,
    );
  }

  /// Generates a lightweight web URL with query parameters.
  /// When scanned by any camera, phone immediately shows "Open in Safari / Chrome"
  /// and opens the static serverless viewer page!
  String toWebUrl({String baseUrl = defaultLocalBaseUrl}) {
    final df = DateFormat('yyyy-MM-dd');
    final queryParams = <String, String>{
      'n': name,
      if (genericName.isNotEmpty) 'g': genericName,
      'd': dosage,
      'm': manufacturer,
      'b': batchNo,
      'mf': df.format(mfgDate),
      'ex': df.format(expDate),
      if (description.isNotEmpty) 's': description,
    };

    final uri = Uri.parse(baseUrl);
    return uri.replace(queryParameters: queryParams).toString();
  }
}
