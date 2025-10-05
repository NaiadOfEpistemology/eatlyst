import 'package:flutter/cupertino.dart';
import '../models/food_item.dart';
import '../color_palette.dart';

class FoodTile extends StatelessWidget {
  final FoodItem item;

  const FoodTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CoffeeColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CoffeeColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CoffeeColors.text)),
              const SizedBox(height: 4),
              Text('${item.quantity} units • ${item.mealType}',
                  style: const TextStyle(
                      fontSize: 12, color: CoffeeColors.textSecondary)),
            ],
          ),

          Text('${item.calories} kcal',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CoffeeColors.primary)),
        ],
      ),
    );
  }
}
