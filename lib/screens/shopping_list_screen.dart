import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  void _addItem(AppProvider appProvider) {
    final text = _itemController.text.trim();
    if (text.isNotEmpty) {
      appProvider.addCustomShoppingItem(text);
      _itemController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final shoppingItems = appProvider.shoppingItems;
    final primaryColor = Theme.of(context).primaryColor;

    final List<String> itemList = shoppingItems.keys.toList();
    final totalCount = itemList.length;
    final checkedCount = shoppingItems.values.where((v) => v == true).length;
    final double completionPercent = totalCount > 0 ? checkedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alışveriş Listesi',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Tarif malzemelerini buradan takip et',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          if (itemList.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Listeyi Temizle'),
                    content: const Text('Alışveriş listenizdeki tüm malzemeleri silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          appProvider.clearShoppingList();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              label: const Text('Temizle', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Custom Item Add Field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
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
                          controller: _itemController,
                          decoration: InputDecoration(
                            hintText: 'Listeye özel malzeme ekle...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _addItem(appProvider),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _addItem(appProvider),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator Bar
              if (itemList.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16, top: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alışveriş İlerlemesi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '$checkedCount / $totalCount tamamlandı (%${(completionPercent * 100).toInt()})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: completionPercent,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Checklist Items
              Expanded(
                child: itemList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Alışveriş listeniz boş.',
                              style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bir tarif detayındaki "Malzemeleri Ekle" butonuna basarak\nveya yukarıdan kendiniz ekleyerek başlayabilirsiniz.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          final item = itemList[index];
                          final isChecked = shoppingItems[item] ?? false;

                          return Dismissible(
                            key: Key(item),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            ),
                            onDismissed: (_) {
                              appProvider.removeShoppingItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"$item" listeden silindi.'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Geri Al',
                                    textColor: primaryColor,
                                    onPressed: () {
                                      appProvider.addCustomShoppingItem(item);
                                      if (isChecked) {
                                        appProvider.toggleShoppingItem(item);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isChecked ? Colors.grey[100]! : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isChecked 
                                          ? Colors.transparent 
                                          : Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    appProvider.toggleShoppingItem(item);
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      children: [
                                        // Custom animated checkbox
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isChecked ? primaryColor : Colors.transparent,
                                            border: Border.all(
                                              color: isChecked ? primaryColor : Colors.grey[350]!,
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: isChecked
                                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              decoration: isChecked ? TextDecoration.lineThrough : null,
                                              color: isChecked ? Colors.grey[400] : Colors.grey[800],
                                              fontWeight: isChecked ? FontWeight.normal : FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[300]),
                                          onPressed: () {
                                            appProvider.removeShoppingItem(item);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
