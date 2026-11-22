// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/di/injection.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/repositories/news_repository.dart';
import '../../news_detail/bloc/article_detail_cubit.dart';
import '../bloc/discover_cubit.dart';
import '../bloc/discover_state.dart';
import '../widgets/article_list_item.dart';
import '../widgets/discover_filter_sheet.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/discover_states.dart';
import '../widgets/discover_topic_chips.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoverCubit(getIt<NewsRepository>())..loadInitial(),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<DiscoverCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'News from all around the world',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: BlocBuilder<DiscoverCubit, DiscoverState>(
                builder: (context, state) => DiscoverSearchBar(
                  query: state.searchQuery,
                  onChanged: context.read<DiscoverCubit>().searchChanged,
                  onClear: () =>
                      context.read<DiscoverCubit>().searchChanged(''),
                  onFilter: () => _showFilters(context, state),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<DiscoverCubit, DiscoverState>(
                builder: (context, state) => DiscoverTopicChips(
                  selected: state.topic,
                  onSelected: context.read<DiscoverCubit>().setTopic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<DiscoverCubit, DiscoverState>(
                builder: (context, state) {
                  if (state.articles.isEmpty &&
                      state.status == DiscoverStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.articles.isEmpty &&
                      state.status == DiscoverStatus.error) {
                    return DiscoverMessage(
                      icon: cupertino.CupertinoIcons.exclamationmark_circle,
                      title: 'Could not load articles',
                      message: state.errorMessage,
                      action: FilledButton(
                        onPressed: context.read<DiscoverCubit>().loadInitial,
                        child: const Text('Try again'),
                      ),
                    );
                  }
                  if (state.status == DiscoverStatus.empty ||
                      (state.articles.isNotEmpty &&
                          context
                              .read<DiscoverCubit>()
                              .visibleArticles
                              .isEmpty)) {
                    return RefreshIndicator(
                      onRefresh: context.read<DiscoverCubit>().refresh,
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 320,
                            child: DiscoverMessage(
                              icon: cupertino.CupertinoIcons.doc_text,
                              title: 'No matching articles',
                              message: 'Try changing your search or filters.',
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final articles = context
                      .read<DiscoverCubit>()
                      .visibleArticles;
                  return RefreshIndicator(
                    onRefresh: context.read<DiscoverCubit>().refresh,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount:
                          articles.length +
                          (state.isLoadingMore || state.paginationError != null
                              ? 1
                              : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        if (index >= articles.length) {
                          if (state.paginationError != null) {
                            return TextButton.icon(
                              onPressed: context
                                  .read<DiscoverCubit>()
                                  .loadNextPage,
                              icon: const Icon(
                                cupertino.CupertinoIcons.refresh,
                              ),
                              label: const Text('Could not load more. Retry'),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final article = articles[index];
                        return ArticleListItem(
                          article: article,
                          onTap: () =>
                              _openArticle(context, articles, index, state),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context, DiscoverState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DiscoverFilterSheet(
        state: state,
        onApply:
            ({
              String? source,
              required bool clearSource,
              required ArticleSortOrder sortOrder,
              required ArticleDateRange dateRange,
            }) {
              context.read<DiscoverCubit>().setFilters(
                source: source,
                clearSource: clearSource,
                sortOrder: sortOrder,
                dateRange: dateRange,
              );
            },
      ),
    );
  }

  void _openArticle(
    BuildContext context,
    List<Article> articles,
    int index,
    DiscoverState state,
  ) {
    final article = articles[index];
    context.push(
      '/articles/${article.id ?? ''}',
      extra: ArticleDetailArguments(
        article: article,
        articles: articles,
        initialIndex: index,
        hasMore: state.hasMore,
        initialOffset: state.articles.length,
      ),
    );
  }
}
