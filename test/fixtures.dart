/// Пример ответа GET /character (сокращён до двух персонажей).
const Map<String, dynamic> sampleCharactersResponse = {
  'info': {
    'count': 826,
    'pages': 42,
    'next': 'https://rickandmortyapi.com/api/character?page=2',
    'prev': null,
  },
  'results': [
    {
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)', 'url': ''},
      'location': {'name': 'Citadel of Ricks', 'url': ''},
      'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      'episode': [
        'https://rickandmortyapi.com/api/episode/1',
        'https://rickandmortyapi.com/api/episode/2',
      ],
      'url': 'https://rickandmortyapi.com/api/character/1',
      'created': '2017-11-04T18:48:46.250Z',
    },
    {
      'id': 8,
      'name': 'Adjudicator Rick',
      'status': 'Dead',
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': {'name': 'unknown', 'url': ''},
      'location': {'name': 'Citadel of Ricks', 'url': ''},
      'image': 'https://rickandmortyapi.com/api/character/avatar/8.jpeg',
      'episode': ['https://rickandmortyapi.com/api/episode/28'],
      'url': 'https://rickandmortyapi.com/api/character/8',
      'created': '2017-11-04T20:03:34.737Z',
    },
  ],
};
