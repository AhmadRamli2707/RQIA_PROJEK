import 'jenis_pembayaran_model.dart';
import 'siswa_model.dart';

class MasterDataModel {
  final List<SiswaModel> siswa;
  final List<JenisPembayaranModel> jenisPembayaran;

  MasterDataModel({
    required this.siswa,
    required this.jenisPembayaran,
  });

  factory MasterDataModel.fromJson(Map<String, dynamic> json) {
    final siswaList = (json['siswa'] as List? ?? [])
        .map((item) => SiswaModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final jenisPembayaranList = (json['jenis_pembayaran'] as List? ?? [])
        .map(
          (item) => JenisPembayaranModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    return MasterDataModel(
      siswa: siswaList,
      jenisPembayaran: jenisPembayaranList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswa': siswa.map((item) => item.toJson()).toList(),
      'jenis_pembayaran': jenisPembayaran.map((item) => item.toJson()).toList(),
    };
  }
}
