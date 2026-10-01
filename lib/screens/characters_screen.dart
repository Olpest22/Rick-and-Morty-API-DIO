import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/characters_controller.dart';
import '../data/models/character.dart';
import '../data/repositories/characters_repository.dart';
import '../widgets/character_card.dart';
import '../widgets/message_view.dart';
import 'character_details_screen.dart';

/// Главный экран: поиск, фильтр по статусу и список персонажей
/// с бесконечной прокруткой и обновлением жестом «потянуть вниз».
class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key, required this.repository});

  final CharactersRepository repository;

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  /// Когда до конца списка остаётся меньше этого расстояния,
  /// начинаем загрузку следующей страницы.
  static const _loadMoreThreshold = 600.0;

  late final CharactersController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CharactersController(widget.repository);
    // Ошибки обрабатываются внутри контроллера, поэтому результат не ждём.
    unawaited(_controller.loadFirstPage());
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.updateSearchQuery('');
  }

  void _openDetails(Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterDetailsScreen(character: character),
      ),
    );
  }

  /// Бесконечная прокрутка: следим за положением списка.
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.extentAfter < _loadMoreThreshold) {
      _controller.loadNextPage();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Персонажи Rick and Morty')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) => SearchBar(
                controller: _searchController,
                hintText: 'Поиск по имени (на английском)',
                leading: const Icon(Icons.search),
                trailing: [
                  if (value.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Очистить',
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    ),
                ],
                onChanged: _controller.updateSearchQuery,
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusFilterBar(
                    selectedStatus: _controller.statusFilter,
                    onSelected: _controller.updateStatusFilter,
                  ),
                  // Тонкая полоса загрузки, когда на экране уже есть старые
                  // данные (смена фильтра, обновление).
                  SizedBox(
                    height: 4,
                    child: _controller.isLoading &&
                            _controller.characters.isNotEmpty
                        ? const LinearProgressIndicator()
                        : null,
                  ),
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final characters = _controller.characters;

    if (_controller.isLoading && characters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = _controller.errorMessage;
    if (errorMessage != null) {
      return MessageView(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить данные',
        message: errorMessage,
        actionLabel: 'Повторить',
        onAction: _controller.loadFirstPage,
      );
    }

    if (characters.isEmpty) {
      return const MessageView(
        icon: Icons.person_search_outlined,
        title: 'Никого не нашли',
        message: 'Попробуйте изменить запрос или фильтр по статусу.',
      );
    }

    // Высота карточки растёт вместе с системным размером шрифта.
    final textScale =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.5).toDouble();

    return RefreshIndicator(
      onRefresh: _controller.loadFirstPage,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: CustomScrollView(
          // Позволяет потянуть список вниз, даже если он короткий.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Найдено персонажей: ${_controller.totalCount}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Сетка с ограниченной шириной колонки: на телефоне одна
              // колонка, на планшете и в альбомной ориентации — несколько.
              // Builder создаёт только видимые карточки.
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisExtent: 130 * textScale,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return CharacterCard(
                    key: ValueKey(character.id),
                    character: character,
                    onTap: () => _openDetails(character),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildListFooter(context)),
          ],
        ),
      ),
    );
  }

  /// Низ списка: индикатор догрузки, ошибка догрузки или итог.
  Widget _buildListFooter(BuildContext context) {
    final theme = Theme.of(context);
    final Widget child;

    if (_controller.isLoadingMore) {
      child = const CircularProgressIndicator();
    } else if (_controller.loadMoreErrorMessage != null) {
      child = Column(
        children: [
          Text(
            _controller.loadMoreErrorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          TextButton.icon(
            onPressed: _controller.loadNextPage,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      );
    } else if (_controller.hasMore) {
      // Запасной вариант, если экран большой и прокрутка не началась.
      child = OutlinedButton(
        onPressed: _controller.loadNextPage,
        child: const Text('Загрузить ещё'),
      );
    } else {
      child = Text(
        'Это все персонажи',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: child),
    );
  }
}

/// Фильтр по статусу: «Все», «Жив», «Мёртв», «Неизвестно».
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selectedStatus,
    required this.onSelected,
  });

  final CharacterStatus? selectedStatus;
  final ValueChanged<CharacterStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Все'),
            selected: selectedStatus == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final status in CharacterStatus.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(status.label),
              selected: selectedStatus == status,
              onSelected: (_) => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}
