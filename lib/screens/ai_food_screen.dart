import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../color_palette.dart';
import '../services/ai_service.dart';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';
import 'package:flutter/services.dart';

class AiFoodScreen extends StatefulWidget {
  const AiFoodScreen({Key? key}) : super(key: key);

  @override
  _AiFoodScreenState createState() => _AiFoodScreenState();
}

class _AiFoodScreenState extends State<AiFoodScreen> {
  File? _image;
  String _aiResult = '';
  bool _modelReady = false;

  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();

  final _foodNameController = TextEditingController();
  final _calorieController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      print('Loading model and labels...');
      await _aiService.initialize();
      print('Model initialized.');

      final manifest = await rootBundle.loadString('AssetManifest.json');
      final isRegistered = manifest.contains('assets/models/eatlyst_model.tflite');
      print('Asset registered: $isRegistered');

      setState(() => _modelReady = true);
    } catch (e) {
      print('Error during model initialization: $e');
      setState(() => _aiResult = 'Model failed to load.');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _aiResult = 'Processing...';
      });

      try {
        if (!_modelReady || !_aiService.isModelReady) {
          setState(() => _aiResult = 'Model not ready. Please wait...');
          return;
        }

        final Uint8List imageBytes = await _image!.readAsBytes();
        final label = await _aiService.predict(imageBytes);
        final calories = _aiService.calorieMap[label] ?? 100;

        setState(() {
          _aiResult = 'Prediction: $label';
          _foodNameController.text = label;
          _calorieController.text = calories.toString();
          _quantityController.text = '1';
        });
      } catch (e) {
        setState(() => _aiResult = 'Could not identify food. Try a clearer image.');
      }
    }
  }

  Future<void> _logFood() async {
    final name = _foodNameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final caloriesPerUnit = int.tryParse(_calorieController.text.trim()) ?? 100;
    final totalCalories = caloriesPerUnit * quantity;

    final item = FoodItem(
      name: name,
      calories: totalCalories,
      quantity: quantity,
      date: DateTime.now(),
      mealType: 'AI',
    );

    await StorageHelper.appendFoodItem(item, dayKey: StorageHelper.getTodayKey());

    setState(() => _aiResult = 'Logged: $name ($totalCalories kcal)');
  }

  @override
  void dispose() {
    _aiService.dispose();
    _foodNameController.dispose();
    _calorieController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('AI Food Recognition'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_image != null)
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: CoffeeColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            else
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: CoffeeColors.background,
                  border: Border.all(color: CoffeeColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No image selected', textAlign: TextAlign.center),
                ),
              ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text('Pick from Camera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            CupertinoButton.filled(
              child: const Text('Pick from Gallery'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 30),
            Text(_aiResult, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _foodNameController,
              placeholder: 'Food Name',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              style: const TextStyle(color: CupertinoColors.black),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _calorieController,
              placeholder: 'Calories per unit',
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              style: const TextStyle(color: CupertinoColors.black),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _quantityController,
              placeholder: 'Quantity',
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              style: const TextStyle(color: CupertinoColors.black),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
            ),


            const SizedBox(height: 20),
            CupertinoButton.filled(child: const Text('Log Food'), onPressed: _logFood),
          ],
        ),
      ),
    );
  }
}
