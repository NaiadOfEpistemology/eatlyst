import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color_palette.dart';
import 'signup_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetupAndNavigate();
  }

  Future<void> _checkSetupAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool('setupComplete') ?? false;

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => isSetupComplete ? const MainScreen() : const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CoffeeColors.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(CupertinoIcons.cube_box, size: 80, color: CoffeeColors.cardBackground),
            SizedBox(height: 20),
            Text(
              'Eatlyst',
              style: TextStyle(
                color: CoffeeColors.cardBackground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your personal calorie tracker',
              style: TextStyle(
                color: CoffeeColors.cardBackground,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
