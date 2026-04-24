import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/salad_model.dart';
import '../widgets/salad_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTag = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final allSalads = appProvider.allSalads;

    // Extract tags
    final tagsSet = <String>{};
    for (var salad in allSalads) {
      tagsSet.addAll(salad.tags);
    }
    final List<String> tags = ['Tümü', ...tagsSet.toList()..sort()];

    // Filter salads
    List<SaladModel> filteredSalads;
    if (_selectedTag == 'Tümü') {
      filteredSalads = allSalads;
    } else {
      filteredSalads = allSalads.where((salad) => salad.tags.contains(_selectedTag)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taze Salatalar',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Sağlıklı ve lezzetli tarifler keşfet',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags Filter
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = tag == _selectedTag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),
          // Salad List
          Expanded(
            child: filteredSalads.isEmpty
                ? Center(
                    child: Text(
                      'Bu kategoriye ait salata bulunamadı.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
          ),
        ],
      ),
    );
  }
}
