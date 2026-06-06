import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppImagePreviewList extends StatelessWidget {
  const AppImagePreviewList({
    super.key,
    required this.imagePaths,
    this.height = 92,
    this.imageSize = 92,
    this.spacing = 10,
    this.borderRadius = 14,
    this.canRemove = false,
    this.onRemove,
    this.emptyText = 'No image added yet.',
  });

  final List<String> imagePaths;
  final double height;
  final double imageSize;
  final double spacing;
  final double borderRadius;
  final bool canRemove;
  final ValueChanged<int>? onRemove;
  final String emptyText;

  bool _isNetworkImage(String imagePath) {
    return imagePath.startsWith('http://') ||
        imagePath.startsWith('https://') ||
        imagePath.startsWith('blob:');
  }

  bool _isLocalFile(String imagePath) {
    return imagePath.trim().isNotEmpty && !_isNetworkImage(imagePath);
  }

  void _openImagePreview(BuildContext context, String imagePath) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 4,
              child: Container(
                color: Colors.black,
                child: _PreviewImage(
                  imagePath: imagePath,
                  isNetworkImage: _isNetworkImage(imagePath),
                  isLocalFile: _isLocalFile(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (imagePaths.isEmpty) {
      return Text(
        emptyText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (BuildContext context, int index) {
          final String imagePath = imagePaths[index];

          return Stack(
            children: [
              InkWell(
                onTap: () => _openImagePreview(context, imagePath),
                borderRadius: BorderRadius.circular(borderRadius),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: SizedBox(
                    height: imageSize,
                    width: imageSize,
                    child: _PreviewImage(
                      imagePath: imagePath,
                      isNetworkImage: _isNetworkImage(imagePath),
                      isLocalFile: _isLocalFile(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (canRemove && onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => onRemove!(index),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.imagePath,
    required this.isNetworkImage,
    required this.isLocalFile,
    required this.fit,
  });

  final String imagePath;
  final bool isNetworkImage;
  final bool isLocalFile;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) {
      return const _ImageErrorBox();
    }

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return const _ImageErrorBox();
        },
      );
    }

    /*
      Flutter Web does not support Image.file.

      On web, image_picker may return a blob/local-style path.
      In that case, we try to render it with Image.network instead of Image.file.
    */
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return const _ImageErrorBox();
        },
      );
    }

    if (isLocalFile) {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (_, __, ___) {
          return const _ImageErrorBox();
        },
      );
    }

    return const _ImageErrorBox();
  }
}

class _ImageErrorBox extends StatelessWidget {
  const _ImageErrorBox();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Icon(
        Icons.broken_image_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}