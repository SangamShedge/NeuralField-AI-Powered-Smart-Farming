// lib/screens/pest_detection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';

// Red Theme Constants for Pest Detection
class RedTheme {
  static const Color primary = Color(0xFFF44336);      // Main Red
  static const Color primaryLight = Color(0xFFFFEBEE); // Light Red BG
  static const Color primaryDark = Color(0xFFD32F2F);  // Dark Red
  static const Color accent = Color(0xFFFFCDD2);       // Accent Red
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color textDark = Color(0xFF2C3E2B);     // Dark Text
  static const Color textLight = Color(0xFF4A5B49);    // Light Text
  static const Color gradientStart = Color(0xFFFFEBEE);
  static const Color gradientEnd = Color(0xFFFFCDD2);
}

class PestDetectionScreen extends StatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  State<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends State<PestDetectionScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts();
  final PestDetectionService _pestService = PestDetectionService();

  XFile? _selectedImage;
  bool _isAnalyzing = false;
  String? _detectionResult;
  String? _confidence;
  String? _solution;
  List<String> _preventionTips = [];
  String? _errorMessage;
  String? _severity;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    _pestService.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakResult(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _detectionResult = null;
          _confidence = null;
          _solution = null;
          _preventionTips = [];
          _errorMessage = null;
          _severity = null;
          _isAnalyzing = false;
        });
        _animationController.forward();
        _analyzeImage();
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      _showErrorSnackBar('${localizations.errorPickingImage} $e');
    }
  }

  void _showImageSourceDialog() {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
              ListTile(
                leading: const Icon(Icons.camera_alt, color: RedTheme.primary),
                title: Text(localizations.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: RedTheme.primary),
              title: Text(localizations.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final File imageFile = File(_selectedImage!.path);

      final response = await _pestService.detectPest(imageFile);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final data = response.data!;

        setState(() {
          _isAnalyzing = false;
          _detectionResult = data.displayName;
          _confidence = data.confidencePercentage;
          _solution = data.getSolution();
          _preventionTips = data.getPreventionTips();
          _severity = data.getSeverity();
        });

        await _speakResult('Detected ${data.displayName} with ${data.confidencePercentage} confidence. ${data.getSolution()}');
      } else {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = response.message;
        });
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      print('Error analyzing image: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _isAnalyzing = false;
          _errorMessage = localizations.failedToAnalyzeImage;
        });
        _showErrorSnackBar(localizations.failedToAnalyzeImageShort);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RedTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resetDetection() async {
    setState(() {
      _selectedImage = null;
      _detectionResult = null;
      _confidence = null;
      _solution = null;
      _preventionTips = [];
      _errorMessage = null;
      _severity = null;
      _isAnalyzing = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: Text(
          localizations.pestDetectionAppBarTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: RedTheme.textDark),
        ),
        backgroundColor: const Color(0xFFF5F7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RedTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: RedTheme.primary),
              onPressed: _resetDetection,
              tooltip: localizations.newDetectionTooltip,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- CLOSEST CHANGE: Center the AI card -----
            Center(
              child: _buildAIRecommendationCard(),
            ),
            const SizedBox(height: 16),

            // Image Selection Area
            Container(
              height: 280,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: _selectedImage == null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(localizations.uploadOrTakePhoto, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(localizations.ofAffectedCropForAnalysis, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                          _buildImageOptionButton(
                            icon: Icons.camera_alt,
                            label: localizations.camera,
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        _buildImageOptionButton(
                          icon: Icons.photo_library,
                          label: localizations.gallery,
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  ),
                  if (_isAnalyzing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 12),
                            Text(localizations.analyzingImage, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RedTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RedTheme.accent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: RedTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: RedTheme.primaryDark, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Results Section
            if (_detectionResult != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Detection Result Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _severity == 'Severe'
                                  ? Colors.red.shade50
                                  : _severity == 'High'
                                  ? Colors.orange.shade50
                                  : Colors.yellow.shade50,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _severity == 'Severe'
                                ? Colors.red.shade200
                                : _severity == 'High'
                                ? Colors.orange.shade200
                                : Colors.yellow.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _severity == 'Severe'
                                        ? Colors.red.shade100
                                        : _severity == 'High'
                                        ? Colors.orange.shade100
                                        : Colors.yellow.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.science,
                                    color: _severity == 'Severe'
                                        ? Colors.red.shade700
                                        : _severity == 'High'
                                        ? Colors.orange.shade700
                                        : Colors.yellow.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.detectedDiseaseLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _severity == 'Severe'
                                              ? Colors.red.shade700
                                              : _severity == 'High'
                                              ? Colors.orange.shade700
                                              : Colors.yellow.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _detectionResult!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_confidence != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _severity == 'Severe'
                                          ? Colors.red.shade100
                                          : _severity == 'High'
                                          ? Colors.orange.shade100
                                          : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _confidence!,
                                      style: TextStyle(
                                        color: _severity == 'Severe'
                                            ? Colors.red.shade800
                                            : _severity == 'High'
                                            ? Colors.orange.shade800
                                            : Colors.green.shade800,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (_severity != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 16,
                                      color: _severity == 'Severe'
                                          ? Colors.red.shade700
                                          : _severity == 'High'
                                          ? Colors.orange.shade700
                                          : Colors.yellow.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${localizations.severityLabelPDS} $_severity',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _severity == 'Severe'
                                            ? Colors.red.shade700
                                            : _severity == 'High'
                                            ? Colors.orange.shade700
                                            : Colors.yellow.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Solution Card
                      if (_solution != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RedTheme.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: RedTheme.accent, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.medication, color: RedTheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      localizations.recommendedSolutionTitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: RedTheme.primary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _speakResult(_solution!),
                                    icon: Icon(Icons.volume_up, size: 20, color: RedTheme.primary),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _solution!,
                                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Prevention Tips Card
                      if (_preventionTips.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RedTheme.gradientStart,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: RedTheme.accent, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.shield, color: RedTheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.preventionTipsTitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: RedTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._preventionTips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('•', style: TextStyle(fontSize: 16, color: RedTheme.primary)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationCard() {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [RedTheme.primary, RedTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RedTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.bug_report,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        localizations.aiPoweredBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.smartPestDetectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.smartPestDetectionDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFeatureChip(Icons.speed, localizations.featureFastAnalysis),
                    _buildFeatureChip(Icons.medication, localizations.featureTreatmentPlans),
                    _buildFeatureChip(Icons.volume_up, localizations.featureVoiceOutput),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: RedTheme.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}