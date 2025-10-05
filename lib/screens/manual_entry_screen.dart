import 'package:flutter/cupertino.dart';
import '../color_palette.dart';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({Key? key}) : super(key: key);

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _mealType = 'Lunch';
  String _feedback = '';

  Future<void> _submitEntry() async {
    final name = _foodController.text.trim();
    final calories = int.tryParse(_calorieController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    if (name.isEmpty || calories <= 0 || quantity <= 0) {
      setState(() => _feedback = 'Please enter valid values.');
      return;
    }

    final item = FoodItem(
      name: name,
      calories: calories,
      quantity: quantity,
      date: DateTime.now(),
      mealType: _mealType,
    );

    await StorageHelper.appendFoodItem(item, dayKey: StorageHelper.getTodayKey());

    setState(() {
      _foodController.clear();
      _calorieController.clear();
      _quantityController.clear();
      _feedback = 'Added ${item.name} (${item.calories} cal)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CoffeeColors.scaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Manual Entry'),
        backgroundColor: CoffeeColors.primary,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              CupertinoTextField(
                controller: _foodController,
                placeholder: 'Food Name',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _calorieController,
                placeholder: 'Calories',
                keyboardType: TextInputType.number,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _quantityController,
                placeholder: 'Quantity',
                keyboardType: TextInputType.number,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoffeeColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoSegmentedControl<String>(
                children: {
                  'Breakfast': const Text('Breakfast'),
                  'Lunch': const Text('Lunch'),
                  'Dinner': const Text('Dinner'),
                  'Snack': const Text('Snack'),
                  'Beverage': const Text('Beverage'),
                },
                groupValue: _mealType,
                onValueChanged: (val) => setState(() => _mealType = val),
              ),
              const SizedBox(height: 24),
              if (_feedback.isNotEmpty)
                Text(_feedback, style: const TextStyle(color: CoffeeColors.success)),
              CupertinoButton.filled(
                child: const Text('Add Food'),
                onPressed: _submitEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
