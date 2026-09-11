import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';
import 'database_helper.dart';

class StorageService {
  static const String _keyMedicines = 'saved_medicines_v2';

  /// Reactive notifier that triggers UI updates whenever a medicine is saved or deleted
  static final ValueNotifier<List<Medicine>> medicinesNotifier =
      ValueNotifier<List<Medicine>>([]);

  /// Get current list of saved medicines
  static List<Medicine> getMedicines() => medicinesNotifier.value;

  /// Initialize: loads from real SQLite database on mobile, and localStorage on web
  static Future<void> init() async {
    try {
      if (!kIsWeb) {
        // Native SQLite on Android & iOS
        final dbList = await DatabaseHelper.instance.getAllMedicines();
        medicinesNotifier.value = dbList;
        debugPrint('StorageService (SQLite): Loaded ${dbList.length} medicines');
        return;
      } else {
        // Web testing fallback
        final prefs = await SharedPreferences.getInstance();
        final String? jsonStr = prefs.getString(_keyMedicines);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
          final loaded = decoded
              .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
              .toList();
          medicinesNotifier.value = loaded;
          debugPrint('StorageService (Web): Loaded ${loaded.length} medicines');
          return;
        }
      }
    } catch (e) {
      debugPrint('StorageService init error: $e');
    }
    medicinesNotifier.value = [];
  }

  /// Save medicine: writes to real SQLite database on mobile
  static Future<void> saveMedicine(Medicine medicine) async {
    try {
      // 1. Update in-memory reactive list immediately (0ms UI latency)
      final current = List<Medicine>.from(medicinesNotifier.value);
      current.removeWhere((m) =>
          m.name.trim().toLowerCase() == medicine.name.trim().toLowerCase() &&
          m.batchNo.trim().toLowerCase() == medicine.batchNo.trim().toLowerCase());
      current.insert(0, medicine);
      medicinesNotifier.value = current;

      // 2. Persist to real SQLite database on Mobile!
      if (!kIsWeb) {
        final insertedId = await DatabaseHelper.instance.insert(medicine);
        debugPrint('StorageService (SQLite): Inserted into medicines.db with id $insertedId');
      } else {
        final prefs = await SharedPreferences.getInstance();
        final encoded = jsonEncode(current.map((m) => m.toJson()).toList());
        await prefs.setString(_keyMedicines, encoded);
        debugPrint('StorageService (Web): Saved to localStorage');
      }
    } catch (e) {
      debugPrint('StorageService save error: $e');
    }
  }

  /// Delete medicine: removes from SQLite database on mobile
  static Future<void> deleteMedicine(int index) async {
    try {
      final current = List<Medicine>.from(medicinesNotifier.value);
      if (index >= 0 && index < current.length) {
        final removed = current.removeAt(index);
        medicinesNotifier.value = current;

        if (!kIsWeb) {
          if (removed.id != null) {
            await DatabaseHelper.instance.delete(removed.id!);
          } else {
            await DatabaseHelper.instance.deleteByNameAndBatch(removed.name, removed.batchNo);
          }
          debugPrint('StorageService (SQLite): Deleted "${removed.name}" from medicines.db');
        } else {
          final prefs = await SharedPreferences.getInstance();
          final encoded = jsonEncode(current.map((m) => m.toJson()).toList());
          await prefs.setString(_keyMedicines, encoded);
          debugPrint('StorageService (Web): Deleted from localStorage');
        }
      }
    } catch (e) {
      debugPrint('StorageService delete error: $e');
    }
  }
}
