import '../../domain/entities/article_page.dart';
import 'article_model.dart';

int _countFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

String? _stringOrNull(Object? value) {
  return value is String ? value : null;
}

Map<String, dynamic> _stringKeyedMap(Map value) {
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

List<ArticleModel> _resultsFromJson(Object? value) {
  if (value is! List) {
    return const <ArticleModel>[];
  }
  return value
      .whereType<Map>()
      .map((item) => ArticleModel.fromJson(_stringKeyedMap(item)))
      .toList();
}

class ArticlePageModel {
  const ArticlePageModel({
    this.count = 0,
    this.results = const <ArticleModel>[],
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ArticleModel> results;

  factory ArticlePageModel.fromJson(Map<String, dynamic> json) {
    return ArticlePageModel(
      count: _countFromJson(json['count']),
      next: _stringOrNull(json['next']),
      previous: _stringOrNull(json['previous']),
      results: _resultsFromJson(json['results']),
    );
  }

  ArticlePage toEntity() {
    return ArticlePage(
      count: count,
      next: next,
      previous: previous,
      articles: results.map((article) => article.toEntity()).toList(),
    );
  }
}
