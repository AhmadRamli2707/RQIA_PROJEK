import 'package:flutter/material.dart';
import 'data/services/local_storage_service.dart';
import 'pages/input_pembayaran_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InputPembayaranPage(),
    );
  }
}
