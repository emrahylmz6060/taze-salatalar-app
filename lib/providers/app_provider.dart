import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/salad_model.dart';

class AppProvider with ChangeNotifier {
  List<SaladModel> _allSalads = [];
  final List<String> _favoriteIds = [];
  int _caloriesEatenToday = 0;
  int _dailyCalorieGoal = 1500;
  double _proteinEatenToday = 0.0;
  double _carbsEatenToday = 0.0;
  double _fatEatenToday = 0.0;
  double _dailyProteinGoal = 80.0;
  double _dailyCarbsGoal = 180.0;
  double _dailyFatGoal = 60.0;

  int _waterGlassesToday = 0;
  final int _dailyWaterGoal = 8; // 8 glasses = 2000 ml
  Map<String, bool> _shoppingItems = {};
  bool _isLoading = true;
  int _currentTabIndex = 0;

  List<SaladModel> get allSalads => _allSalads;
  List<SaladModel> get favoriteSalads => _allSalads.where((s) => _favoriteIds.contains(s.id)).toList();
  List<String> get favoriteIds => _favoriteIds;
  int get caloriesEatenToday => _caloriesEatenToday;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  double get proteinEatenToday => _proteinEatenToday;
  double get carbsEatenToday => _carbsEatenToday;
  double get fatEatenToday => _fatEatenToday;
  double get dailyProteinGoal => _dailyProteinGoal;
  double get dailyCarbsGoal => _dailyCarbsGoal;
  double get dailyFatGoal => _dailyFatGoal;

  int get waterGlassesToday => _waterGlassesToday;
  int get dailyWaterGoal => _dailyWaterGoal;
  Map<String, bool> get shoppingItems => _shoppingItems;
  bool get isLoading => _isLoading;
  int get currentTabIndex => _currentTabIndex;

  AppProvider() {
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load built-in salads
    final String response = await rootBundle.loadString('assets/data/salads.json');
    final List<dynamic> defaultData = json.decode(response);
    List<SaladModel> loadedSalads = defaultData.map((json) => SaladModel.fromJson(json)).toList();

    // 2. Load custom recipes
    final String? customSaladsStr = prefs.getString('custom_salads');
    if (customSaladsStr != null) {
      final List<dynamic> customData = json.decode(customSaladsStr);
      loadedSalads.addAll(customData.map((json) => SaladModel.fromJson(json)));
    }
    _allSalads = loadedSalads;

    // 3. Load favorites
    final List<String>? favs = prefs.getStringList('favorite_ids');
    if (favs != null) {
      _favoriteIds.addAll(favs);
    }

    // Load goals
    _dailyCalorieGoal = prefs.getInt('daily_calorie_goal') ?? 1500;
    _dailyProteinGoal = prefs.getDouble('daily_protein_goal') ?? 80.0;
    _dailyCarbsGoal = prefs.getDouble('daily_carbs_goal') ?? 180.0;
    _dailyFatGoal = prefs.getDouble('daily_fat_goal') ?? 60.0;

    // 4. Load calories & water (check date)
    final String todayDate = DateTime.now().toIso8601String().split('T')[0];
    final String? savedDate = prefs.getString('calorie_date');
    if (savedDate == todayDate) {
      _caloriesEatenToday = prefs.getInt('calories_eaten') ?? 0;
      _waterGlassesToday = prefs.getInt('water_glasses') ?? 0;
      _proteinEatenToday = prefs.getDouble('protein_eaten') ?? 0.0;
      _carbsEatenToday = prefs.getDouble('carbs_eaten') ?? 0.0;
      _fatEatenToday = prefs.getDouble('fat_eaten') ?? 0.0;
    } else {
      // New day, reset
      _caloriesEatenToday = 0;
      _waterGlassesToday = 0;
      _proteinEatenToday = 0.0;
      _carbsEatenToday = 0.0;
      _fatEatenToday = 0.0;
      await prefs.setString('calorie_date', todayDate);
      await prefs.setInt('calories_eaten', 0);
      await prefs.setInt('water_glasses', 0);
      await prefs.setDouble('protein_eaten', 0.0);
      await prefs.setDouble('carbs_eaten', 0.0);
      await prefs.setDouble('fat_eaten', 0.0);
    }

    // 5. Load shopping items
    final String? shoppingStr = prefs.getString('shopping_list');
    if (shoppingStr != null) {
      final Map<String, dynamic> decoded = json.decode(shoppingStr);
      _shoppingItems = decoded.map((key, value) => MapEntry(key, value as bool));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_ids', _favoriteIds);
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  Future<void> addRecipe(SaladModel newSalad) async {
    _allSalads.add(newSalad);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // Get existing custom salads
    final String? customSaladsStr = prefs.getString('custom_salads');
    List<dynamic> customData = customSaladsStr != null ? json.decode(customSaladsStr) : [];
    customData.add(newSalad.toJson());
    await prefs.setString('custom_salads', json.encode(customData));
  }

  Future<void> addCalories(int calories) async {
    _caloriesEatenToday += calories;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_eaten', _caloriesEatenToday);
  }

  Future<void> addEatenMeal(int calories, double protein, double carbs, double fat) async {
    _caloriesEatenToday += calories;
    _proteinEatenToday += protein;
    _carbsEatenToday += carbs;
    _fatEatenToday += fat;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_eaten', _caloriesEatenToday);
    await prefs.setDouble('protein_eaten', _proteinEatenToday);
    await prefs.setDouble('carbs_eaten', _carbsEatenToday);
    await prefs.setDouble('fat_eaten', _fatEatenToday);
  }

  Future<void> removeEatenMeal(int calories, double protein, double carbs, double fat) async {
    _caloriesEatenToday = (_caloriesEatenToday - calories).clamp(0, 99999);
    _proteinEatenToday = (_proteinEatenToday - protein).clamp(0.0, 9999.0);
    _carbsEatenToday = (_carbsEatenToday - carbs).clamp(0.0, 9999.0);
    _fatEatenToday = (_fatEatenToday - fat).clamp(0.0, 9999.0);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_eaten', _caloriesEatenToday);
    await prefs.setDouble('protein_eaten', _proteinEatenToday);
    await prefs.setDouble('carbs_eaten', _carbsEatenToday);
    await prefs.setDouble('fat_eaten', _fatEatenToday);
  }

  Future<void> resetCalories() async {
    _caloriesEatenToday = 0;
    _proteinEatenToday = 0.0;
    _carbsEatenToday = 0.0;
    _fatEatenToday = 0.0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_eaten', 0);
    await prefs.setDouble('protein_eaten', 0.0);
    await prefs.setDouble('carbs_eaten', 0.0);
    await prefs.setDouble('fat_eaten', 0.0);
  }

  // Water tracking methods
  Future<void> addWaterGlass(int count) async {
    _waterGlassesToday = (_waterGlassesToday + count).clamp(0, 99);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_glasses', _waterGlassesToday);
  }

  Future<void> resetWater() async {
    _waterGlassesToday = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_glasses', 0);
  }

  // Shopping list methods
  Future<void> addIngredientsToShopping(List<String> ingredients) async {
    for (var ingredient in ingredients) {
      if (!_shoppingItems.containsKey(ingredient)) {
        _shoppingItems[ingredient] = false;
      }
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shopping_list', json.encode(_shoppingItems));
  }

  Future<void> addCustomShoppingItem(String item) async {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty && !_shoppingItems.containsKey(trimmed)) {
      _shoppingItems[trimmed] = false;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shopping_list', json.encode(_shoppingItems));
    }
  }

  Future<void> toggleShoppingItem(String item) async {
    if (_shoppingItems.containsKey(item)) {
      _shoppingItems[item] = !_shoppingItems[item]!;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shopping_list', json.encode(_shoppingItems));
    }
  }

  Future<void> removeShoppingItem(String item) async {
    if (_shoppingItems.containsKey(item)) {
      _shoppingItems.remove(item);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shopping_list', json.encode(_shoppingItems));
    }
  }

  Future<void> clearShoppingList() async {
    _shoppingItems.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shopping_list');
  }

  Future<void> updateDailyCalorieGoal(int goal) async {
    _dailyCalorieGoal = goal;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_calorie_goal', goal);
  }

  Future<void> updateDailyMacroGoals(double protein, double carbs, double fat) async {
    _dailyProteinGoal = protein;
    _dailyCarbsGoal = carbs;
    _dailyFatGoal = fat;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('daily_protein_goal', protein);
    await prefs.setDouble('daily_carbs_goal', carbs);
    await prefs.setDouble('daily_fat_goal', fat);
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
