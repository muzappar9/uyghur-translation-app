import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CameraButton: 相机/OCR按钮组件
class CameraButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isProcessing;
  final double size;
  final Color? color;

  const CameraButton({
    super.key,
    this.onTap,
    this.isProcessing = false,
    this.size = 64,
    this.color,
  });

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: widget.isProcessing
                        ? SizedBox(
                            width: widget.size * 0.4,
                            height: widget.size * 0.4,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: widget.size * 0.5,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ImagePreviewCard: 图片预览卡片
class ImagePreviewCard extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final bool showRemoveButton;
  final bool isLoading;

  const ImagePreviewCard({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.onRemove,
    this.onTap,
    this.height = 200,
    this.borderRadius = 16,
    this.showRemoveButton = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 图片
              if (imageFile != null)
                Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                )
              else if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        color: theme.hintColor,
                        size: 48,
                      ),
                    );
                  },
                )
              else
                Container(
                  color: theme.cardColor,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: theme.hintColor,
                      size: 48,
                    ),
                  ),
                ),

              // 加载遮罩
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),

              // 删除按钮
              if (showRemoveButton && (imageFile != null || imageUrl != null))
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRemove?.call();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ImagePickerButtons: 图片选择按钮组
class ImagePickerButtons extends StatelessWidget {
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;
  final bool isLoading;
  final double spacing;

  const ImagePickerButtons({
    super.key,
    this.onCameraTap,
    this.onGalleryTap,
    this.isLoading = false,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          context: context,
          icon: Icons.camera_alt,
          label: '拍照',
          onTap: isLoading ? null : onCameraTap,
          color: const Color(0xFF4CAF50),
        ),
        SizedBox(width: spacing),
        _buildButton(
          context: context,
          icon: Icons.photo_library,
          label: '相册',
          onTap: isLoading ? null : onGalleryTap,
          color: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ??
              Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color?.withValues(alpha: 0.3) ??
                Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OcrTextOverlay: OCR文字识别结果覆盖层
class OcrTextOverlay extends StatelessWidget {
  final List<OcrTextBlock> textBlocks;
  final Size imageSize;
  final bool showBoundingBoxes;
  final Color boxColor;
  final VoidCallback? onBlockTap;

  const OcrTextOverlay({
    super.key,
    required this.textBlocks,
    required this.imageSize,
    this.showBoundingBoxes = true,
    this.boxColor = Colors.blue,
    this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / imageSize.width;
        final scaleY = constraints.maxHeight / imageSize.height;

        return Stack(
          children: textBlocks.map((block) {
            return Positioned(
              left: block.rect.left * scaleX,
              top: block.rect.top * scaleY,
              width: block.rect.width * scaleX,
              height: block.rect.height * scaleY,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onBlockTap?.call();
                },
                child: Container(
                  decoration: showBoundingBoxes
                      ? BoxDecoration(
                          border: Border.all(
                            color: boxColor.withValues(alpha: 0.7),
                            width: 2,
                          ),
                          color: boxColor.withValues(alpha: 0.1),
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// OCR文本块数据类
class OcrTextBlock {
  final String text;
  final Rect rect;
  final double confidence;

  const OcrTextBlock({
    required this.text,
    required this.rect,
    this.confidence = 1.0,
  });
}

/// OcrResultCard: OCR识别结果卡片
class OcrResultCard extends StatelessWidget {
  final String recognizedText;
  final VoidCallback? onCopy;
  final VoidCallback? onTranslate;
  final VoidCallback? onShare;
  final bool isLoading;

  const OcrResultCard({
    super.key,
    required this.recognizedText,
    this.onCopy,
    this.onTranslate,
    this.onShare,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '识别结果',
                style: TextStyle(
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 识别文字
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              recognizedText.isEmpty ? '暂无识别结果' : recognizedText,
              style: TextStyle(
                fontSize: 16,
                color: recognizedText.isEmpty
                    ? theme.hintColor
                    : theme.textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
          ),

          if (recognizedText.isNotEmpty) ...[
            const SizedBox(height: 12),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.copy,
                  label: '复制',
                  onTap: onCopy,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.translate,
                  label: '翻译',
                  onTap: onTranslate,
                  isPrimary: true,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.share,
                  label: '分享',
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPrimary ? theme.colorScheme.primary : theme.hintColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
