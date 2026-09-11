import 'package:intl/intl.dart';

class Medicine {
  final int? id;
  final String name;
  final String genericName;
  final String dosage;
  final String manufacturer;
  final String batchNo;
  final DateTime mfgDate;
  final DateTime expDate;
  final String description;

  Medicine({
    this.id,
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.manufacturer,
    required this.batchNo,
    required this.mfgDate,
    required this.expDate,
    required this.description,
  });

  /// Map for SQLite database storage
  Map<String, dynamic> toMap() {
    final df = DateFormat('yyyy-MM-dd');
    return {
      if (id != null) 'id': id,
      'name': name,
      'generic_name': genericName,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'batch_no': batchNo,
      'mfg_date': df.format(mfgDate),
      'exp_date': df.format(expDate),
      'description': description,
    };
  }

  /// Create Medicine from SQLite database row
  factory Medicine.fromMap(Map<String, dynamic> map) {
    final df = DateFormat('yyyy-MM-dd');
    return Medicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      genericName: (map['generic_name'] ?? map['genericName'] ?? '') as String,
      dosage: map['dosage'] as String,
      manufacturer: map['manufacturer'] as String,
      batchNo: (map['batch_no'] ?? map['batchNo'] ?? '') as String,
      mfgDate: df.parse((map['mfg_date'] ?? map['mfgDate']) as String),
      expDate: df.parse((map['exp_date'] ?? map['expDate']) as String),
      description: (map['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine.fromMap(json);

  Medicine copyWith({int? id}) {
    return Medicine(
      id: id ?? this.id,
      name: name,
      genericName: genericName,
      dosage: dosage,
      manufacturer: manufacturer,
      batchNo: batchNo,
      mfgDate: mfgDate,
      expDate: expDate,
      description: description,
    );
  }

  /// Generates a lightweight web URL with query parameters.
  /// When scanned by any camera, phone immediately shows "Open in Safari / Chrome"
  /// and opens the static serverless viewer page!
  String toWebUrl({required String baseUrl}) {
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
