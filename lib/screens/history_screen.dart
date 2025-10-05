import 'package:flutter/cupertino.dart';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';
import '../widgets/food_tile.dart';
import '../color_palette.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime? dayKey;
  const HistoryScreen({super.key, this.dayKey});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FoodItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (widget.dayKey != null) {
      final key = '${widget.dayKey!.year}-${widget.dayKey!.month.toString().padLeft(2, '0')}-${widget.dayKey!.day.toString().padLeft(2, '0')}';
      _history = await StorageHelper.getFoodItems(dayKey: key);
    } else {
      _history = await StorageHelper.getAllFoodLogs();
    }

    _history.sort((a, b) => b.date.compareTo(a.date));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('History'),
      ),
      child: SafeArea(
        child: _history.isEmpty
            ? Center(
          child: Text(
            'No food logged yet',
            style: TextStyle(color: CoffeeColors.textSecondary),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, index) {
            final item = _history[index];
            return FoodTile(item: item);
          },
        ),
      ),
    );
  }
}
