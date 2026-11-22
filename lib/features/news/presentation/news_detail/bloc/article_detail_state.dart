import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum ArticleDetailStatus { loading, success, error }

class ArticleDetailState extends Equatable {
  const ArticleDetailState({
    required this.articles,
    required this.currentIndex,
    required this.article,
    this.status = ArticleDetailStatus.loading,
    this.errorMessage,
    this.isPaginationLoading = false,
    this.paginationError,
    this.bookmarked = false,
    this.hasMore = true,
  });

  final List<Article> articles;
  final int currentIndex;
  final Article article;
  final ArticleDetailStatus status;
  final String? errorMessage;
  final bool isPaginationLoading;
  final String? paginationError;
  final bool bookmarked;
  final bool hasMore;

  ArticleDetailState copyWith({
    List<Article>? articles,
    int? currentIndex,
    Article? article,
    ArticleDetailStatus? status,
    String? errorMessage,
    bool? isPaginationLoading,
    String? paginationError,
    bool? bookmarked,
    bool? hasMore,
  }) {
    return ArticleDetailState(
      articles: articles ?? this.articles,
      currentIndex: currentIndex ?? this.currentIndex,
      article: article ?? this.article,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      paginationError: paginationError,
      bookmarked: bookmarked ?? this.bookmarked,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    articles,
    currentIndex,
    article,
    status,
    errorMessage,
    isPaginationLoading,
    paginationError,
    bookmarked,
    hasMore,
  ];
}
