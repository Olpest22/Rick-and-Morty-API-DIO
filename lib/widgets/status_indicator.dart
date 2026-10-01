import 'package:flutter/material.dart';

import '../data/models/character.dart';

/// Цветная точка статуса и подпись: «● Жив — Human».
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status, this.species});

  final CharacterStatus status;
  final String? species;

  static Color colorOf(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.alive:
        return Colors.green;
      case CharacterStatus.dead:
        return Colors.red;
      case CharacterStatus.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = species == null || species!.isEmpty
        ? status.label
        : '${status.label} — $species';

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colorOf(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
