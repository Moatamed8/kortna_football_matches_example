import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/theme/app_palette.dart";
import "package:soccer/features/news/domain/entities/story.dart";

class StoryStack extends StatelessWidget {
  const StoryStack({required this.stories, required this.onTap, super.key});

  final List<Story> stories;
  final ValueChanged<Story> onTap;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();
    final featured = stories.first;
    final rest = stories.skip(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeaturedStory(story: featured, onTap: () => onTap(featured)),
        for (final story in rest)
          StoryRow(story: story, onTap: () => onTap(story)),
      ],
    );
  }
}

class FeaturedStory extends StatelessWidget {
  const FeaturedStory({required this.story, required this.onTap, super.key});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _StoryImage(url: story.imageUrl, featured: true),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.headline,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Meta(story: story),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryRow extends StatelessWidget {
  const StoryRow({required this.story, required this.onTap, super.key});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 88,
                height: 72,
                child: _StoryImage(url: story.imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.headline,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Meta(story: story),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final time = story.publishedAt == null ? null : relativeTime(story.publishedAt!);
    return Text(
      [story.source, ?time].join("  ·  "),
      style: TextStyle(color: palette.muted, fontSize: 12),
    );
  }
}

class _StoryImage extends StatelessWidget {
  const _StoryImage({required this.url, this.featured = false});

  final String? url;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return ColoredBox(
        color: context.palette.surfaceHigh,
        child: Icon(
          Icons.image_outlined,
          color: context.palette.muted,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      memCacheWidth: featured ? 900 : 300,
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => ColoredBox(color: context.palette.surfaceHigh),
      errorWidget: (_, _, _) => ColoredBox(
        color: context.palette.surfaceHigh,
        child: Icon(Icons.image_outlined, color: context.palette.muted),
      ),
    );
  }
}
