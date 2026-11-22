import 'package:equatable/equatable.dart';

import 'article.dart';

class ArticlePage extends Equatable {
  const ArticlePage({
    required this.count,
    required this.articles,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<Article> articles;

  @override
  List<Object?> get props => [count, next, previous, articles];
}
