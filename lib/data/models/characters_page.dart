import 'character.dart';

/// Блок `info` ответа: сведения о пагинации.
class PageInfo {
  const PageInfo({
    required this.count,
    required this.pages,
    required this.hasNextPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      count: json['count'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      // Ссылка `next` равна null на последней странице.
      hasNextPage: json['next'] != null,
    );
  }

  /// Общее количество найденных персонажей.
  final int count;
  final int pages;
  final bool hasNextPage;
}

/// Одна страница ответа `GET /character`:
/// `{ "info": {...}, "results": [ {...}, ... ] }`.
class CharactersPage {
  const CharactersPage({required this.info, required this.results});

  factory CharactersPage.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return CharactersPage(
      info: PageInfo.fromJson(json['info'] as Map<String, dynamic>),
      results: rawResults
          .map((item) => Character.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  /// Пустой результат (по фильтру ничего не найдено).
  static const empty = CharactersPage(
    info: PageInfo(count: 0, pages: 0, hasNextPage: false),
    results: [],
  );

  final PageInfo info;
  final List<Character> results;
}
