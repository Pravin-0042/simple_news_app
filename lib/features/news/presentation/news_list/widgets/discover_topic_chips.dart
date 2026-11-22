import 'package:material_ui/material_ui.dart';

import '../bloc/discover_state.dart';

class DiscoverTopicChips extends StatelessWidget {
  const DiscoverTopicChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DiscoverTopic selected;
  final ValueChanged<DiscoverTopic> onSelected;

  static const _topics = {
    DiscoverTopic.all: 'All',
    DiscoverTopic.nasa: 'NASA',
    DiscoverTopic.spacex: 'SpaceX',
    DiscoverTopic.launches: 'Launches',
    DiscoverTopic.science: 'Science',
    DiscoverTopic.technology: 'Technology',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in _topics.entries) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: selected == entry.key,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: selected == entry.key
                      ? Colors.white
                      : const Color.fromARGB(255, 131, 129, 129),
                  // fontWeight: FontWeight.w600,s
                  fontSize: 13,
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.15),
                side: BorderSide.none,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                onSelected: (_) => onSelected(entry.key),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
