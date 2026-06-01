import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'shopping_list_screen.dart';
import 'profile_screen.dart';
import 'analyzer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const AnalyzerScreen(),
    const FavoritesScreen(),
    const ShoppingListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if provider is loading
    final provider = Provider.of<AppProvider>(context);
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Color primaryColor = Theme.of(context).primaryColor;
    final int currentIndex = provider.currentTabIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                // Premium Left Sidebar
                Container(
                  width: 260,
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Logo / Title
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.restaurant_menu, color: primaryColor, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Taze Salatalar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nav Items
                        _buildSidebarItem(context, 0, Icons.home_outlined, Icons.home, 'Ana Sayfa', primaryColor, currentIndex),
                        _buildSidebarItem(context, 1, Icons.explore_outlined, Icons.explore, 'Keşfet', primaryColor, currentIndex),
                        _buildSidebarItem(context, 2, Icons.psychology_outlined, Icons.psychology, 'Besin Analizi', primaryColor, currentIndex),
                        _buildSidebarItem(context, 3, Icons.favorite_outline, Icons.favorite, 'Favorilerim', primaryColor, currentIndex),
                        _buildSidebarItem(context, 4, Icons.shopping_basket_outlined, Icons.shopping_basket, 'Alışveriş', primaryColor, currentIndex),
                        _buildSidebarItem(context, 5, Icons.person_outline, Icons.person, 'Profil', primaryColor, currentIndex),
                        
                        const Spacer(),
                        // Bottom User Profile Indicator
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                                  child: Icon(Icons.person, color: primaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kullanıcı',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Sağlıklı Yaşam',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: Colors.grey[200]),
                // Main Content
                Expanded(
                  child: _pages[currentIndex],
                ),
              ],
            ),
          );
        }

        // Mobile / Tablet View
        return Scaffold(
          extendBody: true,
          body: _pages[currentIndex],
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomNavItem(0, Icons.home_rounded, 'Ana Sayfa', primaryColor, currentIndex, provider),
                          _buildBottomNavItem(1, Icons.explore_rounded, 'Keşfet', primaryColor, currentIndex, provider),
                          _buildBottomNavItem(2, Icons.psychology_rounded, 'Analiz', primaryColor, currentIndex, provider),
                          _buildBottomNavItem(3, Icons.favorite_rounded, 'Favoriler', primaryColor, currentIndex, provider),
                          _buildBottomNavItem(4, Icons.shopping_basket_rounded, 'Alışveriş', primaryColor, currentIndex, provider),
                          _buildBottomNavItem(5, Icons.person_rounded, 'Profil', primaryColor, currentIndex, provider),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    Color primaryColor,
    int currentIndex,
  ) {
    final bool isSelected = currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          Provider.of<AppProvider>(context, listen: false).setTabIndex(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
    int currentIndex,
    AppProvider provider,
  ) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTabIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.grey[400],
                  size: 22,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
