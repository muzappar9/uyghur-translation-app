import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_states.dart';
import '../i18n/localizations.dart';

/// CameraScreen: 相机页（增强版）
/// 支持拍照取词、相册选择和OCR识别
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _recognizedText = '';
  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _flashMode = 0; // 0: auto, 1: on, 2: off

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _recognizedText = '';
        });
        await _recognizeText();
      }
    } on PlatformException catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage =
            '无法访问${source == ImageSource.camera ? '相机' : '相册'}: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '选择图片失败: $e';
      });
    }
  }

  Future<void> _recognizeText() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _hasError = false;
    });

    try {
      // 模拟OCR识别过程
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _recognizedText = '这是一段模拟的识别文本。\n\n'
            '在实际应用中，这里将显示从图片中识别出的文字内容。\n\n'
            '支持中文、英文和维吾尔文的识别。';
        _isProcessing = false;
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '文字识别失败: $e';
        _isProcessing = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _recognizedText = '';
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _copyText() {
    if (_recognizedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _recognizedText));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _translateText() {
    if (_recognizedText.isEmpty) return;
    Navigator.pushNamed(context, '/translate_result', arguments: {
      'text': _recognizedText,
      'source': 'auto',
      'target': 'ug',
    });
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = (_flashMode + 1) % 3;
    });
    final modes = ['自动', '开启', '关闭'];
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('闪光灯: ${modes[_flashMode]}'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case 1:
        return Icons.flash_on;
      case 2:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF8BC34A),
              Color(0xFFCDDC39),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // AppBar
                _buildAppBar(),

                // 主内容区
                Expanded(
                  child: _selectedImage != null
                      ? _buildResultView()
                      : _buildCameraPreview(),
                ),

                // 底部按钮
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            t(context, 'camera.title'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (_selectedImage != null)
            IconButton(
              onPressed: _clearImage,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: '重新选择',
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.document_scanner,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  t(context, 'camera.hint'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '支持中/英/维吾尔文识别',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 图片预览
          LoadingOverlay(
            isLoading: _isProcessing,
            message: '正在识别文字...',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 识别结果
          GlassCard(
            blurSigma: 15,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '识别结果',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (_isProcessing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isProcessing
                      ? const Center(child: LoadingDots(color: Colors.white))
                      : SelectableText(
                          _recognizedText.isEmpty ? '暂无识别结果' : _recognizedText,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.5,
                          ),
                        ),
                ),
                if (_recognizedText.isNotEmpty && !_isProcessing) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionChip(
                          icon: Icons.copy, label: '复制', onTap: _copyText),
                      const SizedBox(width: 8),
                      _ActionChip(
                          icon: Icons.translate,
                          label: '翻译',
                          onTap: _translateText,
                          isPrimary: true),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 错误提示
          if (_hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GlassCard(
                blurSigma: 15,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.orangeAccent),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_errorMessage,
                            style: const TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GlassButton(
            text: t(context, 'camera.button.gallery'),
            icon: Icons.photo_library,
            onPressed: () => _pickImage(ImageSource.gallery),
            textColor: Colors.white,
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _pickImage(ImageSource.camera),
                borderRadius: BorderRadius.circular(40),
                child: const Center(
                  child: Icon(Icons.camera, size: 36, color: Colors.white),
                ),
              ),
            ),
          ),
          GlassButton(
            text: '',
            icon: _flashIcon,
            iconOnly: true,
            onPressed: _toggleFlash,
            textColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        isPrimary ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 虚线框角落绘制
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;
    const radius = 24.0;

    // 左上角
    final path = Path();
    path.moveTo(0, cornerLength);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(cornerLength, 0);

    // 右上角
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, cornerLength);

    // 右下角
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(size.width - cornerLength, size.height);

    // 左下角
    path.moveTo(cornerLength, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
