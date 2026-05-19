import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';
import '../models/master_data_model.dart';
import '../models/siswa_model.dart';

class SiswaService {
  Future<MasterDataModel> getMasterData() async {
    final url = Uri.parse('${AppConfig.baseUrl}?action=getMasterData');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil master data');
    }

    final result = jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception('Master data tidak ditemukan');
    }

    final data = Map<String, dynamic>.from(result['data'] ?? {});
    return MasterDataModel.fromJson(data);
  }

  Future<List<SiswaModel>> getSiswa() async {
    final masterData = await getMasterData();
    return masterData.siswa;
  }
}
