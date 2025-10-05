import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';
import '../color_palette.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<FoodItem> _logs = [];
  String _jsonStr = '';
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final items = await StorageHelper.getAllFoodLogs();
    final json = const JsonEncoder.withIndent('  ')
        .convert(items.map((e) => e.toJson()).toList());
    final total = items.fold(0, (sum, item) => sum + item.calories);

    setState(() {
      _logs = items;
      _jsonStr = json;
      _totalCalories = total;
    });
  }

  void _copyJson() {
    Clipboard.setData(ClipboardData(text: _jsonStr));
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Copied"),
        content: const Text("Logs copied to clipboard."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _shareJson() {
    Share.share(_jsonStr, subject: 'Eatlyst Food Logs');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Stats')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Total Calories: $_totalCalories",
                  style: TextStyle(fontSize: 18, color: CoffeeColors.text)),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CoffeeColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _jsonStr.isEmpty
                      ? const Center(child: Text("No logs to export"))
                      : SingleChildScrollView(
                    child: Text(_jsonStr, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton.filled(
                    onPressed: _copyJson,
                    child: const Text("Copy"),
                  ),
                  CupertinoButton(
                    onPressed: _shareJson,
                    child: const Text("Share"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
