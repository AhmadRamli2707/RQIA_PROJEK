class JenisPembayaranModel {
  final String idJenis;
  final String namaPembayaran;
  final String nominalDefault;
  final String keterangan;

  JenisPembayaranModel({
    required this.idJenis,
    required this.namaPembayaran,
    required this.nominalDefault,
    required this.keterangan,
  });

  factory JenisPembayaranModel.fromJson(Map<String, dynamic> json) {
    return JenisPembayaranModel(
      idJenis: json['id_jenis']?.toString() ?? '',
      namaPembayaran: json['nama_pembayaran']?.toString() ?? '',
      nominalDefault: json['nominal_default']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jenis': idJenis,
      'nama_pembayaran': namaPembayaran,
      'nominal_default': nominalDefault,
      'keterangan': keterangan,
    };
  }
}
