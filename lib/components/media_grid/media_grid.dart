import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../../data/models.dart';

/// The "Last 3 months (7)" group heading above a [MediaGridSliver].
///
/// Shared by the patient and treatment Media tabs.
class MediaSectionHeading extends StatelessWidget {
  const MediaSectionHeading({required this.label, required this.count, super.key});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(child: DSText(label, style: tokens.text.headingBase)),
        SizedBox(width: tokens.spacing.component.xxs),
        DSText(
          '($count)',
          style: tokens.text.textLg.copyWith(color: tokens.text.subdued),
        ),
      ],
    );
  }
}

/// The responsive grid of media tiles shown by the patient and treatment
/// Media tabs, owning the tile selection state.
///
/// Selection is the one genuinely interactive part of this grid: the
/// checkbox on each tile toggles, and once anything is selected a plain tap
/// on a tile toggles it too (DS multi-select behaviour). Everything else
/// (the per-tile actions) is inert.
///
/// This is a sliver widget — it must be placed inside a sliver context (a
/// [CustomScrollView]'s `slivers`), directly or nested inside one added for
/// this purpose.
class MediaGridSliver extends StatefulWidget {
  const MediaGridSliver({required this.media, super.key});

  final List<MediaItem> media;

  @override
  State<MediaGridSliver> createState() => _MediaGridSliverState();
}

class _MediaGridSliverState extends State<MediaGridSliver> {
  final Set<int> _selected = <int>{};

  void _toggle(int index, bool value) => setState(() {
    if (value) {
      _selected.add(index);
    } else {
      _selected.remove(index);
    }
  });

  @override
  Widget build(BuildContext context) => DSMediaTileSliverGrid(
    tileCount: widget.media.length,
    tileBuilder: (context, index) {
      final item = widget.media[index];
      return DSMediaTile(
        title: item.title,
        subtitle: item.timestamp,
        typeTagText: item.tag,
        imageProvider: AssetImage(item.assetPath),
        placeholderParams: DSMediaTilePlaceholderParams(
          icon: _placeholderIconFor(item.tag),
        ),
        selected: _selected.contains(index),
        selectionMode: _selected.isNotEmpty,
        onSelectedChanged: (value) => _toggle(index, value),
        onPressed: () {},
        actions: [
          [
            DSAction(
              title: 'Open in Canvas',
              icon: DSIcons.canvas,
              onTrigger: () {},
            ),
            DSAction(
              title: 'Download',
              icon: DSIcons.download,
              onTrigger: () {},
            ),
            DSAction(title: 'Share', icon: DSIcons.share, onTrigger: () {}),
          ],
          [
            DSAction(
              title: 'Delete',
              icon: DSIcons.trash,
              destructive: true,
              onTrigger: () {},
            ),
          ],
        ],
      );
    },
  );

  /// Picks a placeholder icon from the tile's tag, e.g. `DI · 3`, `PHOTO · 12`.
  ///
  /// Only used if [DSMediaTile.imageProvider] fails to load.
  static DSIconRef _placeholderIconFor(String? tag) =>
      (tag ?? '').toUpperCase().startsWith('PHOTO')
      ? DSIcons.image
      : DSIcons.jawFull;
}
