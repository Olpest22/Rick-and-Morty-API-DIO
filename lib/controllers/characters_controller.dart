import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/api/api_exception.dart';
import '../data/models/character.dart';
import '../data/repositories/characters_repository.dart';

/// Состояние главного экрана: список персонажей, пагинация, поиск,
/// фильтр по статусу, индикаторы загрузки и ошибки.
class CharactersController extends ChangeNotifier {
  CharactersController(this._repository);

  final CharactersRepository _repository;

  final List<Character> _characters = [];
  int _totalCount = 0;
  int _nextPage = 1;
  bool _hasMore = false;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _loadMoreErrorMessage;

  String _searchQuery = '';
  CharacterStatus? _statusFilter;

  /// Токен текущего запроса: при новом поиске старый запрос отменяется,
  /// чтобы устаревший ответ не перезаписал свежие данные.
  CancelToken? _cancelToken;
  Timer? _searchDebounce;
  bool _isDisposed = false;

  UnmodifiableListView<Character> get characters =>
      UnmodifiableListView(_characters);
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get loadMoreErrorMessage => _loadMoreErrorMessage;
  CharacterStatus? get statusFilter => _statusFilter;

  /// Загружает первую страницу с текущими фильтрами.
  /// Используется при запуске, смене фильтра, «Повторить» и pull-to-refresh.
  Future<void> loadFirstPage() async {
    _cancelToken?.cancel();
    final cancelToken = _cancelToken = CancelToken();

    _isLoading = true;
    _isLoadingMore = false;
    _errorMessage = null;
    _loadMoreErrorMessage = null;
    _notify();

    try {
      final page = await _repository.fetchCharacters(
        name: _searchQuery,
        status: _statusFilter,
        cancelToken: cancelToken,
      );
      // Пока ждали ответ, мог начаться новый запрос — тогда этот ответ устарел.
      if (cancelToken.isCancelled) return;

      _characters
        ..clear()
        ..addAll(page.results);
      _totalCount = page.info.count;
      _hasMore = page.info.hasNextPage;
      _nextPage = 2;
    } on ApiException catch (exception) {
      if (exception.isCancelled) return;
      _characters.clear();
      _totalCount = 0;
      _hasMore = false;
      _errorMessage = exception.message;
    } finally {
      // Состояние меняет только последний (актуальный) запрос.
      if (!cancelToken.isCancelled) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// Догружает следующую страницу при прокрутке списка вниз.
  Future<void> loadNextPage() async {
    // Защита от повторных вызовов, пока предыдущая загрузка не завершилась.
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    final cancelToken = _cancelToken = CancelToken();
    _isLoadingMore = true;
    _loadMoreErrorMessage = null;
    _notify();

    try {
      final page = await _repository.fetchCharacters(
        page: _nextPage,
        name: _searchQuery,
        status: _statusFilter,
        cancelToken: cancelToken,
      );
      if (cancelToken.isCancelled) return;

      _characters.addAll(page.results);
      _hasMore = page.info.hasNextPage;
      _nextPage++;
    } on ApiException catch (exception) {
      if (exception.isCancelled) return;
      _loadMoreErrorMessage = exception.message;
    } finally {
      if (!cancelToken.isCancelled) {
        _isLoadingMore = false;
        _notify();
      }
    }
  }

  /// Поиск по имени с задержкой: запрос уходит через 500 мс после того,
  /// как пользователь перестал печатать, а не на каждую букву.
  void updateSearchQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery == _searchQuery) return;

    _searchQuery = normalizedQuery;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(loadFirstPage()),
    );
  }

  void updateStatusFilter(CharacterStatus? status) {
    if (status == _statusFilter) return;
    _statusFilter = status;
    _searchDebounce?.cancel();
    unawaited(loadFirstPage());
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }
}
