import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final eaten = appProvider.caloriesEatenToday;
    final goal = appProvider.dailyCalorieGoal;
    final waterEaten = appProvider.waterGlassesToday;
    final waterGoal = appProvider.dailyWaterGoal;
    
    final double progress = (eaten / goal).clamp(0.0, 1.0);
    final double waterProgress = (waterEaten / waterGoal).clamp(0.0, 1.0);
    
    final bool isExceeded = eaten > goal;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color progressColor = isExceeded ? Colors.redAccent : primaryColor;
    final int difference = (goal - eaten).abs();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profilim',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Günlük özetin ve hedeflerin',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProgressCard(context, eaten, goal, progress, progressColor, isExceeded, difference),
                        const SizedBox(height: 24),
                        _buildMacroProgressCard(context, appProvider),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGoalControlCard(context, appProvider),
                        const SizedBox(height: 24),
                        _buildWaterSummaryCard(context, appProvider, waterEaten, waterGoal, waterProgress, primaryColor),
                        const SizedBox(height: 24),
                        _buildSettingsCard(context, appProvider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProgressCard(context, eaten, goal, progress, progressColor, isExceeded, difference),
                  const SizedBox(height: 16),
                  _buildMacroProgressCard(context, appProvider),
                  const SizedBox(height: 16),
                  _buildGoalControlCard(context, appProvider),
                  const SizedBox(height: 16),
                  _buildWaterSummaryCard(context, appProvider, waterEaten, waterGoal, waterProgress, primaryColor),
                  const SizedBox(height: 16),
                  _buildSettingsCard(context, appProvider),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    int eaten,
    int goal,
    double progress,
    Color progressColor,
    bool isExceeded,
    int difference,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Kalori Takipçisi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: Colors.grey[150] ?? const Color(0xFFEEEEEE),
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$eaten',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  const Text(
                    'kcal alınan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: progressColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isExceeded ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: progressColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isExceeded 
                      ? 'Dikkat: Günlük hedefini $difference kcal aştın!'
                      : 'Günlük hedefine ulaşmak için $difference kcal kaldı.',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgressCard(BuildContext context, AppProvider provider) {
    final double protein = provider.proteinEatenToday;
    final double proteinGoal = provider.dailyProteinGoal;
    final double proteinPercent = (protein / proteinGoal).clamp(0.0, 1.0);

    final double carbs = provider.carbsEatenToday;
    final double carbsGoal = provider.dailyCarbsGoal;
    final double carbsPercent = (carbs / carbsGoal).clamp(0.0, 1.0);

    final double fat = provider.fatEatenToday;
    final double fatGoal = provider.dailyFatGoal;
    final double fatPercent = (fat / fatGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Makro Besin Değerleri Özeti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildMacroSummaryItem(context, 'Protein', protein, proteinGoal, proteinPercent, const Color(0xFF0D9488)),
          const SizedBox(height: 18),
          _buildMacroSummaryItem(context, 'Karbonhidrat', carbs, carbsGoal, carbsPercent, const Color(0xFFD97706)),
          const SizedBox(height: 18),
          _buildMacroSummaryItem(context, 'Yağ', fat, fatGoal, fatPercent, const Color(0xFFDB2777)),
        ],
      ),
    );
  }

  Widget _buildMacroSummaryItem(BuildContext context, String name, double eaten, double goal, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            Text(
              '${eaten.toStringAsFixed(1)}g / ${goal.toInt()}g',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalControlCard(BuildContext context, AppProvider provider) {
    final primaryColor = Theme.of(context).primaryColor;
    final int goal = provider.dailyCalorieGoal;
    final double proteinGoal = provider.dailyProteinGoal;
    final double carbsGoal = provider.dailyCarbsGoal;
    final double fatGoal = provider.dailyFatGoal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Günlük Hedefleri Güncelle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Günlük tüketmek istediğiniz kalori ve makro miktarlarını belirleyin.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          // Calories Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kalori Hedefi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                '$goal kcal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: goal.toDouble(),
            min: 1000,
            max: 3500,
            divisions: 50,
            activeColor: primaryColor,
            inactiveColor: Colors.grey[200],
            label: '$goal kcal',
            onChanged: (value) {
              provider.updateDailyCalorieGoal(value.round());
            },
          ),
          
          const Divider(height: 32),
          
          // Protein Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Protein Hedefi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                '${proteinGoal.toInt()} g',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          Slider(
            value: proteinGoal,
            min: 20,
            max: 250,
            divisions: 46,
            activeColor: const Color(0xFF0D9488),
            inactiveColor: Colors.grey[200],
            label: '${proteinGoal.toInt()} g',
            onChanged: (value) {
              provider.updateDailyMacroGoals(value, carbsGoal, fatGoal);
            },
          ),

          const Divider(height: 32),

          // Carbs Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Karbonhidrat Hedefi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                '${carbsGoal.toInt()} g',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          Slider(
            value: carbsGoal,
            min: 50,
            max: 400,
            divisions: 70,
            activeColor: const Color(0xFFD97706),
            inactiveColor: Colors.grey[200],
            label: '${carbsGoal.toInt()} g',
            onChanged: (value) {
              provider.updateDailyMacroGoals(proteinGoal, value, fatGoal);
            },
          ),

          const Divider(height: 32),

          // Fat Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yağ Hedefi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                '${fatGoal.toInt()} g',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFDB2777),
                ),
              ),
            ],
          ),
          Slider(
            value: fatGoal,
            min: 10,
            max: 150,
            divisions: 28,
            activeColor: const Color(0xFFDB2777),
            inactiveColor: Colors.grey[200],
            label: '${fatGoal.toInt()} g',
            onChanged: (value) {
              provider.updateDailyMacroGoals(proteinGoal, carbsGoal, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWaterSummaryCard(
    BuildContext context,
    AppProvider provider,
    int waterEaten,
    int waterGoal,
    double waterProgress,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Su Tüketim Özeti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$waterEaten / $waterGoal Bardak',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: waterProgress,
              minHeight: 12,
              backgroundColor: Colors.grey[100],
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            waterEaten >= waterGoal
                ? 'Harika! Bugün için su hedefini tamamladın.'
                : 'Vücudunu susuz bırakma! Su içmeyi ihmal etme.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.orange),
            ),
            title: const Text(
              'Kalorileri Sıfırla',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: const Text('Bugün yediğin tüm yemekleri listeden siler.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kalorileri Sıfırla'),
                  content: const Text('Bugün kaydettiğin tüm yemek kalorilerini sıfırlamak istediğine emin misin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        provider.resetCalories();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Yenilen kalori miktarı sıfırlandı.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_drink_outlined, color: Colors.blue),
            ),
            title: const Text(
              'Su Tüketimini Sıfırla',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: const Text('Bugün içtiğin su miktarını sıfırlar.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Suyu Sıfırla'),
                  content: const Text('Bugün içtiğin su bardak miktarını sıfırlamak istediğine emin misin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        provider.resetWater();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('İçilen su miktarı sıfırlandı.'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
