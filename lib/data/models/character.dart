/// Статус персонажа. API возвращает «Alive», «Dead» или «unknown».
enum CharacterStatus {
  alive('alive', 'Жив'),
  dead('dead', 'Мёртв'),
  unknown('unknown', 'Неизвестно');

  const CharacterStatus(this.apiValue, this.label);

  /// Значение для параметра запроса `status`.
  final String apiValue;

  /// Подпись для интерфейса.
  final String label;

  static CharacterStatus fromApi(String? value) {
    final normalized = value?.toLowerCase();
    return values.firstWhere(
      (status) => status.apiValue == normalized,
      orElse: () => CharacterStatus.unknown,
    );
  }
}

/// Пол персонажа. API возвращает «Female», «Male», «Genderless» или «unknown».
enum CharacterGender {
  female('female', 'Женский'),
  male('male', 'Мужской'),
  genderless('genderless', 'Отсутствует'),
  unknown('unknown', 'Неизвестно');

  const CharacterGender(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CharacterGender fromApi(String? value) {
    final normalized = value?.toLowerCase();
    return values.firstWhere(
      (gender) => gender.apiValue == normalized,
      orElse: () => CharacterGender.unknown,
    );
  }
}

/// Персонаж из ответа `GET /character`.
///
/// Парсинг ручной: структура JSON простая, а генерация кода
/// (json_serializable) потребовала бы build_runner без реальной пользы.
/// Из вложенных объектов берём только нужные поля, а из списка эпизодов —
/// только количество, не создавая лишних объектов.
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.imageUrl,
    required this.episodeCount,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: CharacterStatus.fromApi(json['status'] as String?),
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: CharacterGender.fromApi(json['gender'] as String?),
      originName: _nestedName(json['origin']),
      locationName: _nestedName(json['location']),
      imageUrl: json['image'] as String,
      episodeCount: (json['episode'] as List<dynamic>?)?.length ?? 0,
    );
  }

  final int id;
  final String name;
  final CharacterStatus status;
  final String species;

  /// Подвид персонажа, часто пустая строка.
  final String type;
  final CharacterGender gender;
  final String originName;
  final String locationName;
  final String imageUrl;
  final int episodeCount;

  /// Достаёт поле `name` из вложенного объекта вида {"name": ..., "url": ...}.
  static String _nestedName(Object? json) {
    if (json is Map<String, dynamic>) {
      return json['name'] as String? ?? 'unknown';
    }
    return 'unknown';
  }
}
