import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salad_model.dart';

class RecipeApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1/search.php';

  /// Fetches salads or generic meals from TheMealDB and parses them into SaladModels.
  static Future<List<SaladModel>> fetchOnlineRecipes(String query) async {
    try {
      final searchQuery = query.trim().isEmpty ? 'salad' : query.trim();
      final url = Uri.parse('$_baseUrl?s=$searchQuery');
      
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      
      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);
      final List<dynamic>? meals = data['meals'];
      
      if (meals == null) {
        return [];
      }

      List<SaladModel> parsedSalads = [];

      for (var meal in meals) {
        final id = meal['idMeal'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
        final name = meal['strMeal'] as String? ?? 'Çevrimiçi Tarif';
        final imageUrl = meal['strMealThumb'] as String? ?? 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80';
        
        // Extract ingredients and measures
        List<String> ingredients = [];
        for (int i = 1; i <= 20; i++) {
          final ingredient = meal['strIngredient$i'] as String?;
          final measure = meal['strMeasure$i'] as String?;
          
          if (ingredient != null && ingredient.trim().isNotEmpty) {
            final cleanIngredient = _translateIngredient(ingredient.trim());
            if (measure != null && measure.trim().isNotEmpty) {
              final cleanMeasure = _translateMeasure(measure.trim());
              ingredients.add('$cleanMeasure $cleanIngredient');
            } else {
              ingredients.add(cleanIngredient);
            }
          }
        }

        // Clean steps
        final instructions = meal['strInstructions'] as String? ?? 'Afiyet olsun!';
        List<String> steps = instructions
            .split(RegExp(r'\r\n|\n|\r'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s.length > 3)
            .toList();
        
        if (steps.isEmpty) {
          steps = [instructions];
        }

        // Estimate prep time based on steps and ingredients count
        final prepMinutes = 10 + (ingredients.length * 1) + (steps.length * 1);
        final prepTime = '${prepMinutes.clamp(10, 45)} dk';

        // Calculate macro nutrition based on ingredients list
        final nutrition = estimateNutrition(ingredients);

        // Tags
        List<String> tags = ['Çevrimiçi', 'Sağlıklı'];
        final category = meal['strCategory'] as String?;
        if (category != null && category.trim().isNotEmpty) {
          tags.add(_translateTag(category));
        }
        final area = meal['strArea'] as String?;
        if (area != null && area.trim().isNotEmpty) {
          tags.add(_translateTag(area));
        }

        parsedSalads.add(
          SaladModel(
            id: 'api_$id',
            name: _translateMealName(name),
            ingredients: ingredients,
            steps: steps.map((s) => _translateStep(s)).toList(),
            preparationTime: prepTime,
            calories: nutrition['calories']!.toInt(),
            protein: nutrition['protein']!,
            carbs: nutrition['carbs']!,
            fat: nutrition['fat']!,
            tags: tags,
            imageUrl: imageUrl,
          ),
        );
      }

      return parsedSalads;
    } catch (e) {
      // Network error or timeout, return empty list
      return [];
    }
  }

  /// Estimates Calories, Protein, Carbs, and Fats based on ingredients keywords.
  static Map<String, double> estimateNutrition(List<String> ingredients) {
    double calories = 80.0;
    double protein = 2.0;
    double carbs = 4.0;
    double fat = 1.0;

    for (var ingredient in ingredients) {
      final ing = ingredient.toLowerCase();

      // Healthy Fats & Oils
      if (ing.contains('oil') || ing.contains('yağ') || ing.contains('butter') || ing.contains('mayonnaise') || ing.contains('dressing') || ing.contains('sos')) {
        fat += 10.0;
        calories += 90.0;
      }
      // Poultry & Red Meat
      else if (ing.contains('chicken') || ing.contains('tavuk') || ing.contains('turkey') || ing.contains('hindi') || ing.contains('beef') || ing.contains('meat') || ing.contains('et')) {
        protein += 18.0;
        fat += 3.0;
        calories += 110.0;
      }
      // Fish & Seafood
      else if (ing.contains('salmon') || ing.contains('somon') || ing.contains('tuna') || ing.contains('ton') || ing.contains('fish') || ing.contains('balık') || ing.contains('prawn') || ing.contains('shrimp') || ing.contains('karides')) {
        protein += 15.0;
        fat += 6.0;
        calories += 120.0;
      }
      // Avocado
      else if (ing.contains('avocado') || ing.contains('avokado')) {
        fat += 10.0;
        carbs += 5.0;
        calories += 120.0;
      }
      // Cheeses & Eggs
      else if (ing.contains('cheese') || ing.contains('peynir') || ing.contains('feta') || ing.contains('parmesan') || ing.contains('mozzarella') || ing.contains('halloumi') || ing.contains('hellim') || ing.contains('egg') || ing.contains('yumurta')) {
        protein += 6.0;
        fat += 5.0;
        calories += 75.0;
      }
      // Grains, Rice, Noodles, Potatoes (Carb-heavy)
      else if (ing.contains('quinoa') || ing.contains('kinoa') || ing.contains('rice') || ing.contains('pirinç') || ing.contains('noodle') || ing.contains('pasta') || ing.contains('macaroni') || ing.contains('couscous') || ing.contains('kuskus') || ing.contains('potato') || ing.contains('patates') || ing.contains('bread') || ing.contains('ekmek') || ing.contains('crouton') || ing.contains('kruton') || ing.contains('bulgur')) {
        carbs += 22.0;
        protein += 3.0;
        calories += 100.0;
      }
      // Beans & Lentils & Chickpeas
      else if (ing.contains('bean') || ing.contains('fasulye') || ing.contains('lentil') || ing.contains('mercimek') || ing.contains('chickpea') || ing.contains('nohut') || ing.contains('börülce')) {
        carbs += 15.0;
        protein += 6.0;
        calories += 90.0;
      }
      // Nuts & Seeds
      else if (ing.contains('nut') || ing.contains('walnut') || ing.contains('ceviz') || ing.contains('almond') || ing.contains('badem') || ing.contains('seed') || ing.contains('susam') || ing.contains('peanut') || ing.contains('fıstık')) {
        fat += 8.0;
        protein += 2.5;
        calories += 90.0;
      }
      // Yogurt
      else if (ing.contains('yogurt') || ing.contains('yoğurt')) {
        protein += 3.0;
        fat += 2.0;
        carbs += 3.0;
        calories += 45.0;
      }
      // Fruit (sweet components)
      else if (ing.contains('pomegranate') || ing.contains('nar') || ing.contains('apple') || ing.contains('elma') || ing.contains('strawberry') || ing.contains('çilek') || ing.contains('lemon') || ing.contains('limon') || ing.contains('fruit') || ing.contains('meyve') || ing.contains('orange') || ing.contains('portakal') || ing.contains('grape') || ing.contains('üzüm')) {
        carbs += 8.0;
        calories += 35.0;
      }
      // Sweeteners
      else if (ing.contains('honey') || ing.contains('bal') || ing.contains('sugar') || ing.contains('şeker') || ing.contains('maple') || ing.contains('pekmez')) {
        carbs += 12.0;
        calories += 50.0;
      }
      // Leafy Greens & Low-Calorie Vegetables
      else {
        carbs += 1.5;
        calories += 8.0;
      }
    }

    // Cap at reasonable numbers per portion
    return {
      'calories': calories.clamp(80.0, 580.0).roundToDouble(),
      'protein': double.parse(protein.clamp(1.0, 42.0).toStringAsFixed(1)),
      'carbs': double.parse(carbs.clamp(2.0, 60.0).toStringAsFixed(1)),
      'fat': double.parse(fat.clamp(0.5, 38.0).toStringAsFixed(1)),
    };
  }

  // Basic dictionary mappings to give the user a cleaner Turkish experience.
  static String _translateMealName(String name) {
    final Map<String, String> dict = {
      'Chilli and Lime Salad': 'Acılı ve Misket Limonlu Salata',
      'Salmon Avocado Salad': 'Somonlu Avokado Salatası',
      'Pomegranate Salad': 'Narlı Bahçe Salatası',
      'Noodle Bowl Salad': 'Erişteli Asya Salatası',
      'Summer Salad': 'Ferah Yaz Salatası',
      'Kumpir': 'Köz Patates Salatası (Kumpir)',
      'Chicken Salad': 'Izgara Tavuklu Salata',
      'Waldorf Salad': 'Cevizli ve Elmalı Waldorf Salatası',
      'Greek Salad': 'Klasik Grek (Yunan) Salatası',
      'Tabbouleh': 'Lübnan Usulü Tabule Salatası',
      'Potato Salad': 'Nefis Patates Salatası',
      'Cole Slaw': 'Lahana Salatası (Coleslaw)',
      'Shrimp Salad': 'Karidesli Gurme Salatası',
      'Niçoise Salad': 'Fransız Ton Balıklı Niçoise Salatası',
    };
    for (var key in dict.keys) {
      if (name.toLowerCase().contains(key.toLowerCase())) {
        return dict[key]!;
      }
    }
    return name;
  }

  static String _translateIngredient(String name) {
    final Map<String, String> dict = {
      'olive oil': 'zeytinyağı',
      'oil': 'sıvı yağ',
      'chicken': 'tavuk göğsü',
      'salmon': 'somon',
      'tuna': 'ton balığı',
      'shrimp': 'karides',
      'prawn': 'karides',
      'avocado': 'avokado',
      'feta': 'beyaz peynir',
      'parmesan': 'parmesan peyniri',
      'mozzarella': 'mozzarella peyniri',
      'cheese': 'peynir',
      'egg': 'yumurta',
      'quinoa': 'kinoa',
      'rice': 'pirinç',
      'noodle': 'erişte (noodle)',
      'pasta': 'makarna',
      'couscous': 'kuskus',
      'potato': 'patates',
      'crouton': 'kruton ekmek',
      'bread': 'ekmek',
      'walnut': 'ceviz',
      'almond': 'badem',
      'peanut': 'fıstık',
      'sesame': 'susam',
      'onion': 'soğan',
      'garlic': 'sarımsak',
      'tomato': 'domates',
      'cucumber': 'salatalık',
      'lettuce': 'marul',
      'spinach': 'ıspanak',
      'cabbage': 'lahana',
      'parsley': 'maydanoz',
      'mint': 'taze nane',
      'coriander': 'kişniş',
      'cilantro': 'taze kişniş',
      'lemon': 'limon',
      'lime': 'misket limonu',
      'pomegranate': 'nar',
      'apple': 'elma',
      'strawberry': 'çilek',
      'honey': 'bal',
      'sugar': 'şeker',
      'salt': 'tuz',
      'pepper': 'karabiber',
      'vinegar': 'sirke',
      'mustard': 'hardal',
      'yogurt': 'yoğurt',
      'mayonnaise': 'mayonez',
      'chili': 'acı biber',
    };
    final lower = name.toLowerCase();
    for (var key in dict.keys) {
      if (lower == key) return dict[key]!;
      if (lower.contains(key)) return name.replaceAll(RegExp(key, caseSensitive: false), dict[key]!);
    }
    return name;
  }

  static String _translateMeasure(String measure) {
    return measure
        .replaceAll('tbsp', 'Yemek Kaşığı')
        .replaceAll('tsp', 'Tatlı Kaşığı')
        .replaceAll('cup', 'Su Bardağı')
        .replaceAll('g ', 'gr ')
        .replaceAll('clove', 'Diş')
        .replaceAll('pinch', 'Tutam')
        .replaceAll('can ', 'Kutu ')
        .replaceAll('slice', 'Dilim')
        .replaceAll('whole', 'Adet')
        .replaceAll('to serve', 'Servis için');
  }

  static String _translateTag(String tag) {
    final Map<String, String> dict = {
      'Vegetarian': 'Vejetaryen',
      'Vegan': 'Vegan',
      'Seafood': 'Deniz Ürünü',
      'Chicken': 'Tavuklu',
      'Beef': 'Etli',
      'Pork': 'Etli',
      'Side': 'Aparatif',
      'Starter': 'Başlangıç',
      'Dessert': 'Tatlı',
      'Italian': 'İtalyan',
      'Greek': 'Yunan',
      'French': 'Fransız',
      'American': 'Amerikan',
      'Asian': 'Asya',
      'Mexican': 'Meksika',
      'Turkish': 'Türk',
    };
    return dict[tag] ?? tag;
  }

  static String _translateStep(String step) {
    // Basic step translation phrases for better localization
    return step
        .replaceAll('Preheat the oven', 'Fırını önceden ısıtın')
        .replaceAll('Mix in a bowl', 'Bir kasede karıştırın')
        .replaceAll('Chop the', 'Doğrayın:')
        .replaceAll('Serve immediately', 'Hemen servis yapın')
        .replaceAll('Add the', 'Ekleyin:')
        .replaceAll('Season with salt and pepper', 'Tuz ve karabiber ile tatlandırın');
  }
}
