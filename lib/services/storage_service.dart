import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _keyMedicines = 'saved_medicines_v2';

  /// Reactive notifier that triggers UI updates whenever a medicine is saved or deleted
  static final ValueNotifier<List<Medicine>> medicinesNotifier =
      ValueNotifier<List<Medicine>>([]);

  /// Get current list of saved medicines
  static List<Medicine> getMedicines() => medicinesNotifier.value;

  /// Initialize and load saved medicines from storage into memory
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyMedicines);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        final loaded = decoded
            .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
            .toList();
        medicinesNotifier.value = loaded;
        debugPrint('StorageService: Loaded ${loaded.length} medicines');
        return;
      }
    } catch (e) {
      debugPrint('StorageService init error: $e');
    }
    medicinesNotifier.value = [];
  }

  /// Save medicine to memory (instant UI update) and persist to local storage
  static Future<void> saveMedicine(Medicine medicine) async {
    try {
      // 1. Update in-memory reactive list immediately
      final current = List<Medicine>.from(medicinesNotifier.value);
      current.removeWhere((m) =>
          m.name.trim().toLowerCase() == medicine.name.trim().toLowerCase() &&
          m.batchNo.trim().toLowerCase() == medicine.batchNo.trim().toLowerCase());
      current.insert(0, medicine);
      medicinesNotifier.value = current;

      // 2. Persist to storage
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(current.map((m) => m.toJson()).toList());
      await prefs.setString(_keyMedicines, encoded);
      debugPrint('StorageService: Successfully saved "${medicine.name}". Total: ${current.length}');
    } catch (e) {
      debugPrint('StorageService save error: $e');
    }
  }

  /// Delete medicine by index
  static Future<void> deleteMedicine(int index) async {
    try {
      final current = List<Medicine>.from(medicinesNotifier.value);
      if (index >= 0 && index < current.length) {
        final removed = current.removeAt(index);
        medicinesNotifier.value = current;

        final prefs = await SharedPreferences.getInstance();
        final encoded = jsonEncode(current.map((m) => m.toJson()).toList());
        await prefs.setString(_keyMedicines, encoded);
        debugPrint('StorageService: Deleted "${removed.name}". Remaining: ${current.length}');
      }
    } catch (e) {
      debugPrint('StorageService delete error: $e');
    }
  }
}
