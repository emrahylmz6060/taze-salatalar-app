import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/salad_model.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _calories = '';
  String _time = '';
  String _ingredients = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newSalad = SaladModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        ingredients: _ingredients.split(',').map((e) => e.trim()).toList(),
        steps: ['Malzemeleri doğrayın.', 'Bir kasede harmanlayıp soslayın.'], // Default steps for brevity
        preparationTime: '$_time dk',
        calories: int.tryParse(_calories) ?? 200,
        tags: ['Kendi Tarifim', 'Yeni'],
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80', // Fallback image for custom
      );

      Provider.of<AppProvider>(context, listen: false).addRecipe(newSalad);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarif başarıyla eklendi!')),
      );
      
      _formKey.currentState!.reset();
    }
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Malzemeler (Virgülle ayırın)',
                icon: Icons.list_alt,
                maxLines: 3,
                onSaved: (val) => _ingredients = val!,
                validator: (val) => val!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Tarifi Kaydet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
