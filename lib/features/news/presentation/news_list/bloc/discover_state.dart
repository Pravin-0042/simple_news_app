import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum DiscoverStatus { initial, loading, success, empty, error, refreshing }

enum DiscoverTopic { all, nasa, spacex, launches, science, technology }

enum ArticleSortOrder { newestFirst, oldestFirst }

enum ArticleDateRange { all, last7Days, last30Days }

class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.articles = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.isLoadingMore = false,
    this.paginationError,
    this.hasMore = true,
    this.refreshError,
    this.topic = DiscoverTopic.all,
    this.sourceFilter,
    this.sortOrder = ArticleSortOrder.newestFirst,
    this.dateRange = ArticleDateRange.all,
  });

  final DiscoverStatus status;
  final List<Article> articles;
  final String searchQuery;
  final String? errorMessage;
  final bool isLoadingMore;
  final String? paginationError;
  final bool hasMore;
  final String? refreshError;
  final DiscoverTopic topic;
  final String? sourceFilter;
  final ArticleSortOrder sortOrder;
  final ArticleDateRange dateRange;

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Article>? articles,
    String? searchQuery,
    String? errorMessage,
    bool? isLoadingMore,
    String? paginationError,
    bool? hasMore,
    String? refreshError,
    DiscoverTopic? topic,
    String? sourceFilter,
    bool clearSourceFilter = false,
    ArticleSortOrder? sortOrder,
    ArticleDateRange? dateRange,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: paginationError,
      hasMore: hasMore ?? this.hasMore,
      refreshError: refreshError,
      topic: topic ?? this.topic,
      sourceFilter: clearSourceFilter
          ? null
          : sourceFilter ?? this.sourceFilter,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [
    status,
    articles,
    searchQuery,
    errorMessage,
    isLoadingMore,
    paginationError,
    hasMore,
    refreshError,
    topic,
    sourceFilter,
    sortOrder,
    dateRange,
  ];
}
