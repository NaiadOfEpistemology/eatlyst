import 'package:flutter/cupertino.dart';
import 'color_palette.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EatlystApp());
}

class EatlystApp extends StatelessWidget {
  const EatlystApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Eatlyst',
      theme: const CupertinoThemeData(
        scaffoldBackgroundColor: CoffeeColors.scaffoldBackground,
        primaryColor: CoffeeColors.primary,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: CoffeeColors.text),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
