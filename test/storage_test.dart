import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_data_qr/models/medicine.dart';
import 'package:medicine_data_qr/services/storage_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('StorageService SQLite save and load', () async {
    final med = Medicine(
      name: 'Paracetamol',
      genericName: 'Acetaminophen',
      dosage: '500mg',
      manufacturer: 'Cipla',
      batchNo: 'B101',
      mfgDate: DateTime(2026, 1, 1),
      expDate: DateTime(2028, 1, 1),
      description: 'Pain relief',
    );

    await StorageService.saveMedicine(med);
    final list = StorageService.getMedicines();
    expect(list.isNotEmpty, true);
    expect(list.first.name, 'Paracetamol');
  });
}
