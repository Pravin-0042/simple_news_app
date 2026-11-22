import 'package:go_router/go_router.dart';

import '../../features/news/domain/entities/article.dart';
import '../../features/news/presentation/news_detail/bloc/article_detail_cubit.dart';
import '../../features/news/presentation/news_detail/screens/article_detail_screen.dart';
import '../../features/news/presentation/news_list/screens/discover_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DiscoverScreen()),
    GoRoute(
      path: '/articles/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        final article = state.extra is Article ? state.extra! as Article : null;
        if (state.extra is ArticleDetailArguments) {
          final arguments = state.extra! as ArticleDetailArguments;
          return ArticleDetailScreen(arguments: arguments);
        }
        if (article != null) {
          return ArticleDetailScreen(
            arguments: ArticleDetailArguments(
              article: article,
              articles: [article],
              initialIndex: 0,
              hasMore: false,
            ),
          );
        }
        return ArticleDetailScreen(
          arguments: ArticleDetailArguments(
            article: Article(id: id),
            articles: [Article(id: id)],
            initialIndex: 0,
            hasMore: false,
          ),
        );
      },
    ),
  ],
);
