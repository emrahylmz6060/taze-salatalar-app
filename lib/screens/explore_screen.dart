import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/salad_model.dart';
import '../widgets/salad_card.dart';
import '../services/recipe_api_service.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isOnlineMode = false;
  bool _isOnlineLoading = false;
  List<SaladModel> _onlineSalads = [];
  String _selectedTag = 'Tümü';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMode(bool online) {
    setState(() {
      _isOnlineMode = online;
      _searchQuery = '';
      _searchController.clear();
      _selectedTag = 'Tümü';
    });
    if (online && _onlineSalads.isEmpty) {
      _searchOnline('');
    }
  }

  Future<void> _searchOnline(String query) async {
    setState(() {
      _isOnlineLoading = true;
    });
    final results = await RecipeApiService.fetchOnlineRecipes(query);
    setState(() {
      _onlineSalads = results;
      _isOnlineLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    // 1. Get recipes based on selected mode
    List<SaladModel> currentRecipes = [];
    if (_isOnlineMode) {
      currentRecipes = _onlineSalads;
    } else {
      currentRecipes = appProvider.allSalads;
    }

    // 2. Extract unique tags
    final tagsSet = <String>{};
    for (var salad in currentRecipes) {
      tagsSet.addAll(salad.tags);
    }
    final List<String> tags = ['Tümü', ...tagsSet.toList()..sort()];

    // 3. Filter recipes
    final String query = _searchQuery.trim().toLowerCase();
    List<SaladModel> filteredSalads = currentRecipes;

    if (_selectedTag != 'Tümü') {
      filteredSalads = filteredSalads.where((salad) => salad.tags.contains(_selectedTag)).toList();
    }

    // Local filtering
    if (!_isOnlineMode && query.isNotEmpty) {
      filteredSalads = filteredSalads.where((salad) {
        final nameMatch = salad.name.toLowerCase().contains(query);
        final ingredientMatch = salad.ingredients.any((ing) => ing.toLowerCase().contains(query));
        final tagMatch = salad.tags.any((tag) => tag.toLowerCase().contains(query));
        return nameMatch || ingredientMatch || tagMatch;
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keşfet',
              style: TextStyle(
                color: Colors.grey[850],
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              _isOnlineMode 
                  ? 'Dünya mutfağından çevrimiçi salatalar'
                  : 'Kayıtlı ve klasik salata tariflerin',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Local vs Online Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleMode(false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isOnlineMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isOnlineMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 18,
                              color: !_isOnlineMode ? primaryColor : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tariflerim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: !_isOnlineMode ? primaryColor : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleMode(true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isOnlineMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isOnlineMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_sync_outlined,
                              size: 18,
                              color: _isOnlineMode ? primaryColor : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Çevrimiçi Ara',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _isOnlineMode ? primaryColor : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  if (_isOnlineMode) {
                    _searchOnline(value);
                  }
                },
                onChanged: (value) {
                  if (!_isOnlineMode) {
                    setState(() {
                      _searchQuery = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: _isOnlineMode 
                      ? 'Çevrimiçi salata ara (İngilizce: salad, chicken, salmon...)'
                      : 'Salata, malzeme veya kategori ara...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                            if (_isOnlineMode) {
                              _searchOnline('');
                            }
                          },
                        )
                      : (_isOnlineMode 
                          ? IconButton(
                              icon: Icon(Icons.arrow_circle_right, color: primaryColor),
                              onPressed: () {
                                _searchOnline(_searchController.text);
                              },
                            )
                          : null),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Tags Filter List (only if not loading)
          if (!_isOnlineLoading)
            Container(
              height: 52,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = tag == _selectedTag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedTag = tag;
                            });
                          }
                        },
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: primaryColor,
                        side: BorderSide(
                          color: isSelected ? primaryColor : Colors.grey[200]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Results List/Grid or Spinner
          Expanded(
            child: _isOnlineLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          'Sağlıklı tarifler yükleniyor...',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : filteredSalads.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Aramanızla eşleşen tarif bulunamadı.',
                              style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            if (_isOnlineMode) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Farklı bir İngilizce terim deneyebilirsiniz (örn: salad, chicken).',
                                style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              ),
                            ]
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final double width = constraints.maxWidth;
                          int crossAxisCount = 1;
                          
                          if (width >= 1100) {
                            crossAxisCount = 3;
                          } else if (width >= 600) {
                            crossAxisCount = 2;
                          }

                          if (crossAxisCount == 1) {
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredSalads.length,
                              itemBuilder: (context, index) {
                                final salad = filteredSalads[index];
                                return SaladCard(
                                  salad: salad,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(salad: salad),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredSalads.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final salad = filteredSalads[index];
                                return SaladCard(
                                  salad: salad,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(salad: salad),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
