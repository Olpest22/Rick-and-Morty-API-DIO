import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_characters/data/api/api_exception.dart';
import 'package:rick_morty_characters/data/models/character.dart';
import 'package:rick_morty_characters/data/repositories/characters_repository.dart';

import 'fixtures.dart';

/// Подменяет сетевой слой Dio: тесты работают без интернета.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

CharactersRepository createRepository(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return CharactersRepository(dio);
}

void main() {
  test('успешный GET-запрос возвращает распарсенную страницу', () async {
    final adapter =
        FakeHttpAdapter((_) => jsonResponse(sampleCharactersResponse, 200));
    final repository = createRepository(adapter);

    final page = await repository.fetchCharacters(
      page: 2,
      name: 'rick',
      status: CharacterStatus.alive,
    );

    expect(page.results.first.name, 'Rick Sanchez');
    expect(adapter.lastRequest?.method, 'GET');
    expect(adapter.lastRequest?.path, '/character');
    expect(adapter.lastRequest?.queryParameters, {
      'page': 2,
      'name': 'rick',
      'status': 'alive',
    });
  });

  test('404 при поиске означает пустой результат, а не ошибку', () async {
    final repository = createRepository(FakeHttpAdapter(
      (_) => jsonResponse({'error': 'There is nothing here'}, 404),
    ));

    final page = await repository.fetchCharacters(name: 'zzzz');

    expect(page.results, isEmpty);
    expect(page.info.count, 0);
  });

  test('ошибка сервера превращается в ApiException', () async {
    final repository = createRepository(
      FakeHttpAdapter((_) => jsonResponse({'error': 'boom'}, 500)),
    );

    expect(
      repository.fetchCharacters(),
      throwsA(isA<ApiException>().having(
        (e) => e.message,
        'message',
        contains('Ошибка на сервере'),
      )),
    );
  });

  test('отсутствие соединения превращается в ApiException', () async {
    final repository = createRepository(FakeHttpAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }));

    expect(
      repository.fetchCharacters(),
      throwsA(isA<ApiException>().having(
        (e) => e.message,
        'message',
        contains('Нет подключения'),
      )),
    );
  });

  test('неожиданная структура JSON не роняет приложение', () async {
    final repository = createRepository(
      FakeHttpAdapter((_) => jsonResponse({'unexpected': true}, 200)),
    );

    expect(repository.fetchCharacters(), throwsA(isA<ApiException>()));
  });
}
