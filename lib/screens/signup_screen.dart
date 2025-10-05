import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color_palette.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _gender = 'Female';
  String _error = '';

  double? calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  int calculateCalorieGoal(double weight, double height, int age, String gender) {
    if (gender == 'Male') {
      return ((10 * weight) + (6.25 * height) - (5 * age) + 5).round();
    } else {
      return ((10 * weight) + (6.25 * height) - (5 * age) - 161).round();
    }
  }

  Future<void> saveProfile() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (name.isEmpty || age == null || height == null || weight == null) {
      setState(() => _error = 'Please fill all fields correctly.');
      return;
    }

    final bmi = calculateBMI(weight, height)!;
    final calorieGoal = calculateCalorieGoal(weight, height, age, _gender);

    final profile = {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': _gender,
      'bmi': bmi,
      'calorieGoal': calorieGoal,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile));
    await prefs.setInt('calorie_goal', calorieGoal);
    await prefs.setBool('setupComplete', true);

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Profile Created'),
        content: Text('Your BMI is ${bmi.toStringAsFixed(1)}'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (_) => const MainScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CoffeeColors.scaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Create Profile'),
        backgroundColor: CoffeeColors.primary,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Name',
                style: const TextStyle(color: CoffeeColors.text),
                placeholderStyle: const TextStyle(color: CoffeeColors.textSecondary),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _ageController,
                placeholder: 'Age',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: CoffeeColors.text),
                placeholderStyle: const TextStyle(color: CoffeeColors.textSecondary),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _heightController,
                placeholder: 'Height (cm)',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: CoffeeColors.text),
                placeholderStyle: const TextStyle(color: CoffeeColors.textSecondary),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _weightController,
                placeholder: 'Weight (kg)',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: CoffeeColors.text),
                placeholderStyle: const TextStyle(color: CoffeeColors.textSecondary),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),
              CupertinoSegmentedControl<String>(
                children: {
                  'Male': const Text('Male'),
                  'Female': const Text('Female'),
                },
                groupValue: _gender,
                onValueChanged: (value) => setState(() => _gender = value),
              ),


              const SizedBox(height: 24),
              if (_heightController.text.isNotEmpty &&
                  _weightController.text.isNotEmpty &&
                  _ageController.text.isNotEmpty)
                Builder(builder: (_) {
                  final height = double.tryParse(_heightController.text);
                  final weight = double.tryParse(_weightController.text);
                  final age = int.tryParse(_ageController.text);
                  if (height != null && weight != null && age != null) {
                    final bmi = calculateBMI(weight, height)!;
                    final goal = calculateCalorieGoal(weight, height, age, _gender);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'BMI: ${bmi.toStringAsFixed(1)}  •  Goal: $goal kcal',
                        style: const TextStyle(color: CoffeeColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: CoffeeColors.error)),

              CupertinoButton.filled(
                child: const Text('Create Profile'),
                onPressed: saveProfile,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
