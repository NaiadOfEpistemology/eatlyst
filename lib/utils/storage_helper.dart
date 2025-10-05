import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class StorageHelper {

  static String getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<List<FoodItem>> getFoodItems({required String dayKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(dayKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => FoodItem.fromJson(e)).toList();
  }

  static Future<void> writeFoodItems(List<FoodItem> items, {required String dayKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(dayKey, encoded);
  }

  static Future<void> appendFoodItem(FoodItem item, {required String dayKey}) async {
    final items = await getFoodItems(dayKey: dayKey);
    items.add(item);
    await writeFoodItems(items, dayKey: dayKey);
  }

  static Future<void> deleteFoodItem(FoodItem item, {required String dayKey}) async {
    final items = await getFoodItems(dayKey: dayKey);
    items.removeWhere((e) =>
    e.name == item.name &&
        e.date == item.date &&
        e.calories == item.calories
    );
    await writeFoodItems(items, dayKey: dayKey);
  }

  static Future<int?> getCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('calorie_goal');
  }

  static Future<String> exportJson({required String dayKey}) async {
    final items = await getFoodItems(dayKey: dayKey);
    return const JsonEncoder.withIndent('  ')
        .convert(items.map((e) => e.toJson()).toList());
  }

  static Future<List<String>> getLoggedDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) =>
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)).toList();
  }

  static Future<List<FoodItem>> getAllFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final foodKeys = allKeys.where((key) =>
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key));

    final List<FoodItem> allItems = [];

    for (final key in foodKeys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final decoded = jsonDecode(raw) as List;
      final items = decoded.map((e) => FoodItem.fromJson(e)).toList();
      allItems.addAll(items);
    }

    return allItems;
  }

  static Future<String> exportAllLogsAsJson() async {
    final allItems = await getAllFoodLogs();
    return const JsonEncoder.withIndent('  ')
        .convert(allItems.map((e) => e.toJson()).toList());
  }
}
