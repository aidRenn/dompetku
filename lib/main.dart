import 'package:dompetku/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dompet Mahasiswa',
      theme: ThemeData(
        fontFamily: 'Jost',

        // Warna utama dan sekunder aplikasi
        primaryColor: Color(0xFF222831),
        scaffoldBackgroundColor: Color(0xFFDFD0B8),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Color(0xFF393E46)),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: Color(0xFFDFD0B8),
          titleTextStyle: TextStyle(
            color: Color(0xFF222831),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Jost',
          ),

          contentTextStyle: TextStyle(
            color: Color(0xFF393E46),
            fontSize: 16,
            fontFamily: 'Jost',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF393E46),
          contentTextStyle: TextStyle(
            fontFamily: 'Jost',
            fontSize: 16,
            color: Color(0xFFDFD0B8),
          ),
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF393E46),
            foregroundColor: Color(0xFFDFD0B8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: Color(0xFFFFF1DC), // warna background popup
          textStyle: TextStyle(color: Color(0xFF222831), fontFamily: 'Jost'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF222831)),
      ),
      home: Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
