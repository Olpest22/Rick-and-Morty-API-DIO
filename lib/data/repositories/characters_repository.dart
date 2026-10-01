import 'package:dio/dio.dart';

import '../api/api_exception.dart';
import '../models/character.dart';
import '../models/characters_page.dart';

/// Слой доступа к данным. Интерфейс ничего не знает о Dio и HTTP:
/// он получает готовые объекты Dart или [ApiException].
class CharactersRepository {
  CharactersRepository(this._dio);

  final Dio _dio;

  /// GET /character?page=&name=&status=
  ///
  /// [cancelToken] позволяет отменить запрос, если он стал неактуальным
  /// (например, пользователь изменил текст поиска до получения ответа).
  Future<CharactersPage> fetchCharacters({
    int page = 1,
    String name = '',
    CharacterStatus? status,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/character',
        queryParameters: {
          'page': page,
          if (name.isNotEmpty) 'name': name,
          if (status != null) 'status': status.apiValue,
        },
        cancelToken: cancelToken,
      );

      final json = response.data;
      if (json == null) {
        throw const ApiException('Сервер вернул пустой ответ.');
      }
      return CharactersPage.fromJson(json);
    } on DioException catch (exception) {
      // Особенность этого API: если по фильтру никого не найдено,
      // приходит 404 {"error": "There is nothing here"}. Это не ошибка,
      // а пустой результат поиска.
      final isNothingFound = exception.response?.statusCode == 404 &&
          (name.isNotEmpty || status != null);
      if (isNothingFound) return CharactersPage.empty;

      throw ApiException.fromDioException(exception);
    } on TypeError {
      // JSON пришёл, но его структура не совпадает с ожидаемой.
      throw const ApiException('Не удалось разобрать ответ сервера.');
    }
  }
}
