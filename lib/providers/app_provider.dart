import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/salad_model.dart';

class AppProvider with ChangeNotifier {
  List<SaladModel> _allSalads = [];
  final List<String> _favoriteIds = [];
  int _caloriesEatenToday = 0;
  final int _dailyCalorieGoal = 1500;
  bool _isLoading = true;

  List<SaladModel> get allSalads => _allSalads;
  List<SaladModel> get favoriteSalads => _allSalads.where((s) => _favoriteIds.contains(s.id)).toList();
  List<String> get favoriteIds => _favoriteIds;
  int get caloriesEatenToday => _caloriesEatenToday;
  int get dailyCalorieGoal => _dailyCalorieGoal;
  bool get isLoading => _isLoading;

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

    // 4. Load calories (check date)
    final String todayDate = DateTime.now().toIso8601String().split('T')[0];
    final String? savedDate = prefs.getString('calorie_date');
    if (savedDate == todayDate) {
      _caloriesEatenToday = prefs.getInt('calories_eaten') ?? 0;
    } else {
      // New day, reset
      _caloriesEatenToday = 0;
      await prefs.setString('calorie_date', todayDate);
      await prefs.setInt('calories_eaten', 0);
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

  Future<void> resetCalories() async {
    _caloriesEatenToday = 0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calories_eaten', 0);
  }
}
