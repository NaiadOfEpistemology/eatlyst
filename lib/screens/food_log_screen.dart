import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';
import '../widgets/food_tile.dart';
import '../color_palette.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  List<FoodItem> _loggedItems = [];
  int _calorieGoal = 2000;
  int _totalCalories = 0;
  String _selectedMeal = 'Breakfast';

  @override
  void initState() {
    super.initState();
    _loadFoodLog();
  }

  Future<void> _loadFoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt('calorie_goal');
    if (goal != null) _calorieGoal = goal;

    final items = await StorageHelper.getFoodItems(dayKey: StorageHelper.getTodayKey());
    setState(() {
      _loggedItems = items;
      _totalCalories = items.fold(0, (sum, item) => sum + item.calories);
    });
  }

  Future<void> _saveFoodLog() async {
    await StorageHelper.writeFoodItems(_loggedItems, dayKey: StorageHelper.getTodayKey());
  }

  void _addFoodItem(FoodItem item) {
    setState(() {
      _loggedItems.add(item);
      _totalCalories += item.calories;
    });
    _saveFoodLog();
  }

  void _deleteFoodItem(int index) {
    final item = _loggedItems[index];
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Delete ${item.name}?'),
        actions: [
          CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            child: const Text('Delete'),
            isDestructiveAction: true,
            onPressed: () {
              setState(() {
                _totalCalories -= item.calories;
                _loggedItems.removeAt(index);
              });
              _saveFoodLog();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final quantityController = TextEditingController();
    _selectedMeal = 'Breakfast';

    showCupertinoDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: const Text('Add Food'),
          content: Column(
            children: [
              CupertinoTextField(controller: nameController, placeholder: 'Food Name'),
              const SizedBox(height: 8),
              CupertinoTextField(controller: caloriesController, placeholder: 'Calories', keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              CupertinoTextField(controller: quantityController, placeholder: 'Quantity', keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              CupertinoSegmentedControl<String>(
                groupValue: _selectedMeal,
                children: {
                  'Breakfast': const Text('Breakfast'),
                  'Lunch': const Text('Lunch'),
                  'Dinner': const Text('Dinner'),
                  'Snack': const Text('Snack'),
                  'Beverage': const Text('Beverage'),
                },
                onValueChanged: (val) => setDialogState(() => _selectedMeal = val),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
            CupertinoDialogAction(
              child: const Text('Add'),
              onPressed: () {
                final name = nameController.text.trim();
                final calories = int.tryParse(caloriesController.text) ?? 0;
                final quantity = int.tryParse(quantityController.text) ?? 1;

                if (name.isNotEmpty && calories > 0) {
                  _addFoodItem(FoodItem(
                    name: name,
                    calories: calories,
                    quantity: quantity,
                    date: DateTime.now(),
                    mealType: _selectedMeal,
                  ));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportJson() {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(_loggedItems.map((e) => e.toJson()).toList());
    Clipboard.setData(ClipboardData(text: jsonStr));
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Exported"),
        content: const Text("Today's logs copied to clipboard in JSON format."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalCalories / _calorieGoal).clamp(0.0, 1.0);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Food Log"),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CoffeeColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text("Calorie Goal: $_calorieGoal", style: TextStyle(color: CoffeeColors.text)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: CoffeeColors.primary,
                    backgroundColor: CoffeeColors.border,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text("Total: $_totalCalories cal", style: TextStyle(color: CoffeeColors.textSecondary)),
                ],
              ),
            ),

            Expanded(
              child: _loggedItems.isEmpty
                  ? Center(child: Text("No foods logged yet", style: TextStyle(color: CoffeeColors.textSecondary)))
                  : ListView.builder(
                itemCount: _loggedItems.length,
                itemBuilder: (_, index) {
                  final item = _loggedItems[index];
                  return Dismissible(
                    key: ValueKey(item.date.toIso8601String() + item.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteFoodItem(index),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(CupertinoIcons.delete, color: Colors.white),
                    ),
                    child: FoodTile(item: item),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      child: const Text("Add Food"),
                      onPressed: _showAddFoodDialog,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoButton.filled(
                      child: const Text("Export JSON"),
                      onPressed: _exportJson,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
