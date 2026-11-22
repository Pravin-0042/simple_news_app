import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
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
  final List<String> authors;
  final DateTime? publishedAt;
  final String? url;

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    imageUrl,
    newsSite,
    authors,
    publishedAt,
    url,
  ];
}
