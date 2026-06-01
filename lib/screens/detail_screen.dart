import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salad_model.dart';
import '../providers/app_provider.dart';

class DetailScreen extends StatefulWidget {
  final SaladModel salad;

  const DetailScreen({super.key, required this.salad});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _portions = 1;
  bool _isEaten = false;
  int _eatenCalories = 0;
  double _eatenProtein = 0.0;
  double _eatenCarbs = 0.0;
  double _eatenFat = 0.0;

  // Regex to find numbers in ingredient strings (e.g. "1 adet", "0.5 bardak", "200 gr")
  String _calculateIngredient(String ingredient) {
    if (_portions == 1) return ingredient;
    
    final regex = RegExp(r'^([0-9\.]+)\s*(.*)');
    final match = regex.firstMatch(ingredient);
    
    if (match != null) {
      double? num = double.tryParse(match.group(1)!);
      if (num != null) {
        num = num * _portions;
        String numStr = num.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        return '$numStr ${match.group(2)}';
      }
    }
    return ingredient;
  }

  void _handleEatToggle(
    BuildContext context,
    AppProvider appProvider,
    int totalCalories,
    double totalProtein,
    double totalCarbs,
    double totalFat,
  ) {
    if (_isEaten) {
      appProvider.removeEatenMeal(_eatenCalories, _eatenProtein, _eatenCarbs, _eatenFat);
      setState(() {
        _isEaten = false;
        _eatenCalories = 0;
        _eatenProtein = 0.0;
        _eatenCarbs = 0.0;
        _eatenFat = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yediklerimden çıkarıldı.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      appProvider.addEatenMeal(totalCalories, totalProtein, totalCarbs, totalFat);
      setState(() {
        _isEaten = true;
        _eatenCalories = totalCalories;
        _eatenProtein = totalProtein;
        _eatenCarbs = totalCarbs;
        _eatenFat = totalFat;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Afiyet olsun! $totalCalories kcal hedefine eklendi.'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  void _handleAddToShopping(BuildContext context, AppProvider appProvider) {
    final List<String> scaledIngredients = widget.salad.ingredients.map((ing) => _calculateIngredient(ing)).toList();
    appProvider.addIngredientsToShopping(scaledIngredients);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scaledIngredients.length} malzeme alışveriş listesine eklendi!'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isFav = appProvider.isFavorite(widget.salad.id);
    final int totalCalories = widget.salad.calories * _portions;
    final double totalProtein = widget.salad.protein * _portions;
    final double totalCarbs = widget.salad.carbs * _portions;
    final double totalFat = widget.salad.fat * _portions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MediaQuery.of(context).size.width >= 800
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.salad.name,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.black87,
                  ),
                  onPressed: () => appProvider.toggleFavorite(widget.salad.id),
                ),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          if (isWide) {
            return _buildWideLayout(context, appProvider, isFav, totalCalories, totalProtein, totalCarbs, totalFat);
          } else {
            return _buildMobileLayout(context, appProvider, isFav, totalCalories, totalProtein, totalCarbs, totalFat);
          }
        },
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    final isNetwork = imageUrl.startsWith('http');
    final isAsset = imageUrl.startsWith('assets/');
    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width ?? double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      );
    } else if (isAsset) {
      return Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width ?? double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width ?? double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      );
    }
  }

  Widget _buildWideLayout(
    BuildContext context,
    AppProvider appProvider,
    bool isFav,
    int totalCalories,
    double totalProtein,
    double totalCarbs,
    double totalFat,
  ) {
    final primaryColor = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Image & Actions)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildRecipeImage(
                    widget.salad.imageUrl,
                    height: 350,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 24),
                // Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      context,
                      icon: Icons.local_fire_department_outlined,
                      title: 'Kalori',
                      value: '$totalCalories kcal',
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildInfoCard(
                      context,
                      icon: Icons.timer_outlined,
                      title: 'Süre',
                      value: widget.salad.preparationTime,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Macronutrient Breakdown
                _buildMacroBreakdown(context, totalProtein, totalCarbs, totalFat),
                const SizedBox(height: 20),
                // Portions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Porsiyon Sayısı:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _portions > 1 ? () => setState(() => _portions--) : null,
                            icon: Icon(Icons.remove_circle_outline, color: _portions > 1 ? primaryColor : Colors.grey),
                          ),
                          Text(
                            '$_portions',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _portions++),
                            icon: Icon(Icons.add_circle_outline, color: primaryColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Eat Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleEatToggle(context, appProvider, totalCalories, totalProtein, totalCarbs, totalFat),
                    icon: Icon(_isEaten ? Icons.remove_circle_outline : Icons.restaurant, color: Colors.white),
                    label: Text(
                      _isEaten ? 'Yediklerimden Çıkar' : 'Bunu Yedim',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEaten ? Colors.redAccent : primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Add to Shopping List Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAddToShopping(context, appProvider),
                    icon: Icon(Icons.shopping_basket_outlined, color: primaryColor),
                    label: Text(
                      'Malzemeleri Listeye Ekle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Right Column (Ingredients & Steps)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.salad.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Ingredients title
                const Text(
                  'Malzemeler',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.salad.ingredients.map((ingredient) {
                  String displayIngredient = _calculateIngredient(ingredient);
                  return _buildIngredientRow(context, displayIngredient, primaryColor);
                }),
                const SizedBox(height: 32),
                // Steps title
                const Text(
                  'Yapılış Adımları',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.salad.steps.asMap().entries.map((entry) {
                  return _buildStepRow(context, entry.key, entry.value, primaryColor);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AppProvider appProvider,
    bool isFav,
    int totalCalories,
    double totalProtein,
    double totalCarbs,
    double totalFat,
  ) {
    final primaryColor = Theme.of(context).primaryColor;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          pinned: true,
          elevation: 0,
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black87,
                  size: 20,
                ),
              ),
              onPressed: () {
                appProvider.toggleFavorite(widget.salad.id);
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildRecipeImage(
              widget.salad.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            transform: Matrix4.translationValues(0.0, -30.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Tags
                  Text(
                    widget.salad.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.salad.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        context,
                        icon: Icons.local_fire_department_outlined,
                        title: 'Kalori',
                        value: '$totalCalories kcal',
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildInfoCard(
                        context,
                        icon: Icons.timer_outlined,
                        title: 'Süre',
                        value: widget.salad.preparationTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Macronutrient Breakdown
                  _buildMacroBreakdown(context, totalProtein, totalCarbs, totalFat),
                  const SizedBox(height: 20),

                  // Portion Calculator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Porsiyon Sayısı:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _portions > 1 ? () => setState(() => _portions--) : null,
                              icon: Icon(Icons.remove_circle_outline, color: _portions > 1 ? primaryColor : Colors.grey),
                            ),
                            Text(
                              '$_portions',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _portions++),
                              icon: Icon(Icons.add_circle_outline, color: primaryColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Ingredients Header and Add to Shopping Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Malzemeler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, color: primaryColor),
                        onPressed: () => _handleAddToShopping(context, appProvider),
                        tooltip: 'Alışveriş Listesine Ekle',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.salad.ingredients.map((ingredient) {
                    String displayIngredient = _calculateIngredient(ingredient);
                    return _buildIngredientRow(context, displayIngredient, primaryColor);
                  }),
                  
                  const SizedBox(height: 16),
                  // Add to Shopping List Text Button for visual clarity
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleAddToShopping(context, appProvider),
                      icon: Icon(Icons.shopping_basket_outlined, color: primaryColor),
                      label: Text(
                        'Malzemeleri Alışveriş Listesine Ekle',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Steps
                  const Text(
                    'Yapılış Adımları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.salad.steps.asMap().entries.map((entry) {
                    return _buildStepRow(context, entry.key, entry.value, primaryColor);
                  }),
                  const SizedBox(height: 40),
                  
                  // Eat Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleEatToggle(context, appProvider, totalCalories, totalProtein, totalCarbs, totalFat),
                      icon: Icon(_isEaten ? Icons.remove_circle_outline : Icons.restaurant, color: Colors.white),
                      label: Text(
                        _isEaten ? 'Yediklerimden Çıkar' : 'Bunu Yedim',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEaten ? Colors.redAccent : primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(BuildContext context, String ingredient, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              ingredient,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, int index, String step, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(BuildContext context, double protein, double carbs, double fat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Besin Değerleri Analizi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroBadge(
                name: 'Protein',
                value: '${protein.toStringAsFixed(1)}g',
                color: const Color(0xFF0D9488),
              ),
              _buildMacroBadge(
                name: 'Karb',
                value: '${carbs.toStringAsFixed(1)}g',
                color: const Color(0xFFD97706),
              ),
              _buildMacroBadge(
                name: 'Yağ',
                value: '${fat.toStringAsFixed(1)}g',
                color: const Color(0xFFDB2777),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBadge({required String name, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
