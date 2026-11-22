import '../../../../core/network/api_client.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_page.dart';
import '../../domain/repositories/news_repository.dart';
import '../models/article_model.dart';
import '../models/article_page_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ArticlePage> getArticles({
    required int limit,
    required int offset,
    String? query,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      'articles/',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (query != null && query.trim().isNotEmpty)
          'title_contains': query.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('The articles response was empty.');
    }
    return ArticlePageModel.fromJson(data).toEntity();
  }

  @override
  Future<Article> getArticleById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      'articles/$id/',
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('The article response was empty.');
    }
    return ArticleModel.fromJson(data).toEntity();
  }
}
