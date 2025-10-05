import 'package:flutter/cupertino.dart';
import 'food_items.dart';
import 'models/food_item.dart';

class FoodPickerScreen extends StatefulWidget {
  final String category;
  final Function(FoodItem) onSelect;

  const FoodPickerScreen({required this.category, required this.onSelect, Key? key}) : super(key: key);

  @override
  State<FoodPickerScreen> createState() => _FoodPickerScreenState();
}

class _FoodPickerScreenState extends State<FoodPickerScreen> {
  final _searchController = TextEditingController();
  final _manualNameController = TextEditingController();
  final _manualCalController = TextEditingController();

  List<FoodSuggestion> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = categorizedFoodSuggestions[widget.category] ?? [];
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filtered = categorizedFoodSuggestions[widget.category]!
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  void _submitManual() {
    final name = _manualNameController.text.trim();
    final cal = int.tryParse(_manualCalController.text.trim());
    if (name.isEmpty || cal == null) return;

    widget.onSelect(FoodItem(
      name: name,
      calories: cal,
      quantity: 1,
      mealType: widget.category,
      date: DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('${widget.category} Picker')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoSearchTextField(controller: _searchController),
            const SizedBox(height: 16),
            ..._filtered.map((item) => CupertinoListTile(
              title: Text(item.name),
              trailing: Text('${item.caloriesPerUnit} kcal'),
              onTap: () {
                widget.onSelect(FoodItem(
                  name: item.name,
                  calories: item.caloriesPerUnit,
                  quantity: 1,
                  mealType: widget.category,
                  date: DateTime.now(),
                ));
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
            Text('Manual Entry', style: CupertinoTheme.of(context).textTheme.textStyle),
            const SizedBox(height: 8),
            CupertinoTextField(controller: _manualNameController, placeholder: 'Food Name'),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _manualCalController,
              placeholder: 'Calories',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CupertinoButton.filled(child: const Text('Add Manually'), onPressed: _submitManual),
          ],
        ),
      ),
    );
  }
}
