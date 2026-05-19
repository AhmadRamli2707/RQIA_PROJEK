import 'package:flutter/material.dart';

import '../data/models/jenis_pembayaran_model.dart';
import '../data/models/siswa_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/pembayaran_service.dart';
import '../data/services/siswa_service.dart';
import '../components/custom_app_bar.dart';

class InputPembayaranPage extends StatefulWidget {
  const InputPembayaranPage({super.key});

  @override
  State<InputPembayaranPage> createState() => _InputPembayaranPageState();
}

class _InputPembayaranPageState extends State<InputPembayaranPage> {
  final PembayaranService pembayaranService = PembayaranService();
  final SiswaService siswaService = SiswaService();
  final LocalStorageService localStorageService = LocalStorageService();

  bool isSaving = false;
  bool isLoadingSiswa = true;
  bool isRefreshingSiswa = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();

  List<SiswaModel> siswaList = [];
  List<JenisPembayaranModel> jenisPembayaranList = [];
  SiswaModel? siswaDipilih;
  JenisPembayaranModel? jenisPembayaranDipilih;

  String? bulanDipilih;
  String? metodeDipilih;
  int autocompleteResetKey = 0;

  final List<String> bulanList = [
    'AGST',
    'SEP',
    'OKT',
    'NOV',
    'DES',
    'JAN',
    'FEB',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
  ];

  final List<String> metodeList = [
    'Tunai',
    'Transfer',
  ];

  static const String defaultMetodePembayaran = 'Transfer';

  @override
  void initState() {
    super.initState();
    setDefaultTanggalBulanTahun();
    metodeDipilih = defaultMetodePembayaran;
    loadCachedData();
  }

  void setDefaultTanggalBulanTahun() {
    final now = DateTime.now();
    tanggalController.text = formatTanggal(now);
    tahunController.text = now.year.toString();
    bulanDipilih = getBulanSekarang(now.month);
  }

  String formatTanggal(DateTime tanggal) {
    return '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
  }

  String getBulanSekarang(int month) {
    const monthMap = {
      1: 'JAN',
      2: 'FEB',
      3: 'MARET',
      4: 'APRIL',
      5: 'MEI',
      6: 'JUNI',
      7: 'JULI',
      8: 'AGST',
      9: 'SEP',
      10: 'OKT',
      11: 'NOV',
      12: 'DES',
    };

    return monthMap[month] ?? 'JAN';
  }

  JenisPembayaranModel? getDefaultJenisPembayaran(
    List<JenisPembayaranModel> data,
  ) {
    if (data.isEmpty) {
      return null;
    }
    return data.first;
  }

  void resetPilihanForm() {
    setDefaultTanggalBulanTahun();
    final defaultJenisPembayaran = getDefaultJenisPembayaran(
      jenisPembayaranList,
    );
    nominalController.text = defaultJenisPembayaran?.nominalDefault ?? '';
    setState(() {
      siswaDipilih = null;
      jenisPembayaranDipilih = defaultJenisPembayaran;
      metodeDipilih = defaultMetodePembayaran;
      autocompleteResetKey++;
    });
  }

  Future<void> loadCachedData() async {
    try {
      final masterData = await localStorageService.getMasterData();
      final cachedData = await localStorageService.getSiswaList();
      final cachedJenisPembayaran = masterData?.jenisPembayaran ?? [];
      final defaultJenisPembayaran = getDefaultJenisPembayaran(
        cachedJenisPembayaran,
      );
      if (!mounted) return;

      setState(() {
        siswaList = cachedData;
        jenisPembayaranList = cachedJenisPembayaran;
        jenisPembayaranDipilih = defaultJenisPembayaran;
        nominalController.text = defaultJenisPembayaran?.nominalDefault ?? '';
        metodeDipilih = defaultMetodePembayaran;
        isLoadingSiswa = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingSiswa = false;
      });
    }
  }

  Future<void> ambilDataSiswa() async {
    try {
      setState(() {
        isRefreshingSiswa = true;
      });

      final masterData = await siswaService.getMasterData();
      await localStorageService.saveMasterData(masterData);
      final defaultJenisPembayaran = getDefaultJenisPembayaran(
        masterData.jenisPembayaran,
      );

      if (!mounted) return;

      setState(() {
        siswaList = masterData.siswa;
        jenisPembayaranList = masterData.jenisPembayaran;
        siswaDipilih = null;
        jenisPembayaranDipilih = defaultJenisPembayaran;
        nominalController.text = defaultJenisPembayaran?.nominalDefault ?? '';
        metodeDipilih = defaultMetodePembayaran;
        autocompleteResetKey++;
        isRefreshingSiswa = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Master data berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isRefreshingSiswa = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data siswa: $e'),
        ),
      );
    }
  }

  Future<void> simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    if (siswaDipilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih siswa dari daftar'),
        ),
      );
      return;
    }

    if (jenisPembayaranDipilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jenis pembayaran dari daftar'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await pembayaranService.tambahPembayaran(
        idSiswa: siswaDipilih!.idSiswa,
        namaSiswa: siswaDipilih!.namaSiswa,
        idJenis: jenisPembayaranDipilih!.idJenis,
        bulan: bulanDipilih!,
        tahun: tahunController.text.trim(),
        nominal: nominalController.text.trim(),
        tanggalBayar: tanggalController.text.trim(),
        metode: metodeDipilih!,
        status: 'lunas',
        catatan: '',
        buktiPembayaran: '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pembayaran berhasil disimpan ke Spreadsheet'),
        ),
      );

      resetPilihanForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pembayaran: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> pilihTanggal() async {
    final tanggalAwal =
        DateTime.tryParse(tanggalController.text.trim()) ?? DateTime.now();

    final DateTime? tanggal = await showDatePicker(
      context: context,
      initialDate: tanggalAwal,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (tanggal != null) {
      tanggalController.text = formatTanggal(tanggal);
    }
  }

  @override
  void dispose() {
    nominalController.dispose();
    tanggalController.dispose();
    tahunController.dispose();
    super.dispose();
  }

  Widget buildAutocompleteSiswa() {
    if (isLoadingSiswa) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Autocomplete<SiswaModel>(
      key: ValueKey('autocomplete_siswa_$autocompleteResetKey'),
      displayStringForOption: (SiswaModel siswa) {
        return siswa.namaSiswa;
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<SiswaModel>.empty();
        }

        return siswaList.where((siswa) {
          final keyword = textEditingValue.text.toLowerCase();
          final nama = siswa.namaSiswa.toLowerCase();
          final id = siswa.idSiswa.toLowerCase();
          final kelas = siswa.kelas.toLowerCase();

          return nama.contains(keyword) ||
              id.contains(keyword) ||
              kelas.contains(keyword);
        });
      },
      onSelected: (SiswaModel siswa) {
        setState(() {
          siswaDipilih = siswa;
        });
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Cari Nama Siswa',
            hintText: 'Ketik nama siswa',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          validator: (value) {
            if (siswaDipilih == null) {
              return 'Pilih siswa dari daftar';
            }
            return null;
          },
          onChanged: (value) {
            if (siswaDipilih != null && value != siswaDipilih!.namaSiswa) {
              setState(() {
                siswaDipilih = null;
              });
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 64,
              height: 250,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final siswa = options.elementAt(index);

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(siswa.namaSiswa),
                    subtitle: Text(
                      'ID: ${siswa.idSiswa} | Kelas: ${siswa.kelas}',
                    ),
                    onTap: () {
                      onSelected(siswa);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: "RQIA SPP",
        onDownload: () {
          ambilDataSiswa();
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildAutocompleteSiswa(),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<JenisPembayaranModel>(
                    value: jenisPembayaranDipilih,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Pembayaran',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                    items: jenisPembayaranList.map((jenisPembayaran) {
                      return DropdownMenuItem<JenisPembayaranModel>(
                        value: jenisPembayaran,
                        child: Text(jenisPembayaran.namaPembayaran),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        jenisPembayaranDipilih = value;
                        nominalController.text = value?.nominalDefault ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih jenis pembayaran';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: bulanDipilih,
                    decoration: const InputDecoration(
                      labelText: 'Bulan Pembayaran',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    items: bulanList.map((bulan) {
                      return DropdownMenuItem(
                        value: bulan,
                        child: Text(bulan),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        bulanDipilih = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih bulan pembayaran';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tahunController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Pembayaran',
                      hintText: 'Contoh: 2026',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_note),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tahun pembayaran wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal Pembayaran',
                      hintText: 'Contoh: 800000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nominal wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tanggalController,
                    readOnly: true,
                    onTap: pilihTanggal,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Bayar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal bayar wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: metodeDipilih,
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: metodeList.map((metode) {
                      return DropdownMenuItem(
                        value: metode,
                        child: Text(metode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        metodeDipilih = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih metode pembayaran';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : simpanData,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        isSaving ? 'Menyimpan...' : 'Simpan Pembayaran',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A124F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
