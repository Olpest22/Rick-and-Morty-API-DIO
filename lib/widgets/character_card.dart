import 'package:flutter/material.dart';

import '../data/models/character.dart';
import 'character_image.dart';
import 'status_indicator.dart';

/// Карточка персонажа в списке: фото, имя, статус, вид и место.
class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character, required this.onTap});

  static const imageWidth = 120.0;

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: imageWidth,
              child: CharacterImage(
                imageUrl: character.imageUrl,
                heroTag: 'character-${character.id}',
                decodeWidth: imageWidth,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    StatusIndicator(
                      status: character.status,
                      species: character.species,
                    ),
                    const Spacer(),
                    Text(
                      'Последнее местоположение',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      character.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
