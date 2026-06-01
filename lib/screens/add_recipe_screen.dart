import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../models/salad_model.dart';
import '../services/recipe_api_service.dart';
import '../widgets/camera_capture_dialog.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  String _name = '';
  String _calories = '';
  String _time = '';
  String _ingredients = '';
  String _protein = '';
  String _carbs = '';
  String _fat = '';
  String _imageUrl = '';
  String _localFilePath = '';

  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(() {
      setState(() {
        _imageUrl = _imageUrlController.text;
        if (_imageUrl.isNotEmpty) {
          _localFilePath = '';
        }
      });
    });
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final List<String> ingredientList = _ingredients.split(',').map((e) => e.trim()).toList();
      final estimatedMacros = RecipeApiService.estimateNutrition(ingredientList);

      final double finalProtein = double.tryParse(_protein) ?? estimatedMacros['protein'] ?? 0.0;
      final double finalCarbs = double.tryParse(_carbs) ?? estimatedMacros['carbs'] ?? 0.0;
      final double finalFat = double.tryParse(_fat) ?? estimatedMacros['fat'] ?? 0.0;

      final newSalad = SaladModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        ingredients: ingredientList,
        steps: ['Malzemeleri doğrayın.', 'Bir kasede harmanlayıp soslayın.'], // Default steps for brevity
        preparationTime: '$_time dk',
        calories: int.tryParse(_calories) ?? (estimatedMacros['calories']?.toInt() ?? 200),
        tags: ['Kendi Tarifim', 'Yeni'],
        imageUrl: _localFilePath.isNotEmpty
            ? _localFilePath
            : (_imageUrl.trim().isNotEmpty 
                ? _imageUrl.trim() 
                : 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80'),
        protein: finalProtein,
        carbs: finalCarbs,
        fat: finalFat,
      );

      Provider.of<AppProvider>(context, listen: false).addRecipe(newSalad);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarif başarıyla eklendi!')),
      );
      
      _formKey.currentState!.reset();
      _imageUrlController.clear();
      setState(() {
        _localFilePath = '';
      });
      Navigator.pop(context);
    }
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureLivePhoto() async {
    final String? capturedPath = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CameraCaptureDialog(),
    );

    if (capturedPath != null && capturedPath.isNotEmpty) {
      setState(() {
        _localFilePath = capturedPath;
        _imageUrlController.clear();
        _imageUrl = '';
      });
    }
  }

  void _selectImageSource() {
    final primaryColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Görsel Kaynağı Seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[850],
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tarifiniz için cihazınızdan bir görsel seçebilir, kamerayla çekebilir veya web adresi girebilirsiniz.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildSourceCard(
                    icon: Icons.photo_library_outlined,
                    title: 'Cihazdan Seç',
                    color: primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _pickLocalImage();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildSourceCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Fotoğraf Çek',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _captureLivePhoto();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildSourceCard(
                    icon: Icons.link_rounded,
                    title: 'Görsel URL Gir',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.pop(context);
                      _showUrlDialog();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLocalImage() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _localFilePath = result.files.single.path!;
          _imageUrlController.clear();
          _imageUrl = '';
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görsel seçilirken bir hata oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showUrlDialog() {
    final primaryColor = Theme.of(context).primaryColor;
    final dialogUrlController = TextEditingController(text: _imageUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Görsel URL Girin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dialogUrlController,
              decoration: InputDecoration(
                labelText: 'Görsel Bağlantısı (URL)',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _localFilePath = '';
                _imageUrlController.text = dialogUrlController.text.trim();
                _imageUrl = dialogUrlController.text.trim();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tamam', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarif Ekle',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Kendi sağlıklı salatanı oluştur',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Tarif Detayları
              _buildFormSectionCard(
                title: 'Tarif Detayları',
                icon: Icons.restaurant_menu_rounded,
                children: [
                  _buildTextField(
                    label: 'Tarif Adı',
                    icon: Icons.fastfood_outlined,
                    onSaved: (val) => _name = val!,
                    validator: (val) => val!.isEmpty ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Kalori (kcal)',
                          icon: Icons.local_fire_department_outlined,
                          keyboardType: TextInputType.number,
                          onSaved: (val) => _calories = val!,
                          validator: (val) => val!.isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Süre (dk)',
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                          onSaved: (val) => _time = val!,
                          validator: (val) => val!.isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card 2: Makro Besin Değerleri
              _buildFormSectionCard(
                title: 'Makro Besin Değerleri',
                icon: Icons.pie_chart_rounded,
                subtitle: 'İsteğe bağlı (Boş bırakırsanız tahmini hesaplanır)',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Protein (g)',
                          icon: Icons.spa_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => _protein = val!,
                          validator: (val) => null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          label: 'Karb (g)',
                          icon: Icons.restaurant_menu_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => _carbs = val!,
                          validator: (val) => null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          label: 'Yağ (g)',
                          icon: Icons.opacity_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => _fat = val!,
                          validator: (val) => null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card 2.5: Görsel Seçimi
              _buildFormSectionCard(
                title: 'Görsel Seçimi (Opsiyonel)',
                icon: Icons.image_outlined,
                subtitle: 'Tarifinize bir görsel ekleyin veya hazır şablonlardan birini seçin',
                children: [
                  const Text(
                    'Hazır Şablonlar:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildImageTemplateTile(
                          'Yeşil Akdeniz',
                          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
                        ),
                        _buildImageTemplateTile(
                          'Meyveli Yulaf',
                          'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
                        ),
                        _buildImageTemplateTile(
                          'Tavuklu Sezar',
                          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=80',
                        ),
                        _buildImageTemplateTile(
                          'Renkli Bowl',
                          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _localFilePath.isEmpty && _imageUrl.trim().isEmpty
                      ? InkWell(
                          onTap: _selectImageSource,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAF9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add_a_photo_outlined, size: 28, color: Theme.of(context).primaryColor),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Görsel Seç (Cihaz veya URL)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cihazınızdan seçmek veya fotoğraf bağlantısı girmek için tıklayın',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            color: const Color(0xFFF0F4F1),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _localFilePath.isNotEmpty
                                    ? Image.file(
                                        File(_localFilePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        _imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image_outlined, size: 40, color: Colors.redAccent),
                                              SizedBox(height: 8),
                                              Text('Geçersiz görsel URL\'si', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                                    radius: 18,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          _localFilePath = '';
                                          _imageUrlController.clear();
                                          _imageUrl = '';
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _localFilePath.isNotEmpty ? 'Cihazdan Seçildi' : 'Web Görseli',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _selectImageSource,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Değiştir',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 20),

              // Card 3: Malzemeler
              _buildFormSectionCard(
                title: 'Malzemeler',
                icon: Icons.list_alt_rounded,
                subtitle: 'Malzemeleri virgülle ayırarak yazın (örn: Marul, Domates, Zeytinyağı)',
                children: [
                  _buildTextField(
                    label: 'Malzemeler',
                    icon: Icons.list,
                    maxLines: 3,
                    onSaved: (val) => _ingredients = val!,
                    validator: (val) => val!.isEmpty ? 'Gerekli' : null,
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Tarifi Kaydet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: const Color(0xFFF9FAF9),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildImageTemplateTile(String label, String url) {
    final isSelected = _imageUrl == url && _localFilePath.isEmpty;
    return GestureDetector(
      onTap: () {
        setState(() {
          _localFilePath = '';
          _imageUrlController.text = url;
          _imageUrl = url;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(url, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.35)),
              Center(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
