import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AiService {
  late final Interpreter _interpreter;
  late final List<String> _labels;
  bool _isReady = false;

  final Map<String, int> calorieMap = {
    'Apple Pie': 300, 'Baby Back Ribs': 450, 'Baklava': 290, 'Beef Carpaccio': 180, 'Beef Tartare': 220,
    'Beet Salad': 150, 'Beignets': 280, 'Bibimbap': 550, 'Bread Pudding': 310, 'Breakfast Burrito': 320,
    'Bruschetta': 150, 'Caesar Salad': 180, 'Cannoli': 250, 'Caprese Salad': 220, 'Carrot Cake': 330,
    'Ceviche': 160, 'Cheese Plate': 400, 'Cheesecake': 350, 'Chicken Curry': 290, 'Chicken Quesadilla': 320,
    'Chicken Wings': 430, 'Chocolate Cake': 370, 'Chocolate Mousse': 300, 'Churros': 260, 'Clam Chowder': 220,
    'Club Sandwich': 400, 'Crab Cakes': 280, 'Creme Brulee': 330, 'Croque Madame': 420, 'Cup Cakes': 270,
    'Deviled Eggs': 120, 'Donuts': 260, 'Dumplings': 220, 'Edamame': 190, 'Eggs Benedict': 290, 'Escargots': 180,
    'Falafel': 300, 'Filet Mignon': 320, 'Fish and Chips': 585, 'Foie Gras': 400, 'French Fries': 312,
    'French Onion Soup': 180, 'French Toast': 226, 'Fried Calamari': 350, 'Fried Rice': 215, 'Frozen Yogurt': 180,
    'Garlic Bread': 220, 'Gnocchi': 250, 'Greek Salad': 160, 'Grilled Cheese Sandwich': 320, 'Grilled Salmon': 367,
    'Guacamole': 150, 'Gyoza': 200, 'Hamburger': 480, 'Hot and Sour Soup': 90, 'Hot Dog': 290,
    'Huevos Rancheros': 320, 'Hummus': 180, 'Ice Cream': 137, 'Lasagna': 350, 'Lobster Bisque': 250,
    'Lobster Roll Sandwich': 420, 'Macaroni and Cheese': 380, 'Macarons': 90, 'Miso Soup': 80, 'Mussels': 170,
    'Nachos': 350, 'Omelette': 154, 'Onion Rings': 240, 'Oysters': 150, 'Pad Thai': 330, 'Paella': 340,
    'Pancakes': 227, 'Panna Cotta': 300, 'Peking Duck': 400, 'Pho': 290, 'Pizza': 285, 'Pork Chop': 320,
    'Poutine': 330, 'Prime Rib': 450, 'Pulled Pork Sandwich': 420, 'Ramen': 450, 'Ravioli': 310,
    'Red Velvet Cake': 360, 'Risotto': 340, 'Samosa': 130, 'Sashimi': 180, 'Scallops': 220, 'Seaweed Salad': 100,
    'Shrimp and Grits': 400, 'Spaghetti Bolognese': 370, 'Spaghetti Carbonara': 390, 'Spring Rolls': 120,
    'Steak': 679, 'Strawberry Shortcake': 320, 'Sushi': 200, 'Tacos': 280, 'Takoyaki': 300, 'Tiramisu': 330,
    'Tuna Tartare': 200, 'Waffles': 218,
  };

  Future<void> initialize() async {
    try {
      final modelData = await rootBundle.load('assets/models/eatlyst_model.tflite');
      _interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List());

      final raw = await rootBundle.loadString('assets/models/labels.txt');
      _labels = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      _isReady = true;
      print('Model and labels loaded via buffer');
    } catch (e, stack) {
      print('Error during model initialization: $e');
      print(stack);
      _isReady = false;
    }
  }

  bool get isModelReady => _isReady;

  Future<String> predict(Uint8List imageBytes) async {
    if (!_isReady) return 'Model not ready';

    final input = _preprocessImage(imageBytes);
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    try {
      _interpreter.run(input, output);
    } catch (e) {
      print('Error during inference: $e');
      return 'Prediction failed';
    }

    final scores = output[0] as List<double>;
    final topIndex = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    final topScore = scores[topIndex];

    if (topScore < 0.2) return 'Uncertain — try again';

    final rawLabel = _labels[topIndex];
    final normalized = _normalizeLabel(rawLabel);
    print('Prediction: $normalized (${(topScore * 100).toStringAsFixed(1)}%)');
    return normalized;
  }

  String _normalizeLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes)!;
    final resized = img.copyResize(image, width: 224, height: 224);

    final input = List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        })
    );

    return [input];
  }

  void dispose() {
    _interpreter.close();
  }
}
