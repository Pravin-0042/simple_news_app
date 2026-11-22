import 'package:material_ui/material_ui.dart';

import '../bloc/discover_state.dart';

class DiscoverFilterSheet extends StatefulWidget {
  const DiscoverFilterSheet({
    super.key,
    required this.state,
    required this.onApply,
  });

  final DiscoverState state;
  final void Function({
    String? source,
    required bool clearSource,
    required ArticleSortOrder sortOrder,
    required ArticleDateRange dateRange,
  })
  onApply;

  @override
  State<DiscoverFilterSheet> createState() => _DiscoverFilterSheetState();
}

class _DiscoverFilterSheetState extends State<DiscoverFilterSheet> {
  late final TextEditingController _sourceController = TextEditingController(
    text: widget.state.sourceFilter ?? '',
  );
  late ArticleSortOrder _sortOrder = widget.state.sortOrder;
  late ArticleDateRange _dateRange = widget.state.dateRange;

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source',
                hintText: 'For example, NASA',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ArticleSortOrder>(
              initialValue: _sortOrder,
              decoration: const InputDecoration(labelText: 'Sort order'),
              items: const [
                DropdownMenuItem(
                  value: ArticleSortOrder.newestFirst,
                  child: Text('Newest first'),
                ),
                DropdownMenuItem(
                  value: ArticleSortOrder.oldestFirst,
                  child: Text('Oldest first'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sortOrder = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ArticleDateRange>(
              initialValue: _dateRange,
              decoration: const InputDecoration(labelText: 'Date range'),
              items: const [
                DropdownMenuItem(
                  value: ArticleDateRange.all,
                  child: Text('Any time'),
                ),
                DropdownMenuItem(
                  value: ArticleDateRange.last7Days,
                  child: Text('Last 7 days'),
                ),
                DropdownMenuItem(
                  value: ArticleDateRange.last30Days,
                  child: Text('Last 30 days'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _dateRange = value);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _sourceController.clear();
                    setState(() {
                      _sortOrder = ArticleSortOrder.newestFirst;
                      _dateRange = ArticleDateRange.all;
                    });
                    widget.onApply(
                      clearSource: true,
                      sortOrder: _sortOrder,
                      dateRange: _dateRange,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    final source = _sourceController.text.trim();
                    widget.onApply(
                      source: source.isEmpty ? null : source,
                      clearSource: source.isEmpty,
                      sortOrder: _sortOrder,
                      dateRange: _dateRange,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
