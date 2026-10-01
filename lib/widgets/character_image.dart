import 'package:flutter/material.dart';

/// Аватар персонажа из сети с заглушками на время загрузки и при ошибке.
class CharacterImage extends StatelessWidget {
  const CharacterImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.decodeWidth,
  });

  final String imageUrl;
  final Object heroTag;

  /// Ширина декодирования в логических пикселях. Картинки с сервера
  /// 300×300; для маленьких превью декодируем их в меньшем размере,
  /// чтобы экономить память при длинном списке.
  final double? decodeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Hero(
      tag: heroTag,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth:
            decodeWidth == null ? null : (decodeWidth! * pixelRatio).round(),
        // Плавное появление картинки после загрузки.
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: colors.secondaryContainer,
          child: Icon(Icons.broken_image_outlined, color: colors.outline),
        ),
      ),
    );
  }
}
