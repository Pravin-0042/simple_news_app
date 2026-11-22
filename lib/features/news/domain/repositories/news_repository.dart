import '../entities/article.dart';
import '../entities/article_page.dart';

abstract interface class NewsRepository {
  Future<ArticlePage> getArticles({
    required int limit,
    required int offset,
    String? query,
  });

  Future<Article> getArticleById(int id);
}
