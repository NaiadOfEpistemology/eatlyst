class FoodItem {
  String name;
  int calories;
  int quantity;
  DateTime date;
  String mealType;
  int? protein;
  int? carbs;
  int? fat;

  FoodItem({
    required this.name,
    required this.calories,
    required this.quantity,
    required this.date,
    required this.mealType,
    this.protein,
    this.carbs,
    this.fat,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'quantity': quantity,
    'date': date.toIso8601String(),
    'mealType': mealType,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    name: json['name'],
    calories: json['calories'],
    quantity: json['quantity'],
    date: DateTime.parse(json['date']),
    mealType: json['mealType'] ?? 'Other',
    protein: json['protein'],
    carbs: json['carbs'],
    fat: json['fat'],
  );

  double get caloriesPerUnit => calories / quantity;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  FoodItem copyWith({
    String? name,
    int? calories,
    int? quantity,
    DateTime? date,
    String? mealType,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}
