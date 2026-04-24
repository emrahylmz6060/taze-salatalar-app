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

  // Regex to find numbers in ingredient strings (e.g. "1 adet", "0.5 bardak", "200 gr")
  String _calculateIngredient(String ingredient) {
    if (_portions == 1) return ingredient;
    
    // Simple logic: if the string starts with a number, multiply it.
    // E.g. "1 adet marul" -> "2 adet marul"
    final regex = RegExp(r'^([0-9\.]+)\s*(.*)');
    final match = regex.firstMatch(ingredient);
    
    if (match != null) {
      double? num = double.tryParse(match.group(1)!);
      if (num != null) {
        num = num * _portions;
        // Format to remove trailing .0
        String numStr = num.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        return '$numStr ${match.group(2)}';
      }
    }
    return ingredient; // If no number at start, return as is
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isFav = appProvider.isFavorite(widget.salad.id);
    final int totalCalories = widget.salad.calories * _portions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
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
              background: Image.asset(
                widget.salad.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  );
                },
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
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
                    const SizedBox(height: 24),

                    // Portion Calculator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
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
                                icon: Icon(Icons.remove_circle_outline, color: _portions > 1 ? Theme.of(context).primaryColor : Colors.grey),
                              ),
                              Text(
                                '$_portions',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _portions++),
                                icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Ingredients
                    const Text(
                      'Malzemeler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.salad.ingredients.map((ingredient) {
                          String displayIngredient = _calculateIngredient(ingredient);
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
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    displayIngredient,
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
                        }),
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
                      int index = entry.key;
                      String step = entry.value;
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
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
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
                    }),
                    const SizedBox(height: 40),
                    
                    // Eat Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_isEaten) {
                            appProvider.addCalories(-_eatenCalories);
                            setState(() {
                              _isEaten = false;
                              _eatenCalories = 0;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Yediklerimden çıkarıldı.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            appProvider.addCalories(totalCalories);
                            setState(() {
                              _isEaten = true;
                              _eatenCalories = totalCalories;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Afiyet olsun! $totalCalories kcal hedefine eklendi.'),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            );
                          }
                        },
                        icon: Icon(_isEaten ? Icons.remove_circle_outline : Icons.restaurant, color: Colors.white),
                        label: Text(
                          _isEaten ? 'Yediklerimden Çıkar' : 'Bunu Yedim',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEaten ? Colors.redAccent : Theme.of(context).primaryColor,
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
      ),
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
}
