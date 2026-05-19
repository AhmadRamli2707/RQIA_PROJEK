class SiswaModel {
  final String idSiswa;
  final String namaSiswa;
  final String kelas;
  final String noHpWali;
  final String status;

  SiswaModel({
    required this.idSiswa,
    required this.namaSiswa,
    required this.kelas,
    required this.noHpWali,
    required this.status,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      idSiswa: json['id_siswa']?.toString() ?? '',
      namaSiswa: json['nama_siswa']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
      noHpWali: json['no_hp_wali']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_siswa': idSiswa,
      'nama_siswa': namaSiswa,
      'kelas': kelas,
      'no_hp_wali': noHpWali,
      'status': status,
    };
  }
}