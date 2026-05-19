import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/master_data_model.dart';
import '../models/siswa_model.dart';

class LocalStorageService {
  static const String masterDataKey = 'master_data_cache';
  static const String siswaListKey = 'siswa_list_cache';
  static const String siswaListTimestampKey = 'siswa_list_timestamp';

  static SharedPreferences? _prefs;

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    await init();
    return _prefs!;
  }

  Future<void> saveSiswaList(List<SiswaModel> siswaList) async {
    try {
      final prefs = await _getPrefs();
      final jsonList = siswaList.map((siswa) => siswa.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(siswaListKey, jsonString);
      await prefs.setInt(
        siswaListTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is MissingPluginException) {
        throw Exception(
          'Plugin local storage belum aktif. Lakukan full restart aplikasi lalu coba lagi.',
        );
      }
      throw Exception('Gagal menyimpan data siswa ke local storage: $e');
    }
  }

  Future<void> saveMasterData(MasterDataModel masterData) async {
    try {
      final prefs = await _getPrefs();
      final masterDataString = jsonEncode(masterData.toJson());
      final siswaListString = jsonEncode(
        masterData.siswa.map((siswa) => siswa.toJson()).toList(),
      );

      await prefs.setString(masterDataKey, masterDataString);
      await prefs.setString(siswaListKey, siswaListString);
      await prefs.setInt(
        siswaListTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is MissingPluginException) {
        throw Exception(
          'Plugin local storage belum aktif. Lakukan full restart aplikasi lalu coba lagi.',
        );
      }
      throw Exception('Gagal menyimpan master data ke local storage: $e');
    }
  }

  Future<MasterDataModel?> getMasterData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(masterDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final jsonMap = Map<String, dynamic>.from(jsonDecode(jsonString));
      return MasterDataModel.fromJson(jsonMap);
    } catch (e) {
      if (e is MissingPluginException) {
        throw Exception(
          'Plugin local storage belum aktif. Lakukan full restart aplikasi lalu coba lagi.',
        );
      }
      throw Exception('Gagal membaca master data dari local storage: $e');
    }
  }

  Future<List<SiswaModel>> getSiswaList() async {
    try {
      final masterData = await getMasterData();
      if (masterData != null) {
        return masterData.siswa;
      }

      final prefs = await _getPrefs();
      final jsonString = prefs.getString(siswaListKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => SiswaModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      if (e is MissingPluginException) {
        throw Exception(
          'Plugin local storage belum aktif. Lakukan full restart aplikasi lalu coba lagi.',
        );
      }
      throw Exception('Gagal membaca data siswa dari local storage: $e');
    }
  }

  Future<bool> hasSiswaList() async {
    final prefs = await _getPrefs();
    return prefs.containsKey(masterDataKey) || prefs.containsKey(siswaListKey);
  }

  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(masterDataKey);
    await prefs.remove(siswaListKey);
    await prefs.remove(siswaListTimestampKey);
  }

  Future<int?> getLastUpdateTimestamp() async {
    final prefs = await _getPrefs();
    return prefs.getInt(siswaListTimestampKey);
  }
}
