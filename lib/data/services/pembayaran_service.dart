import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';

class PembayaranService {
  Future<void> tambahPembayaran({
    required String idSiswa,
    required String namaSiswa,
    required String idJenis,
    required String bulan,
    required String tahun,
    required String nominal,
    required String tanggalBayar,
    required String metode,
    String status = 'lunas',
    String catatan = '',
    String buktiPembayaran = '',
  }) async {
    final url = Uri.parse(AppConfig.baseUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_siswa': idSiswa,
        'nama_siswa': namaSiswa,
        'id_jenis': idJenis,
        'bulan': bulan,
        'tahun': tahun,
        'nominal': nominal,
        'tanggal_bayar': tanggalBayar,
        'metode': metode,
        'status': status,
        'catatan': catatan,
        'bukti_pembayaran': buktiPembayaran,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal terhubung ke server: ${response.statusCode}');
    }

    final result = jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Gagal menyimpan pembayaran');
    }
  }
}