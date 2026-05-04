import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  await themeService.loadTheme();
  runApp(CountryExplorerApp(themeService: themeService));
}

class CountryExplorerApp extends StatefulWidget {
  final ThemeService themeService;

  const CountryExplorerApp({super.key, required this.themeService});

  @override
  State<CountryExplorerApp> createState() => _CountryExplorerAppState();
}

class _CountryExplorerAppState extends State<CountryExplorerApp> {
  @override
  void initState() {
    super.initState();
    widget.themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer',
      debugShowCheckedModeBanner: false,
      themeMode: widget.themeService.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: HomeScreen(themeService: widget.themeService),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00796B),
        brightness: brightness,
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
