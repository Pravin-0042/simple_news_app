import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/repositories/news_repository.dart';
import 'article_detail_state.dart';

class ArticleDetailArguments {
  const ArticleDetailArguments({
    required this.article,
    required this.articles,
    required this.initialIndex,
    required this.hasMore,
    this.initialOffset,
  });

  final Article article;
  final List<Article> articles;
  final int initialIndex;
  final bool hasMore;
  final int? initialOffset;
}

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  ArticleDetailCubit(this._repository, ArticleDetailArguments arguments)
    : super(
        ArticleDetailState(
          articles: arguments.articles.isEmpty
              ? [arguments.article]
              : arguments.articles,
          currentIndex: arguments.initialIndex.clamp(
            0,
            (arguments.articles.isEmpty ? 1 : arguments.articles.length) - 1,
          ),
          article: arguments.article,
          status: ArticleDetailStatus.success,
          hasMore: arguments.hasMore,
        ),
      ) {
    _offset = arguments.initialOffset ?? state.articles.length;
  }

  static const _pageSize = 20;
  final NewsRepository _repository;
  bool _isLoadingPage = false;
  late int _offset;

  Future<void> loadCurrentArticle() async {
    final id = state.article.id;
    if (id == null) return;
    emit(
      state.copyWith(status: ArticleDetailStatus.loading, errorMessage: null),
    );
    try {
      final article = await _repository.getArticleById(id);
      if (isClosed || state.article.id != id) return;
      final articles = [...state.articles];
      final index = state.currentIndex;
      if (index >= 0 && index < articles.length) {
        articles[index] = article;
      }
      emit(
        state.copyWith(
          articles: articles,
          article: article,
          status: ArticleDetailStatus.success,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ArticleDetailStatus.error,
          errorMessage: error.toString().replaceFirst('NetworkException: ', ''),
        ),
      );
    }
  }

  void selectArticle(int index) {
    if (index < 0 ||
        index >= state.articles.length ||
        index == state.currentIndex) {
      return;
    }
    emit(
      state.copyWith(
        currentIndex: index,
        article: state.articles[index],
        status: ArticleDetailStatus.success,
        errorMessage: null,
        paginationError: null,
      ),
    );
    loadCurrentArticle();
    if (index == state.articles.length - 1) {
      loadNextPage();
    }
  }

  void toggleBookmark() {
    emit(state.copyWith(bookmarked: !state.bookmarked));
  }

  Future<void> loadNextPage() async {
    if (_isLoadingPage || !state.hasMore) return;
    _isLoadingPage = true;
    emit(state.copyWith(isPaginationLoading: true, paginationError: null));
    try {
      final page = await _repository.getArticles(
        limit: _pageSize,
        offset: _offset,
      );
      if (isClosed) return;
      _offset += page.articles.length;
      final ids = state.articles
          .map((article) => article.id)
          .whereType<int>()
          .toSet();
      final articles = [
        ...state.articles,
        for (final article in page.articles)
          if (article.id == null || ids.add(article.id!)) article,
      ];
      emit(
        state.copyWith(
          articles: articles,
          isPaginationLoading: false,
          hasMore: page.next != null,
          paginationError: null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isPaginationLoading: false,
          paginationError: error.toString().replaceFirst(
            'NetworkException: ',
            '',
          ),
        ),
      );
    } finally {
      _isLoadingPage = false;
    }
  }
}
