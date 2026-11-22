import 'package:cached_network_image/cached_network_image.dart';
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/di/injection.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/repositories/news_repository.dart';
import '../../news_list/widgets/discover_states.dart';
import '../bloc/article_detail_cubit.dart';
import '../bloc/article_detail_state.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.arguments});

  final ArticleDetailArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArticleDetailCubit(getIt<NewsRepository>(), arguments)
            ..loadCurrentArticle(),
      child: const _ArticleDetailView(),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  const _ArticleDetailView();

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ArticleDetailCubit>().state;
    _pageController = PageController(initialPage: state.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
      builder: (context, state) {
        final cubit = context.read<ArticleDetailCubit>();
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.articles.length,
                  onPageChanged: cubit.selectArticle,
                  itemBuilder: (context, index) {
                    final article = state.articles[index];
                    final isCurrent = index == state.currentIndex;
                    return _ArticlePage(
                      article: article,
                      isLoading:
                          isCurrent &&
                          state.status == ArticleDetailStatus.loading,
                      errorMessage: isCurrent ? state.errorMessage : null,
                      onBack: () => Navigator.of(context).maybePop(),
                      bookmarked: isCurrent && state.bookmarked,
                      onBookmark: cubit.toggleBookmark,
                      onOpenArticle: () => _openArticle(context, article),
                      onRetry: cubit.loadCurrentArticle,
                    );
                  },
                ),
              ),
              if (state.articles.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '${state.currentIndex + 1} of ${state.articles.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (state.isPaginationLoading)
                const LinearProgressIndicator(minHeight: 2),
              if (state.paginationError != null)
                TextButton(
                  onPressed: cubit.loadNextPage,
                  child: const Text('Could not load more articles. Retry'),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openArticle(BuildContext context, Article article) async {
    final value = article.url;
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This article has no valid publisher link.'),
        ),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the publisher link.')),
      );
    }
  }
}

class _ArticlePage extends StatelessWidget {
  const _ArticlePage({
    required this.article,
    required this.isLoading,
    required this.onBack,
    required this.bookmarked,
    required this.onBookmark,
    required this.onOpenArticle,
    required this.onRetry,
    this.errorMessage,
  });

  final Article article;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onBack;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onOpenArticle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && article.title == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && article.title == null) {
      return DiscoverMessage(
        icon: cupertino.CupertinoIcons.exclamationmark_circle,
        title: 'Could not load article',
        message: errorMessage,
        action: FilledButton(onPressed: onRetry, child: const Text('Retry')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = (constraints.maxHeight * 0.53)
            .clamp(320.0, 460.0)
            .toDouble();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _HeroImage(imageUrl: article.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x44000000),
                            Color(0x00000000),
                            Color(0xB8000000),
                          ],
                          stops: [0, 0.38, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 42,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _HeroControl(
                            tooltip: 'Back',
                            icon: cupertino.CupertinoIcons.back,
                            onPressed: onBack,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _HeroControl(
                                tooltip: bookmarked
                                    ? 'Remove bookmark'
                                    : 'Bookmark',
                                icon: bookmarked
                                    ? cupertino.CupertinoIcons.bookmark_fill
                                    : cupertino.CupertinoIcons.bookmark,
                                onPressed: onBookmark,
                              ),
                              const SizedBox(width: 8),
                              _HeroMoreControl(onOpenArticle: onOpenArticle),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.newsSite?.trim().isNotEmpty ?? false)
                            // Text(
                            //   article.newsSite!.trim().toUpperCase(),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: Theme.of(context).textTheme.labelMedium
                            //       ?.copyWith(
                            //         color: Colors.white.withValues(alpha: 0.9),
                            //         fontWeight: FontWeight.w700,
                            //         letterSpacing: 1.1,
                            //       ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 3,
                                ),
                                child: Text(
                                  article.newsSite!.trim().toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),
                          Text(
                            article.title?.trim().isNotEmpty ?? false
                                ? article.title!.trim()
                                : 'Untitled article',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x66000000),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                          ),
                          if (article.publishedAt != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _formatDate(article.publishedAt!),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.newsSite?.trim().isNotEmpty ?? false) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Text(
                                _publisherInitials(article.newsSite!.trim()),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                article.newsSite!.trim(),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (article.summary?.trim().isNotEmpty ?? false)
                        Text(
                          article.summary!.trim(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 15, height: 1.65),
                        )
                      else
                        Text(
                          'No summary is available for this article.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 15,
                                height: 1.65,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onOpenArticle,
                          icon: const Icon(
                            cupertino.CupertinoIcons.arrow_up_right_square,
                          ),
                          label: const Text('Read Full Article'),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return DateFormat("dd MMM yyyy").format(local);
  }

  String _publisherInitials(String publisher) {
    final words = publisher
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    return words.map((word) => word[0].toUpperCase()).join();
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl!);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return const ColoredBox(color: Color(0xFF34434B));
    }
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      fit: BoxFit.cover,
      placeholder: (context, url) => const ColoredBox(color: Color(0xFF34434B)),
      errorWidget: (context, url, error) =>
          const ColoredBox(color: Color(0xFF34434B)),
    );
  }
}

class _HeroControl extends StatelessWidget {
  const _HeroControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 46,
      child: Material(
        color: const cupertino.Color.fromARGB(133, 96, 95, 95),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          color: Colors.white,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          icon: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _HeroMoreControl extends StatelessWidget {
  const _HeroMoreControl({required this.onOpenArticle});

  final VoidCallback onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 46,
      child: Material(
        color: const cupertino.Color.fromARGB(133, 96, 95, 95),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: PopupMenuButton<void>(
          tooltip: 'More options',
          padding: EdgeInsets.zero,
          iconSize: 22,
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          icon: const Icon(
            cupertino.CupertinoIcons.ellipsis,
            color: Colors.white,
            size: 22,
          ),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (_) => onOpenArticle(),
          itemBuilder: (context) => const [
            PopupMenuItem<void>(child: Text('Read Full Article')),
          ],
        ),
      ),
    );
  }
}
