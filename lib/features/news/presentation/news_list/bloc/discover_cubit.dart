import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_page.dart';
import '../../../domain/repositories/news_repository.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit(this._repository) : super(const DiscoverState());

  static const _pageSize = 20;
  final NewsRepository _repository;
  Timer? _searchTimer;
  int _requestVersion = 0;
  int _offset = 0;
  List<Article> _allLoadedArticles = const [];

  List<Article> get visibleArticles {
    final query = state.searchQuery.trim().toLowerCase();
    final source = state.sourceFilter?.trim().toLowerCase();
    final now = DateTime.now();
    final filtered = state.articles.where((article) {
      if (query.isNotEmpty &&
          !(article.title ?? '').toLowerCase().contains(query) &&
          !(article.summary ?? '').toLowerCase().contains(query)) {
        return false;
      }
      if (source != null &&
          source.isNotEmpty &&
          (article.newsSite ?? '').toLowerCase() != source) {
        return false;
      }
      final searchable = '${article.title ?? ''} ${article.summary ?? ''}'
          .toLowerCase();
      final topicMatches = switch (state.topic) {
        DiscoverTopic.all => true,
        DiscoverTopic.nasa => searchable.contains('nasa'),
        DiscoverTopic.spacex => searchable.contains('spacex'),
        DiscoverTopic.launches =>
          searchable.contains('launch') || searchable.contains('rocket'),
        DiscoverTopic.science =>
          searchable.contains('science') || searchable.contains('research'),
        DiscoverTopic.technology =>
          searchable.contains('technology') || searchable.contains('tech'),
      };
      if (!topicMatches) {
        return false;
      }
      final publishedAt = article.publishedAt;
      if (state.dateRange != ArticleDateRange.all &&
          (publishedAt == null ||
              now.difference(publishedAt).inDays >
                  (state.dateRange == ArticleDateRange.last7Days ? 7 : 30))) {
        return false;
      }
      return true;
    }).toList();
    filtered.sort((a, b) {
      final aDate = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return state.sortOrder == ArticleSortOrder.newestFirst
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    });
    return filtered;
  }

  Future<void> loadInitial() => _loadFirstPage();

  void searchChanged(String query) {
    _requestVersion++;
    emit(state.copyWith(searchQuery: query, status: DiscoverStatus.loading));
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 450), _loadFirstPage);
  }

  Future<void> refresh() async {
    _searchTimer?.cancel();
    final version = ++_requestVersion;
    emit(state.copyWith(status: DiscoverStatus.refreshing, refreshError: null));
    try {
      final page = await _fetchPage(offset: 0);
      if (isClosed || version != _requestVersion) return;
      _offset = page.articles.length;
      _allLoadedArticles = state.searchQuery.trim().isEmpty
          ? page.articles
          : _merge(_allLoadedArticles, page.articles);
      final articles = _allLoadedArticles;
      emit(
        state.copyWith(
          status: articles.isEmpty
              ? DiscoverStatus.empty
              : DiscoverStatus.success,
          articles: articles,
          hasMore: page.next != null,
          refreshError: null,
          errorMessage: null,
          paginationError: null,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (isClosed || version != _requestVersion) return;
      if (state.articles.isEmpty) {
        emit(
          state.copyWith(
            status: DiscoverStatus.error,
            errorMessage: _messageFor(error),
            refreshError: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: DiscoverStatus.success,
            refreshError: _messageFor(error),
          ),
        );
      }
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status == DiscoverStatus.loading ||
        state.status == DiscoverStatus.refreshing) {
      return;
    }
    final version = _requestVersion;
    emit(
      state.copyWith(
        isLoadingMore: true,
        paginationError: null,
        errorMessage: null,
      ),
    );
    try {
      final page = await _fetchPage(offset: _offset);
      if (isClosed || version != _requestVersion) return;
      _offset += page.articles.length;
      _allLoadedArticles = _merge(_allLoadedArticles, page.articles);
      final articles = _allLoadedArticles;
      emit(
        state.copyWith(
          status: articles.isEmpty
              ? DiscoverStatus.empty
              : DiscoverStatus.success,
          articles: articles,
          isLoadingMore: false,
          hasMore: page.next != null,
          paginationError: null,
        ),
      );
    } catch (error) {
      if (isClosed || version != _requestVersion) return;
      emit(
        state.copyWith(
          status: DiscoverStatus.success,
          isLoadingMore: false,
          paginationError: _messageFor(error),
        ),
      );
    }
  }

  void setTopic(DiscoverTopic topic) {
    emit(state.copyWith(topic: topic));
  }

  void setFilters({
    String? source,
    required bool clearSource,
    required ArticleSortOrder sortOrder,
    required ArticleDateRange dateRange,
  }) {
    emit(
      state.copyWith(
        sourceFilter: source,
        clearSourceFilter: clearSource,
        sortOrder: sortOrder,
        dateRange: dateRange,
      ),
    );
  }

  Future<void> _loadFirstPage() async {
    final version = ++_requestVersion;
    final wasLoaded = state.articles.isNotEmpty;
    emit(
      state.copyWith(
        status: wasLoaded ? DiscoverStatus.refreshing : DiscoverStatus.loading,
        errorMessage: null,
        refreshError: null,
        paginationError: null,
        isLoadingMore: false,
      ),
    );
    try {
      final page = await _fetchPage(offset: 0);
      if (isClosed || version != _requestVersion) return;
      _offset = page.articles.length;
      _allLoadedArticles = state.searchQuery.trim().isEmpty
          ? page.articles
          : _merge(_allLoadedArticles, page.articles);
      final articles = _allLoadedArticles;
      emit(
        state.copyWith(
          status: articles.isEmpty
              ? DiscoverStatus.empty
              : DiscoverStatus.success,
          articles: articles,
          hasMore: page.next != null,
          errorMessage: null,
          refreshError: null,
        ),
      );
    } catch (error) {
      if (isClosed || version != _requestVersion) return;
      emit(
        state.copyWith(
          status: DiscoverStatus.error,
          errorMessage: _messageFor(error),
          refreshError: null,
        ),
      );
    }
  }

  Future<ArticlePage> _fetchPage({required int offset}) {
    return _repository.getArticles(
      limit: _pageSize,
      offset: offset,
      query: state.searchQuery,
    );
  }

  List<Article> _merge(List<Article> existing, List<Article> incoming) {
    final ids = existing.map((article) => article.id).whereType<int>().toSet();
    return [
      ...existing,
      for (final article in incoming)
        if (article.id == null || ids.add(article.id!)) article,
    ];
  }

  String _messageFor(Object error) {
    return error.toString().replaceFirst('NetworkException: ', '');
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
