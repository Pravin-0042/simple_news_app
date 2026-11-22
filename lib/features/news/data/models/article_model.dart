import '../../domain/entities/article.dart';
import 'author_model.dart';

DateTime? _dateTimeFromJson(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String? _stringFromJson(Object? value) {
  return value is String ? value : null;
}

List<Author> _authorsFromJson(Object? value) {
  if (value is! List) {
    return const <Author>[];
  }

  return value
      .whereType<Map>()
      .map((author) => Author.fromJson(Map<String, dynamic>.from(author)))
      .toList();
}

class ArticleModel {
  const ArticleModel({
    this.id,
    this.title,
    this.summary,
    this.imageUrl,
    this.newsSite,
    this.authors = const [],
    this.publishedAt,
    this.url,
  });

  final int? id;
  final String? title;
  final String? summary;
  final String? imageUrl;
  final String? newsSite;
  final List<Author> authors;
  final DateTime? publishedAt;
  final String? url;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: _intFromJson(json['id']),
      title: _stringFromJson(json['title']),
      summary: _stringFromJson(json['summary']),
      imageUrl: _stringFromJson(json['image_url']),
      newsSite: _stringFromJson(json['news_site']),
      authors: _authorsFromJson(json['authors']),
      publishedAt: _dateTimeFromJson(json['published_at']),
      url: _stringFromJson(json['url']),
    );
  }

  Article toEntity() {
    return Article(
      id: id,
      title: title,
      summary: summary,
      imageUrl: imageUrl,
      newsSite: newsSite,
      authors: authors
          .map((author) => author.name?.trim())
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .toList(),
      publishedAt: publishedAt,
      url: url,
    );
  }
}
