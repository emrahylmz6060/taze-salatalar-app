import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/salad_model.dart';
import 'detail_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _healthyTips = [
    "Salatanıza avokado veya zeytinyağı gibi sağlıklı yağlar eklemek, yağda çözünen vitaminlerin emilimini kolaylaştırır.",
    "Sosları salatayı servis etmeden hemen önce ekleyin. Bu, yeşilliklerin canlı kalmasını ve pörsümesini engeller.",
    "Renkli salatalar farklı vitamin gruplarını temsil eder. Ne kadar çok renk, o kadar çok antioksidan demektir!",
    "Yeşillikleri yıkadıktan sonra mutlaka kurutun. Kalan su, sosun yeşilliklere yapışmasını önler.",
    "Salatanıza nohut, yeşil mercimek veya haşlanmış tavuk göğsü ekleyerek doyurucu bir ana öğün haline getirebilirsiniz."
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final allSalads = appProvider.allSalads;
    final primaryColor = Theme.of(context).primaryColor;

    SaladModel? featuredSalad;
    if (allSalads.isNotEmpty) {
      final int index = DateTime.now().day % allSalads.length;
      featuredSalad = allSalads[index];
    }

    final String todayTip = _healthyTips[DateTime.now().day % _healthyTips.length];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.7),
            radius: 1.2,
            colors: [
              Color(0xFFE6F4EA),
              Color(0xFFF4FAF6),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.spa, color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Taze Salatalar',
                        style: TextStyle(
                          color: Colors.grey[850],
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(Icons.add, color: primaryColor, size: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
                        );
                      },
                      tooltip: 'Yeni Tarif Ekle',
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ];
            },
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                if (isWide) {
                  // Two column layout on wider screens
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Greetings, Dashboard, Water
                        Expanded(
                          flex: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreeting(),
                              const SizedBox(height: 24),
                              _buildCalorieCard(appProvider, primaryColor),
                              const SizedBox(height: 24),
                              _buildWaterTrackerCard(appProvider, primaryColor),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: Featured Recipe, Health Tip
                        Expanded(
                          flex: 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (featuredSalad != null) ...[
                                _buildFeaturedSection(featuredSalad, primaryColor),
                                const SizedBox(height: 24),
                              ],
                              _buildTipCard(todayTip, primaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Mobile Single Column Scroll Layout
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _buildCalorieCard(appProvider, primaryColor),
                      const SizedBox(height: 24),
                      _buildWaterTrackerCard(appProvider, primaryColor),
                      const SizedBox(height: 24),
                      if (featuredSalad != null) ...[
                        _buildFeaturedSection(featuredSalad, primaryColor),
                        const SizedBox(height: 24),
                      ],
                      _buildTipCard(todayTip, primaryColor),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Beautiful Organic Greeting
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.grey[850],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bugün sağlıklı bir gün geçirmeye hazır mısın?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Premium Macronutrient Dashboard Card
  Widget _buildCalorieCard(AppProvider appProvider, Color primaryColor) {
    final int eaten = appProvider.caloriesEatenToday;
    final int goal = appProvider.dailyCalorieGoal;
    final double percent = (eaten / goal).clamp(0.0, 1.0);
    final int remaining = (goal - eaten).clamp(0, goal);

    final double protein = appProvider.proteinEatenToday;
    final double proteinGoal = appProvider.dailyProteinGoal;
    final double proteinPercent = (protein / proteinGoal).clamp(0.0, 1.0);

    final double carbs = appProvider.carbsEatenToday;
    final double carbsGoal = appProvider.dailyCarbsGoal;
    final double carbsPercent = (carbs / carbsGoal).clamp(0.0, 1.0);

    final double fat = appProvider.fatEatenToday;
    final double fatGoal = appProvider.dailyFatGoal;
    final double fatPercent = (fat / fatGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günlük Besin Özeti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[850],
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Quick reset button with confirmation
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Değerleri Sıfırla?'),
                      content: const Text('Bugün kaydettiğiniz tüm yiyecek ve kalori verileri sıfırlanacaktır. Emin misiniz?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
                        TextButton(
                          onPressed: () {
                            appProvider.resetCalories();
                            Navigator.pop(context);
                          },
                          child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(Icons.restart_alt, color: Colors.grey[400], size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Left side: Large circular progress ring
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 105,
                          height: 105,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 10,
                            backgroundColor: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                            color: percent >= 1.0 ? Colors.amber : primaryColor,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$eaten',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                color: Colors.grey[850],
                              ),
                            ),
                            Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kalan: $remaining kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: remaining > 0 ? Colors.grey[700] : Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right side: Macros Progress (Protein, Carbs, Fats)
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildMacroBar('Protein', protein, proteinGoal, proteinPercent, const Color(0xFF0D9488)),
                    const SizedBox(height: 14),
                    _buildMacroBar('Karbonhidrat', carbs, carbsGoal, carbsPercent, const Color(0xFFD97706)),
                    const SizedBox(height: 14),
                    _buildMacroBar('Yağ', fat, fatGoal, fatPercent, const Color(0xFFDB2777)),
                  ],
                ),
              ),
            ],
          ),
          if (percent >= 1.0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tebrikler! Günlük salata kalori hedefini tamamladın!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, double eaten, double goal, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '${eaten.toStringAsFixed(1)}/${goal.toInt()}g',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            return Stack(
              children: [
                Container(
                  height: 7,
                  width: width,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 7,
                  width: width * percent,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Interactive Water Tracker Card
  Widget _buildWaterTrackerCard(AppProvider appProvider, Color primaryColor) {
    final int glasses = appProvider.waterGlassesToday;
    final int goal = appProvider.dailyWaterGoal;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Günlük Su Takibi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[850],
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hedef: $goal Bardak (${goal * 250} ml)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.water_drop, color: Colors.blue[400], size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$glasses / $goal Bardak',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue[600],
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: glasses > 0 ? () => appProvider.addWaterGlass(-1) : null,
                    icon: Icon(Icons.remove_circle_outline, color: glasses > 0 ? Colors.blue[600] : Colors.grey[300]),
                  ),
                  IconButton(
                    onPressed: () => appProvider.addWaterGlass(1),
                    icon: Icon(Icons.add_circle, color: Colors.blue[600], size: 28),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(goal, (index) {
              final isFilled = index < glasses;
              return AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isFilled ? 1.1 : 1.0,
                child: Icon(
                  isFilled ? Icons.local_drink : Icons.local_drink_outlined,
                  color: isFilled ? Colors.blue[400] : Colors.grey[300],
                  size: 30,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Daily Featured Recipe Card
  Widget _buildFeaturedSection(SaladModel salad, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Günün Tarifi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey[850],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(salad: salad)),
            );
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: salad.imageUrl.startsWith('http')
                            ? Image.network(
                                salad.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                ),
                              )
                            : (salad.imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    salad.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                    ),
                                  )
                                : Image.file(
                                    File(salad.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                    ),
                                  )),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                salad.preparationTime,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salad.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[850],
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${salad.ingredients.length} malzeme • Pratik ve lezzetli',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${salad.calories} kcal',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Daily Healthy Tip Widget
  Widget _buildTipCard(String tipText, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.08),
            primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                )
              ]
            ),
            child: Icon(Icons.tips_and_updates, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günün İpucu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[850],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tipText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
