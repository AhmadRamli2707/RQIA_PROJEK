import 'package:flutter/material.dart';

import '../data/models/siswa_model.dart';
import '../data/services/siswa_service.dart';
import '../data/services/pembayaran_service.dart';
import '../data/services/local_storage_service.dart';
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

  List<SiswaModel> siswaList = [];
  SiswaModel? siswaDipilih;

  String? bulanDipilih;
  String? metodeDipilih;

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

  @override
  void initState() {
    super.initState();
    loadCachedData();
  }

  Future<void> loadCachedData() async {
    try {
      final cachedData = await localStorageService.getSiswaList();
      if (!mounted) return;

      setState(() {
        siswaList = cachedData;
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
      final cachedData = await localStorageService.getSiswaList();

      if (!mounted) return;

      setState(() {
        siswaList = cachedData;
        siswaDipilih = null;
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

    setState(() {
      isSaving = true;
    });

    try {
      await pembayaranService.tambahPembayaran(
        idSiswa: siswaDipilih!.idSiswa,
        namaSiswa: siswaDipilih!.namaSiswa,
        idJenis: '1',
        bulan: bulanDipilih!,
        tahun: DateTime.now().year.toString(),
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

      nominalController.clear();
      tanggalController.clear();

      setState(() {
        siswaDipilih = null;
        bulanDipilih = null;
        metodeDipilih = null;
      });
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
    final DateTime? tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (tanggal != null) {
      tanggalController.text =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    nominalController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Widget buildAutocompleteSiswa() {
    if (isLoadingSiswa) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Autocomplete<SiswaModel>(
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

  Widget buildInfoSiswaDipilih() {
    if (siswaDipilih == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Siswa Dipilih',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text('ID Siswa: ${siswaDipilih!.idSiswa}'),
          Text('Nama: ${siswaDipilih!.namaSiswa}'),
          Text('Kelas: ${siswaDipilih!.kelas}'),
        ],
      ),
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
                  buildInfoSiswaDipilih(),
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
