import 'package:dio/dio.dart';

/// Ошибка загрузки данных с понятным пользователю текстом.
class ApiException implements Exception {
  const ApiException(this.message, {this.isCancelled = false});

  /// Переводит техническую ошибку Dio в сообщение для пользователя.
  factory ApiException.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout: 
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'Сервер слишком долго не отвечает. Попробуйте ещё раз.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Нет подключения к интернету или сервер недоступен.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          'Не удалось установить защищённое соединение с сервером.',
        );
      case DioExceptionType.badResponse:
        return ApiException(
          _messageForStatusCode(exception.response?.statusCode),
        );
      case DioExceptionType.cancel:
        return const ApiException('Запрос отменён', isCancelled: true);
      case DioExceptionType.unknown:
        return const ApiException(
          'Не удалось выполнить запрос. Проверьте подключение к сети.',
        );
    }
  }

  final String message;

  /// true, если запрос отменён приложением (например, пользователь
  /// изменил поисковый запрос). Такую «ошибку» не нужно показывать.
  final bool isCancelled;

  static String _messageForStatusCode(int? statusCode) {
    if (statusCode == null) return 'Сервер вернул некорректный ответ.';
    if (statusCode == 404) return 'Данные не найдены: неверный адрес запроса.';
    if (statusCode == 429) return 'Слишком много запросов. Подождите немного.';
    if (statusCode >= 500) return 'Ошибка на сервере ($statusCode). Попробуйте позже.';
    return 'Ошибка запроса (код $statusCode).';
  }

  @override
  String toString() => 'ApiException: $message';
}
