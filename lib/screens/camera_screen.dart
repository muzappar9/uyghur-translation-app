import 'package:flutter/material.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';

/// CameraScreen: 相机页
/// 标题 + Container占位预览 + 底部拍照/相册按钮
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

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
              Color(0xFFFF6B6B),
              Color(0xFFFF8E53),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Camera Preview Placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DashedBorderPainter(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t(context, 'camera.hint'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    GlassButton(
                      text: t(context, 'camera.button.gallery'),
                      icon: Icons.photo_library,
                      onPressed: () {
                        // TODO: 打开相册
                        Navigator.pushNamed(context, '/ocr_result');
                      },
                      textColor: Colors.white,
                    ),
                    
                    // Capture Button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: 拍照
                            Navigator.pushNamed(context, '/ocr_result');
                          },
                          borderRadius: BorderRadius.circular(40),
                          child: const Center(
                            child: Icon(
                              Icons.camera,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Flash Button
                    GlassButton(
                      text: '',
                      icon: Icons.flash_auto,
                      iconOnly: true,
                      onPressed: () {
                        // TODO: 闪光灯切换
                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      ..color = Colors.white.withOpacity(0.6)
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
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
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
