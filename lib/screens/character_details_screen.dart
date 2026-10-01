import 'package:flutter/material.dart';

import '../data/models/character.dart';
import '../widgets/character_image.dart';
import '../widgets/status_indicator.dart';

/// Подробная информация о персонаже. Данные уже загружены
/// на главном экране, поэтому повторный запрос не нужен.
class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({super.key, required this.character});

  final Character character;

  /// Ширина, начиная с которой фото и данные выводятся рядом.
  static const _wideLayoutBreakpoint = 720.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: CharacterImage(
                imageUrl: character.imageUrl,
                heroTag: 'character-${character.id}',
              ),
            ),
          );
          final info = _CharacterInfo(character: character);

          if (constraints.maxWidth >= _wideLayoutBreakpoint) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: image),
                  const SizedBox(width: 24),
                  Expanded(child: info),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: image,
                ),
                const SizedBox(height: 16),
                info,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CharacterInfo extends StatelessWidget {
  const _CharacterInfo({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(character.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        StatusIndicator(status: character.status, species: character.species),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.category_outlined,
                label: 'Вид',
                value: character.species,
              ),
              if (character.type.isNotEmpty)
                _InfoTile(
                  icon: Icons.science_outlined,
                  label: 'Подвид',
                  value: character.type,
                ),
              _InfoTile(
                icon: Icons.wc_outlined,
                label: 'Пол',
                value: character.gender.label,
              ),
              _InfoTile(
                icon: Icons.public_outlined,
                label: 'Происхождение',
                value: character.originName,
              ),
              _InfoTile(
                icon: Icons.place_outlined,
                label: 'Последнее местоположение',
                value: character.locationName,
              ),
              _InfoTile(
                icon: Icons.movie_outlined,
                label: 'Эпизодов с персонажем',
                value: '${character.episodeCount}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}
