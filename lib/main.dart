import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

/// The main widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ColorChangerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// A screen that changes its background color when tapped.
class ColorChangerScreen extends StatefulWidget {
  /// Creates a [ColorChangerScreen].
  const ColorChangerScreen({super.key});

  @override
  State<ColorChangerScreen> createState() => _ColorChangerScreenState();
}

class _ColorChangerScreenState extends State<ColorChangerScreen> {
  Color _backgroundColor = Colors.white;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoadColor();
  }

  Future<void> _initPrefsAndLoadColor() async {
    _prefs = await SharedPreferences.getInstance();
    final colorValue = _prefs.getInt('bgColor');
    if (colorValue != null) {
      final a = (colorValue >> 24) & 0xFF;
      final r = (colorValue >> 16) & 0xFF;
      final g = (colorValue >> 8) & 0xFF;
      final b = colorValue & 0xFF;
      setState(() {
        _backgroundColor = Color.fromARGB(a, r, g, b);
      });
    }
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r + g + b}'.toUpperCase();
  }

  void _saveColor(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    final argb = (a << 24) | (r << 16) | (g << 8) | b;
    _prefs.setInt('bgColor', argb);
  }

  void _changeColor() {
    final newColor = Color(Random().nextInt(0xFFFFFF)).withAlpha(255);
    setState(() {
      _backgroundColor = newColor;
    });
    _saveColor(newColor);
  }

  void _resetColor() {
    setState(() {
      _backgroundColor = Colors.white;
    });
    _saveColor(Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: _changeColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: _backgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hello there',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _colorToHex(_backgroundColor),
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetColor,
                child: const Text(
                  'Reset Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
