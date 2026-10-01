import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Базовый адрес открытого API: https://rickandmortyapi.com/documentation
const String rickAndMortyBaseUrl = 'https://rickandmortyapi.com/api';

/// Создаёт настроенный экземпляр Dio. Один клиент используется во всём
/// приложении, чтобы переиспользовать соединения и общие настройки.
Dio createApiClient({String baseUrl = rickAndMortyBaseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      // Dio сам декодирует JSON. Большие ответы декодируются в отдельном
      // изоляте (BackgroundTransformer по умолчанию), поэтому UI не подвисает.
      responseType: ResponseType.json,
    ),
  );

  // В отладочной сборке выводим запросы в консоль, в релизе логов нет.
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        logPrint: (message) => debugPrint(message.toString()),
      ),
    );
  }
  return dio;
}
