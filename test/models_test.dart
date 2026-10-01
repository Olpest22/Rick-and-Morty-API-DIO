import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_characters/data/models/character.dart';
import 'package:rick_morty_characters/data/models/characters_page.dart';

import 'fixtures.dart';

void main() {
  test('страница персонажей парсится из JSON', () {
    final page = CharactersPage.fromJson(sampleCharactersResponse);

    expect(page.info.count, 826);
    expect(page.info.hasNextPage, isTrue);
    expect(page.results, hasLength(2));

    final rick = page.results.first;
    expect(rick.id, 1);
    expect(rick.name, 'Rick Sanchez');
    expect(rick.status, CharacterStatus.alive);
    expect(rick.gender, CharacterGender.male);
    expect(rick.originName, 'Earth (C-137)');
    expect(rick.locationName, 'Citadel of Ricks');
    expect(rick.episodeCount, 2);
    expect(page.results.last.status, CharacterStatus.dead);
  });

  test('неизвестные значения статуса и пола не ломают парсинг', () {
    expect(CharacterStatus.fromApi('something'), CharacterStatus.unknown);
    expect(CharacterStatus.fromApi(null), CharacterStatus.unknown);
    expect(CharacterGender.fromApi('Genderless'), CharacterGender.genderless);
  });
}
