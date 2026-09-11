import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicine_data_qr/models/medicine.dart';
import 'package:medicine_data_qr/services/storage_service.dart';

void main() {
  test('StorageService save and load', () async {
    SharedPreferences.setMockInitialValues({});
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
    expect(list.length, 1);
    expect(list.first.name, 'Paracetamol');
  });
}
