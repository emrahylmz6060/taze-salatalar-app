import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../widgets/camera_capture_dialog.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _customNameController = TextEditingController();
  
  String _imageUrl = '';
  String _localFilePath = '';
  String _foodName = '';
  
  bool _isScanning = false;
  bool _hasResult = false;
  
  double _scanProgress = 0.0;
  String _scanStatusText = 'Görüntü analiz ediliyor...';
  Timer? _scanTimer;
  late AnimationController _laserController;

  // Mock Analysis Results
  int _resultCalories = 0;
  double _resultProtein = 0.0;
  double _resultCarbs = 0.0;
  double _resultFat = 0.0;
  List<String> _resultIngredients = [];

  // Sample plates for quick selection
  final List<Map<String, dynamic>> _samplePlates = [
    {
      'name': 'Izgara Somon Salatası',
      'url': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=600&q=80',
      'calories': 380,
      'protein': 32.0,
      'carbs': 12.0,
      'fat': 22.0,
      'ingredients': ['Izgara Somon (150g)', 'Karışık Yeşillik (100g)', 'Avokado (50g)', 'Zeytinyağı Sos (15ml)', 'Limon Suyu'],
    },
    {
      'name': 'Tavuklu Kinoa Bowl',
      'url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      'calories': 450,
      'protein': 35.0,
      'carbs': 48.0,
      'fat': 14.0,
      'ingredients': ['Izgara Tavuk Göğsü (120g)', 'Haşlanmış Kinoa (80g)', 'Brokoli (50g)', 'Nohut (40g)', 'Tahin Sos (15ml)'],
    },
    {
      'name': 'Meyveli Fit Yulaf Lapası',
      'url': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80',
      'calories': 310,
      'protein': 12.0,
      'carbs': 52.0,
      'fat': 6.0,
      'ingredients': ['Yulaf Ezmesi (50g)', 'Yarım Yağlı Süt (150ml)', 'Çilek & Muz Dilimleri (60g)', 'Çiya Tohumu (10g)', 'Süzme Bal (10g)'],
    },
    {
      'name': 'Avokado Yumurtalı Tost',
      'url': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=600&q=80',
      'calories': 340,
      'protein': 16.0,
      'carbs': 28.0,
      'fat': 18.0,
      'ingredients': ['Ekşi Mayalı Ekmek (1 dilim)', 'Olgun Avokado (60g)', 'Poşe Yumurta (1 adet)', 'Çörek Otu & Pul Biber', 'Zeytinyağı (5ml)'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _customNameController.dispose();
    _scanTimer?.cancel();
    _laserController.dispose();
    super.dispose();
  }

  // Estimate macros logically based on keyword matching
  void _calculateLogicalMacros(String name) {
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains('somon') || lowerName.contains('balık') || lowerName.contains('salmon')) {
      _resultCalories = 390;
      _resultProtein = 28.5;
      _resultCarbs = 4.0;
      _resultFat = 26.0;
      _resultIngredients = ['Izgara Somon Fileto (~150g)', 'Zeytinyağlı Akdeniz Yeşillikleri', 'Çeri Domates', 'Limon Suyu Sos'];
    } else if (lowerName.contains('tavuk') || lowerName.contains('chicken') || lowerName.contains('sezar')) {
      _resultCalories = 420;
      _resultProtein = 34.0;
      _resultCarbs = 18.0;
      _resultFat = 15.0;
      _resultIngredients = ['Izgara Tavuk Fileto (~120g)', 'Göbek Marul (~150g)', 'Kruton Ekmek (~20g)', 'Parmesan Peyniri', 'Sezar Sos (~15g)'];
    } else if (lowerName.contains('yulaf') || lowerName.contains('oat') || lowerName.contains('pancake')) {
      _resultCalories = 320;
      _resultProtein = 11.0;
      _resultCarbs = 54.0;
      _resultFat = 6.5;
      _resultIngredients = ['Yulaf Ezmesi (~50g)', 'Muz & Orman Meyveleri (~80g)', 'Badem Sütü (~150ml)', 'Bal veya Akçaağaç Şurubu'];
    } else if (lowerName.contains('tost') || lowerName.contains('avokado') || lowerName.contains('yumurta')) {
      _resultCalories = 350;
      _resultProtein = 14.5;
      _resultCarbs = 30.0;
      _resultFat = 17.0;
      _resultIngredients = ['Ekşi Mayalı Çavdar Ekmeği', 'Ezilmiş Avokado Sos (~50g)', 'Haşlanmış Yumurta (1 adet)', 'Lor Peyniri (~30g)'];
    } else if (lowerName.contains('makarna') || lowerName.contains('pasta') || lowerName.contains('pizza')) {
      _resultCalories = 540;
      _resultProtein = 16.0;
      _resultCarbs = 78.0;
      _resultFat = 12.0;
      _resultIngredients = ['Durum Buğdayı Makarnası (~100g)', 'Ev Yapımı Fesleğenli Domates Sosu', 'Zeytinyağı (~10ml)', 'Rendelenmiş Kaşar Peyniri'];
    } else {
      // Default fallback logical estimation
      _resultCalories = 290;
      _resultProtein = 12.0;
      _resultCarbs = 35.0;
      _resultFat = 9.0;
      _resultIngredients = ['Karışık Taze Malzemeler (~250g)', 'Doğal Bitkisel Yağlar', 'Baharat & Sos Çeşnileri'];
    }
  }

  void _startAnalysis({
    required String name,
    String imageUrl = '',
    String localFilePath = '',
    Map<String, dynamic>? precalculated,
  }) {
    setState(() {
      _isScanning = true;
      _hasResult = false;
      _scanProgress = 0.0;
      _imageUrl = imageUrl;
      _localFilePath = localFilePath;
      _foodName = name.isNotEmpty ? name : 'Bilinmeyen Yemek';
    });

    _laserController.repeat(reverse: true);

    // Setup phased scanning text statuses
    int phase = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      phase++;
      setState(() {
        _scanProgress = (phase / 3).clamp(0.0, 1.0);
        if (phase == 1) {
          _scanStatusText = 'Malzemeler saptanıyor...';
        } else if (phase == 2) {
          _scanStatusText = 'Kalori ve makrolar hesaplanıyor...';
        } else if (phase >= 3) {
          timer.cancel();
          _laserController.stop();
          _isScanning = false;
          _hasResult = true;
          
          if (precalculated != null) {
            _resultCalories = precalculated['calories'];
            _resultProtein = precalculated['protein'];
            _resultCarbs = precalculated['carbs'];
            _resultFat = precalculated['fat'];
            _resultIngredients = List<String>.from(precalculated['ingredients']);
          } else {
            _calculateLogicalMacros(_foodName);
          }
        }
      });
    });
  }

  void _resetAnalyzer() {
    setState(() {
      _hasResult = false;
      _isScanning = false;
      _imageUrl = '';
      _localFilePath = '';
      _foodName = '';
      _urlController.clear();
      _customNameController.clear();
    });
  }

  Widget _buildImageWidget({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (_localFilePath.isNotEmpty) {
      return Image.file(
        File(_localFilePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else if (_imageUrl.isNotEmpty) {
      return Image.network(
        _imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return const Center(child: Icon(Icons.image, color: Colors.grey));
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
      final String guessedName = 'Fotoğraf ${DateTime.now().hour}:${DateTime.now().minute}';
      _showNameVerificationDialog(guessedName, capturedPath);
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
                'Tabağınızı galeriden seçebilir, kamerayla çekebilir veya bir web adresi girebilirsiniz.',
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
        final path = result.files.single.path!;
        final fileName = result.files.single.name;
        
        String guessedName = fileName;
        final lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex != -1) {
          guessedName = fileName.substring(0, lastDotIndex);
        }
        guessedName = guessedName.replaceAll(RegExp(r'[-_]'), ' ');
        if (guessedName.isNotEmpty) {
          guessedName = guessedName[0].toUpperCase() + guessedName.substring(1);
        }

        _showNameVerificationDialog(guessedName, path);
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

  void _showNameVerificationDialog(String guessedName, String path) {
    _customNameController.text = guessedName;
    final primaryColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.amber),
            SizedBox(width: 8),
            Text('Yemek İsmini Onaylayın'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yapay zekanın doğru analiz yapabilmesi için yemeğin ismini doğrulayın veya düzenleyin:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customNameController,
              decoration: InputDecoration(
                labelText: 'Yemek Adı',
                prefixIcon: const Icon(Icons.fastfood_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.file(File(path), fit: BoxFit.cover),
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
              _startAnalysis(
                name: _customNameController.text.trim().isNotEmpty 
                    ? _customNameController.text.trim() 
                    : 'Özel Tabak',
                localFilePath: path,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tarayıcıyı Başlat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUrlDialog() {
    _customNameController.clear();
    _urlController.clear();
    final primaryColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Görsel URL Girin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customNameController,
              decoration: InputDecoration(
                labelText: 'Yemek Adı (Örn: Tavuklu Salata)',
                prefixIcon: const Icon(Icons.fastfood_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
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
              if (_urlController.text.trim().isNotEmpty) {
                _startAnalysis(
                  name: _customNameController.text.trim(),
                  imageUrl: _urlController.text.trim(),
                );
              } else {
                _startAnalysis(
                  name: _customNameController.text.trim().isNotEmpty 
                      ? _customNameController.text.trim() 
                      : 'Özel Tabak',
                  imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tara', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology_outlined, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Yapay Zeka Besin Analizörü',
              style: TextStyle(
                color: Colors.grey[850],
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isScanning && !_hasResult) _buildSetupView(primaryColor),
                if (_isScanning) _buildScanningView(primaryColor),
                if (_hasResult) _buildResultView(primaryColor),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Initial configuration layout
  Widget _buildSetupView(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tabağını Fotoğrafla ve Öğren! 📸',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.grey[850],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tabağının görselini yükleyerek veya örneklerden seçerek kalori ve makro değerlerini saniyeler içinde analiz et.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 24),

        // Interactive Scan Zone Card
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: _selectImageSource,
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_a_photo_outlined, color: primaryColor, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Görsel Yükle (Cihaz veya URL)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cihazınızdan seçmek veya fotoğraf bağlantısı girmek için tıklayın',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Quick Test Section
        Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              'Hızlı Test: Popüler Tabaklar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemCount: _samplePlates.length,
          itemBuilder: (context, index) {
            final plate = _samplePlates[index];
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _startAnalysis(
                  name: plate['name'],
                  imageUrl: plate['url'],
                  precalculated: plate,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        plate['url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plate['name'],
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey[850]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plate['calories']} kcal',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Scanning / Loading Animation Screen
  Widget _buildScanningView(Color primaryColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Analiz Ediliyor...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey[800]),
          ),
          const SizedBox(height: 16),
          
          // Image scanning area with scanner laser effect
          Container(
            width: 280,
            height: 280,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Display the scanned image blur-faded
                Positioned.fill(
                  child: _buildImageWidget(),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
                // Cyan laser scanning line animation
                AnimatedBuilder(
                  animation: _laserController,
                  builder: (context, child) {
                    final double topOffset = _laserController.value * 280;
                    return Positioned(
                      top: topOffset,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Scanner text phase and progress bar
          Text(
            _scanStatusText,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 220,
              height: 10,
              child: LinearProgressIndicator(
                value: _scanProgress,
                backgroundColor: Colors.grey[200],
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Scanner analysis result panel
  Widget _buildResultView(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analiz Sonucu 🍽️',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.grey[850],
                letterSpacing: -0.5,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _resetAnalyzer,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Scanned Plate Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImageWidget(
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _foodName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey[850]),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Yapay Zeka Tespiti',
                            style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Macro Details Gauge & Progress Indicators
              Row(
                children: [
                  // Circular Calories ring
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 8,
                                backgroundColor: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                                color: primaryColor,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_resultCalories',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: Colors.grey[850],
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tahmini Kalori',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Macronutrient Progress Cards
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        _buildMacroBadge('Protein', '${_resultProtein.toStringAsFixed(1)}g', const Color(0xFF0D9488)),
                        const SizedBox(height: 8),
                        _buildMacroBadge('Karbonhidrat', '${_resultCarbs.toStringAsFixed(1)}g', const Color(0xFFD97706)),
                        const SizedBox(height: 8),
                        _buildMacroBadge('Yağ', '${_resultFat.toStringAsFixed(1)}g', const Color(0xFFDB2777)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredient List
              Text(
                'Saptanan Malzemeler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 10),
              ..._resultIngredients.map((ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      ingredient,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Log eaten meal to daily totals
                    Provider.of<AppProvider>(context, listen: false).addEatenMeal(
                      _resultCalories,
                      _resultProtein,
                      _resultCarbs,
                      _resultFat,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Afiyet olsun! $_resultCalories kcal günlük özete kaydedildi.'),
                        backgroundColor: primaryColor,
                      ),
                    );
                    _resetAnalyzer();
                  },
                  icon: const Icon(Icons.restaurant, color: Colors.white),
                  label: const Text('Günlüğüme Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _resetAnalyzer,
                  icon: Icon(Icons.refresh, color: primaryColor),
                  label: Text('Yeni Analiz', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroBadge(String name, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
