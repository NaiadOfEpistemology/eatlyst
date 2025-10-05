import 'dart:convert';
import 'package:eatlyst_new/utils/storage_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../food_items.dart';
import '../food_picker_screen.dart';
import '../utils/storage_helper.dart';
import '../models/food_item.dart';
import '../color_palette.dart';
import '../widgets/food_tile.dart';
import 'signup_screen.dart';
import 'ai_food_screen.dart';
import 'package:eatlyst_new/screens/history_screen.dart';
import 'package:eatlyst_new/screens/stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<FoodItem> _todayItems = [];
  int _calorieGoal = 1800;
  String? _selectedCategory;
  bool _showDropdown = false;

  final _manualNameController = TextEditingController();
  final _manualCalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await StorageHelper.getFoodItems(dayKey: StorageHelper.getTodayKey());
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt('calorie_goal') ?? 1800;
    setState(() {
      _todayItems = items;
      _calorieGoal = goal;
    });
  }

  int get _totalCalories => _todayItems.fold(0, (sum, item) => sum + item.calories);

  void _deleteItem(FoodItem item) async {
    await StorageHelper.deleteFoodItem(item, dayKey: StorageHelper.getTodayKey());
    await _loadData();
  }

  void _submitManualEntry() async {
    final name = _manualNameController.text.trim();
    final cal = int.tryParse(_manualCalController.text.trim());

    if (name.isEmpty || cal == null) return;

    final item = FoodItem(
      name: name,
      calories: cal,
      quantity: 1,
      mealType: _selectedCategory ?? 'Snack',
      date: DateTime.now(),
    );

    await StorageHelper.appendFoodItem(item, dayKey: StorageHelper.getTodayKey());
    _manualNameController.clear();
    _manualCalController.clear();
    setState(() => _selectedCategory = null);
    await _loadData();
  }

  Future<void> _resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('calorie_goal');
    await prefs.setBool('setupComplete', false);

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calorieGoal > 0
        ? (_totalCalories / _calorieGoal).clamp(0.0, 1.0)
        : 0.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Eatlyst'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.time),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => HistoryScreen()),
                );
              },
            ),

            const SizedBox(width: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.chart_bar),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const StatsScreen()),
                );
              },
            ),
          ],
        ),
      ),

      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Hello!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('You’ve consumed $_totalCalories out of $_calorieGoal kcal today.',
                style: const TextStyle(color: CoffeeColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: CoffeeColors.border,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: CoffeeColors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              child: const Text('Log Food'),
              onPressed: () => setState(() => _showDropdown = !_showDropdown),
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              child: const Text('Scan Food with AI'),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const AiFoodScreen()),
                ).then((_) => _loadData());
              },
            ),
            if (_showDropdown)
              Column(
                children: [
                  const SizedBox(height: 12),
                  ...categorizedFoodSuggestions.keys.map((category) => CupertinoButton(
                    child: Text(category),
                    onPressed: () {
                      setState(() => _selectedCategory = category);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => FoodPickerScreen(
                            category: category,
                            onSelect: (item) async {
                              await StorageHelper.appendFoodItem(item,
                                  dayKey: StorageHelper.getTodayKey());
                              setState(() => _selectedCategory = null);
                              await _loadData();
                            },
                          ),
                        ),
                      );
                    },
                  )),
                  CupertinoButton(
                    child: const Text('Manual Entry'),
                    onPressed: () => setState(() => _selectedCategory = 'Manual Entry'),
                  ),
                ],
              ),
            if (_selectedCategory == 'Manual Entry')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _manualNameController,
                    placeholder: 'Food Name',
                    style: const TextStyle(color: CoffeeColors.text),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CoffeeColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _manualCalController,
                    placeholder: 'Calories',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: CoffeeColors.text),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CoffeeColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton.filled(
                    child: const Text('Add Food'),
                    onPressed: _submitManualEntry,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text('Logged Today', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ..._todayItems.map((item) => Dismissible(
              key: ValueKey(item.date.toIso8601String()),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _deleteItem(item),
              background: Container(
                color: CupertinoColors.systemRed,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(CupertinoIcons.delete),
              ),
              child: FoodTile(item: item),
            )),
            const SizedBox(height: 24),
            const Text('Recently Added', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ..._todayItems.reversed.take(3).map((item) => FoodTile(item: item)),
            const SizedBox(height: 32),
            CupertinoButton(
              child: const Text('Reset Profile'),
              onPressed: _resetProfile,
            ),
          ],
        ),
      ),
    );
  }
}
